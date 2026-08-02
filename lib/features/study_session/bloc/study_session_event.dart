import 'package:equatable/equatable.dart';

sealed class StudySessionEvent extends Equatable {
  const StudySessionEvent();

  @override
  List<Object?> get props => [];
}

class StartSessionRequested extends StudySessionEvent {
  final String planId;
  final String subjectId;
  final String topicId;
  final String subjectName;
  final String topicName;
  final String? scheduleId;
  final int plannedMinutes;

  const StartSessionRequested({
    required this.planId,
    required this.subjectId,
    required this.topicId,
    required this.subjectName,
    required this.topicName,
    this.scheduleId,
    required this.plannedMinutes,
  });

  @override
  List<Object?> get props => [
    planId,
    subjectId,
    topicId,
    subjectName,
    topicName,
    scheduleId,
    plannedMinutes,
  ];
}

/// Toggles pause/resume — the spec names only Start/Pause/End (no separate
/// Resume), so this single event flips the Bloc's internal paused flag
/// both ways.
class PauseSessionRequested extends StudySessionEvent {
  const PauseSessionRequested();
}

class EndSessionRequested extends StudySessionEvent {
  const EndSessionRequested();
}
