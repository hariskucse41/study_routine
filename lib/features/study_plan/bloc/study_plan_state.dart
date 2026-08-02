import 'package:equatable/equatable.dart';
import '../model/study_plan_model.dart';

enum StudyPlanSubmissionStatus { idle, submitting, success, failure }

class StudyPlanState extends Equatable {
  final StudyPlanSubmissionStatus status;
  final StudyPlanModel? createdPlan;
  final String? errorMessage;

  const StudyPlanState({
    this.status = StudyPlanSubmissionStatus.idle,
    this.createdPlan,
    this.errorMessage,
  });

  StudyPlanState copyWith({
    StudyPlanSubmissionStatus? status,
    StudyPlanModel? createdPlan,
    String? errorMessage,
    bool clearError = false,
  }) => StudyPlanState(
    status: status ?? this.status,
    createdPlan: createdPlan ?? this.createdPlan,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, createdPlan, errorMessage];
}
