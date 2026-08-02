import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/schedule_repository.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _repo;
  StreamSubscription? _scheduleSub;
  final Map<String, String> _subjectNameCache = {};
  final Map<String, String> _topicNameCache = {};

  ScheduleBloc(this._repo) : super(const ScheduleState()) {
    on<WatchScheduleRequested>(_onWatchRequested);
    on<WatchScheduleRangeRequested>(_onWatchRangeRequested);
    on<ScheduleStreamUpdated>(_onStreamUpdated);
    on<ScheduleStreamFailed>(_onStreamFailed);
    on<AddScheduleRequested>(_onAddRequested);
  }

  Future<void> _onWatchRequested(
    WatchScheduleRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleListStatus.loading));
    await _subscribe(
      planId: event.planId,
      start: event.date,
      end: event.date.add(const Duration(days: 1)),
    );
  }

  Future<void> _onWatchRangeRequested(
    WatchScheduleRangeRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleListStatus.loading));
    await _subscribe(planId: event.planId, start: event.start, end: event.end);
  }

  Future<void> _subscribe({
    required String planId,
    required DateTime start,
    required DateTime end,
  }) async {
    await _scheduleSub?.cancel();
    _scheduleSub = _repo
        .watchSchedules(planId: planId, start: start, end: end)
        .listen(
          (list) => add(ScheduleStreamUpdated(list)),
          onError: (Object e) => add(ScheduleStreamFailed(e.toString())),
        );
  }

  Future<void> _onStreamUpdated(
    ScheduleStreamUpdated event,
    Emitter<ScheduleState> emit,
  ) async {
    final subjectIds = event.schedules.map((s) => s.subjectId).toSet();
    final topicIds = event.schedules.map((s) => s.topicId).toSet();
    final newSubjectIds = subjectIds.difference(_subjectNameCache.keys.toSet());
    final newTopicIds = topicIds.difference(_topicNameCache.keys.toSet());

    if (newSubjectIds.isNotEmpty) {
      _subjectNameCache.addAll(await _repo.fetchSubjectNames(newSubjectIds));
    }
    if (newTopicIds.isNotEmpty) {
      _topicNameCache.addAll(await _repo.fetchTopicNames(newTopicIds));
    }

    emit(
      state.copyWith(
        status: event.schedules.isEmpty
            ? ScheduleListStatus.empty
            : ScheduleListStatus.success,
        schedules: event.schedules,
        subjectNames: Map.of(_subjectNameCache),
        topicNames: Map.of(_topicNameCache),
      ),
    );
  }

  void _onStreamFailed(ScheduleStreamFailed event, Emitter<ScheduleState> emit) {
    emit(
      state.copyWith(
        status: ScheduleListStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onAddRequested(
    AddScheduleRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: ScheduleSubmissionStatus.submitting,
        clearError: true,
      ),
    );
    try {
      await _repo.addSchedule(
        planId: event.planId,
        subjectId: event.subjectId,
        topicId: event.topicId,
        scheduledDate: event.scheduledDate,
        startTime: event.startTime,
        plannedMinutes: event.plannedMinutes,
        priority: event.priority,
        reminderEnabled: event.reminderEnabled,
        reminderMinutesBefore: event.reminderMinutesBefore,
        notes: event.notes,
      );
      emit(
        state.copyWith(
          submissionStatus: ScheduleSubmissionStatus.success,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: ScheduleSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _scheduleSub?.cancel();
    return super.close();
  }
}
