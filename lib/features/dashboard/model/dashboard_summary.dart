import '../../study_plan/model/study_plan_model.dart';

/// A computed aggregate for the Home Dashboard — not a Firestore document
/// itself, so unlike the other feature models there's no fromFirestore/
/// toFirestore; DashboardRepository builds this from several collections.
class DashboardSummary {
  final StudyPlanModel plan;
  final int totalTasksToday;
  final int completedTasksToday;
  final int studyMinutesToday;
  final int dueRevisionsCount;
  final int currentStreakDays;

  const DashboardSummary({
    required this.plan,
    required this.totalTasksToday,
    required this.completedTasksToday,
    required this.studyMinutesToday,
    required this.dueRevisionsCount,
    required this.currentStreakDays,
  });

  int get remainingTasksToday =>
      (totalTasksToday - completedTasksToday).clamp(0, totalTasksToday);

  double get dailyProgressRatio {
    if (plan.dailyTargetMinutes <= 0) return 0;
    return (studyMinutesToday / plan.dailyTargetMinutes).clamp(0.0, 1.0);
  }
}
