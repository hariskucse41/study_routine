import 'package:equatable/equatable.dart';
import '../model/goals_summary.dart';

enum GoalsStatus { initial, loading, success, noPlan, error }

class GoalsState extends Equatable {
  final GoalsStatus status;
  final GoalsSummary? summary;
  final String? errorMessage;

  const GoalsState({
    this.status = GoalsStatus.initial,
    this.summary,
    this.errorMessage,
  });

  GoalsState copyWith({
    GoalsStatus? status,
    GoalsSummary? summary,
    String? errorMessage,
  }) => GoalsState(
    status: status ?? this.status,
    summary: summary ?? this.summary,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
