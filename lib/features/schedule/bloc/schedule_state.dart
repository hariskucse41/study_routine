import 'package:equatable/equatable.dart';
import '../model/schedule_model.dart';

enum ScheduleListStatus { initial, loading, success, empty, error }

enum ScheduleSubmissionStatus { idle, submitting, success, failure }

class ScheduleState extends Equatable {
  final ScheduleListStatus status;
  final List<ScheduleModel> schedules;
  final Map<String, String> subjectNames;
  final Map<String, String> topicNames;
  final ScheduleSubmissionStatus submissionStatus;
  final String? errorMessage;

  const ScheduleState({
    this.status = ScheduleListStatus.initial,
    this.schedules = const [],
    this.subjectNames = const {},
    this.topicNames = const {},
    this.submissionStatus = ScheduleSubmissionStatus.idle,
    this.errorMessage,
  });

  ScheduleState copyWith({
    ScheduleListStatus? status,
    List<ScheduleModel>? schedules,
    Map<String, String>? subjectNames,
    Map<String, String>? topicNames,
    ScheduleSubmissionStatus? submissionStatus,
    String? errorMessage,
    bool clearError = false,
  }) => ScheduleState(
    status: status ?? this.status,
    schedules: schedules ?? this.schedules,
    subjectNames: subjectNames ?? this.subjectNames,
    topicNames: topicNames ?? this.topicNames,
    submissionStatus: submissionStatus ?? this.submissionStatus,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    status,
    schedules,
    subjectNames,
    topicNames,
    submissionStatus,
    errorMessage,
  ];
}
