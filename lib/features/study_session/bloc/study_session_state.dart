import 'package:equatable/equatable.dart';

enum StudySessionPhase { idle, starting, active, paused, ending, completed, error }

class StudySessionState extends Equatable {
  final StudySessionPhase phase;
  final String? sessionId;
  final String? planId;
  final String? subjectId;
  final String? topicId;
  final String subjectName;
  final String topicName;
  final String? scheduleId;
  final int plannedMinutes;
  final DateTime? startedAt;
  final int actualMinutes;
  final String? errorMessage;

  const StudySessionState({
    this.phase = StudySessionPhase.idle,
    this.sessionId,
    this.planId,
    this.subjectId,
    this.topicId,
    this.subjectName = '',
    this.topicName = '',
    this.scheduleId,
    this.plannedMinutes = 0,
    this.startedAt,
    this.actualMinutes = 0,
    this.errorMessage,
  });

  StudySessionState copyWith({
    StudySessionPhase? phase,
    String? sessionId,
    String? planId,
    String? subjectId,
    String? topicId,
    String? subjectName,
    String? topicName,
    String? scheduleId,
    int? plannedMinutes,
    DateTime? startedAt,
    int? actualMinutes,
    String? errorMessage,
    bool clearError = false,
  }) => StudySessionState(
    phase: phase ?? this.phase,
    sessionId: sessionId ?? this.sessionId,
    planId: planId ?? this.planId,
    subjectId: subjectId ?? this.subjectId,
    topicId: topicId ?? this.topicId,
    subjectName: subjectName ?? this.subjectName,
    topicName: topicName ?? this.topicName,
    scheduleId: scheduleId ?? this.scheduleId,
    plannedMinutes: plannedMinutes ?? this.plannedMinutes,
    startedAt: startedAt ?? this.startedAt,
    actualMinutes: actualMinutes ?? this.actualMinutes,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    phase,
    sessionId,
    planId,
    subjectId,
    topicId,
    subjectName,
    topicName,
    scheduleId,
    plannedMinutes,
    startedAt,
    actualMinutes,
    errorMessage,
  ];
}
