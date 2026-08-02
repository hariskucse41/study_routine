import 'package:equatable/equatable.dart';
import '../model/schedule_model.dart';

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class WatchScheduleRequested extends ScheduleEvent {
  final String planId;
  final DateTime date;
  const WatchScheduleRequested({required this.planId, required this.date});
  @override
  List<Object?> get props => [planId, date];
}

class WatchScheduleRangeRequested extends ScheduleEvent {
  final String planId;
  final DateTime start;
  final DateTime end;
  const WatchScheduleRangeRequested({
    required this.planId,
    required this.start,
    required this.end,
  });
  @override
  List<Object?> get props => [planId, start, end];
}

/// Dispatched internally by ScheduleBloc in response to the Firestore
/// stream — not intended to be added by the UI.
class ScheduleStreamUpdated extends ScheduleEvent {
  final List<ScheduleModel> schedules;
  const ScheduleStreamUpdated(this.schedules);
  @override
  List<Object?> get props => [schedules];
}

class ScheduleStreamFailed extends ScheduleEvent {
  final String message;
  const ScheduleStreamFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class AddScheduleRequested extends ScheduleEvent {
  final String planId;
  final String subjectId;
  final String topicId;
  final DateTime scheduledDate;
  final String startTime;
  final int plannedMinutes;
  final String priority;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final String? notes;

  const AddScheduleRequested({
    required this.planId,
    required this.subjectId,
    required this.topicId,
    required this.scheduledDate,
    required this.startTime,
    required this.plannedMinutes,
    required this.priority,
    required this.reminderEnabled,
    required this.reminderMinutesBefore,
    this.notes,
  });

  @override
  List<Object?> get props => [
    planId,
    subjectId,
    topicId,
    scheduledDate,
    startTime,
    plannedMinutes,
    priority,
    reminderEnabled,
    reminderMinutesBefore,
    notes,
  ];
}
