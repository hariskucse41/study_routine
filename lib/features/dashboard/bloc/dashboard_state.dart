import 'package:equatable/equatable.dart';
import '../model/dashboard_summary.dart';

enum DashboardStatus { initial, loading, success, noPlan, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardSummary? summary;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummary? summary,
    String? errorMessage,
  }) => DashboardState(
    status: status ?? this.status,
    summary: summary ?? this.summary,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
