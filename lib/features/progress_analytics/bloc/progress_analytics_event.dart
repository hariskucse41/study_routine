import 'package:equatable/equatable.dart';

sealed class ProgressAnalyticsEvent extends Equatable {
  const ProgressAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadOverallProgressRequested extends ProgressAnalyticsEvent {
  const LoadOverallProgressRequested();
}

class LoadSubjectAnalyticsRequested extends ProgressAnalyticsEvent {
  final String subjectId;
  const LoadSubjectAnalyticsRequested(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class LoadWeakTopicsRequested extends ProgressAnalyticsEvent {
  const LoadWeakTopicsRequested();
}
