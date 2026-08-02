import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../revision/repository/revision_repository.dart';
import '../../schedule/presentation/widgets/schedule_visuals.dart';
import '../../schedule/repository/schedule_repository.dart';
import '../../study_plan/repository/study_plan_repository.dart';
import '../../study_session/repository/study_session_repository.dart';
import '../model/notification_item.dart';
import '../repository/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// Stable ids for the single-slot daily reminders — rescheduling with the
/// same id just replaces the previous alarm rather than stacking a new one.
const int _dailyPlanReadyNotificationId = 9001;
const int _goalReminderNotificationId = 9002;

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepo;
  final NotificationService _notificationService;
  final StudyPlanRepository _studyPlanRepo;
  final ScheduleRepository _scheduleRepo;
  final RevisionRepository _revisionRepo;
  final StudySessionRepository _studySessionRepo;

  StreamSubscription<RemoteMessage>? _fcmSub;

  NotificationBloc(
    this._notificationRepo,
    this._notificationService,
    this._studyPlanRepo,
    this._scheduleRepo,
    this._revisionRepo,
    this._studySessionRepo,
  ) : super(const NotificationState()) {
    on<LoadNotificationsRequested>(_onLoadRequested);
    on<RequestPermissionRequested>(_onRequestPermission);
    on<ForegroundMessageReceived>(_onForegroundMessage);

    _fcmSub = _notificationService.onForegroundMessage.listen(
      (message) => add(ForegroundMessageReceived(message)),
    );
  }

  Future<void> _onRequestPermission(
    RequestPermissionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final granted = await _notificationService.requestPermission();
    emit(state.copyWith(permissionGranted: granted));
  }

  void _onForegroundMessage(
    ForegroundMessageReceived event,
    Emitter<NotificationState> emit,
  ) {
    final notification = event.message.notification;
    final item = NotificationItem(
      type: NotificationItemType.fcm,
      title: notification?.title ?? 'Notification',
      body: notification?.body ?? '',
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(items: [item, ...state.items]));
  }

  Future<void> _onLoadRequested(
    LoadNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationLoadStatus.loading));
    try {
      final preferences = await _notificationRepo.fetchPreferences();
      final plan = await _studyPlanRepo.fetchActivePlan();
      if (plan == null) {
        emit(state.copyWith(status: NotificationLoadStatus.noPlan));
        return;
      }

      final computedItems = <NotificationItem>[];
      final today = todayRange();

      if (preferences.dailyPlanReminderEnabled) {
        computedItems.add(
          NotificationItem(
            type: NotificationItemType.dailyPlanReady,
            title: 'Daily Plan Ready',
            body: 'Your study plan for today is ready.',
            timestamp: today.start,
          ),
        );
        final morning = _parseTime(preferences.morningReminderTime);
        await _notificationService.scheduleDaily(
          id: _dailyPlanReadyNotificationId,
          title: 'Daily Plan Ready',
          body: 'Your study plan for today is ready.',
          hour: morning.$1,
          minute: morning.$2,
        );
      }

      if (preferences.studyReminderEnabled) {
        final schedules = await _scheduleRepo
            .watchSchedules(planId: plan.id, start: today.start, end: today.end)
            .first;
        final remindable = schedules.where((s) => s.reminderEnabled).toList();

        if (remindable.isNotEmpty) {
          final subjectIds = remindable.map((s) => s.subjectId).toSet();
          final topicIds = remindable.map((s) => s.topicId).toSet();
          final subjectNames = await _scheduleRepo.fetchSubjectNames(subjectIds);
          final topicNames = await _scheduleRepo.fetchTopicNames(topicIds);

          for (final schedule in remindable) {
            final subjectName = subjectNames[schedule.subjectId] ?? 'Subject';
            final topicName = topicNames[schedule.topicId] ?? 'Topic';
            final scheduledAt = _scheduleDateTime(
              schedule.scheduledDate,
              schedule.startTime,
            );
            final reminderAt = scheduledAt.subtract(
              Duration(minutes: schedule.reminderMinutesBefore),
            );

            computedItems.add(
              NotificationItem(
                type: NotificationItemType.studyReminder,
                title: 'Study Reminder',
                body: '$subjectName • $topicName at ${formatStartTime(schedule.startTime)}',
                timestamp: reminderAt,
              ),
            );
            await _notificationService.scheduleAt(
              id: schedule.id.hashCode & 0x7fffffff,
              title: 'Study Reminder',
              body: '$subjectName • $topicName starts soon',
              dateTime: reminderAt,
            );
          }
        }
      }

      if (preferences.revisionReminderEnabled) {
        final dueRevisions = await _revisionRepo.watchDueRevisions().first;
        if (dueRevisions.isNotEmpty) {
          computedItems.add(
            NotificationItem(
              type: NotificationItemType.revisionDue,
              title: 'Revision Due',
              body:
                  '${dueRevisions.length} ${dueRevisions.length == 1 ? 'topic needs' : 'topics need'} revision.',
              timestamp: today.start,
            ),
          );
        }
      }

      if (preferences.goalReminderEnabled) {
        final studyMinutesToday = await _studySessionRepo
            .fetchTotalMinutesForRange(
              planId: plan.id,
              start: today.start,
              end: today.end,
            );
        if (studyMinutesToday < plan.dailyTargetMinutes) {
          computedItems.add(
            NotificationItem(
              type: NotificationItemType.goalReminder,
              title: 'Goal Reminder',
              body: "You haven't reached today's study goal yet.",
              timestamp: today.start,
            ),
          );
        }
        final evening = _parseTime(preferences.eveningReminderTime);
        await _notificationService.scheduleDaily(
          id: _goalReminderNotificationId,
          title: 'Goal Reminder',
          body: "Check today's study goal progress.",
          hour: evening.$1,
          minute: evening.$2,
        );
      }

      // Keep any FCM messages already received this session, newest first.
      final merged = [...state.items, ...computedItems]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(state.copyWith(status: NotificationLoadStatus.success, items: merged));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationLoadStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  DateTime _scheduleDateTime(DateTime scheduledDate, String startTime) {
    final (hour, minute) = _parseTime(startTime);
    return DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minute,
    );
  }

  (int, int) _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return (hour, minute);
  }

  @override
  Future<void> close() {
    _fcmSub?.cancel();
    return super.close();
  }
}
