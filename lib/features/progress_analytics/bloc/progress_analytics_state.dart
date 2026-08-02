import 'package:equatable/equatable.dart';

import '../../subject/model/subject_model.dart';
import '../../topic/model/topic_model.dart';
import '../model/overall_progress_data.dart';
import '../model/subject_analytics_data.dart';

enum ProgressStatus { initial, loading, success, noPlan, error }

class ProgressAnalyticsState extends Equatable {
  final ProgressStatus status;
  final List<SubjectModel> subjects;
  final OverallProgressData? overallProgress;
  final SubjectAnalyticsData? subjectAnalytics;
  final List<TopicModel> weakTopics;
  final String? errorMessage;

  const ProgressAnalyticsState({
    this.status = ProgressStatus.initial,
    this.subjects = const [],
    this.overallProgress,
    this.subjectAnalytics,
    this.weakTopics = const [],
    this.errorMessage,
  });

  ProgressAnalyticsState copyWith({
    ProgressStatus? status,
    List<SubjectModel>? subjects,
    OverallProgressData? overallProgress,
    SubjectAnalyticsData? subjectAnalytics,
    List<TopicModel>? weakTopics,
    String? errorMessage,
  }) => ProgressAnalyticsState(
    status: status ?? this.status,
    subjects: subjects ?? this.subjects,
    overallProgress: overallProgress ?? this.overallProgress,
    subjectAnalytics: subjectAnalytics ?? this.subjectAnalytics,
    weakTopics: weakTopics ?? this.weakTopics,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    subjects,
    overallProgress,
    subjectAnalytics,
    weakTopics,
    errorMessage,
  ];
}
