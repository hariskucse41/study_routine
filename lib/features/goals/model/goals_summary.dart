/// A computed aggregate for the Goals screen — not a Firestore document
/// itself (see §1.2 of the implementation guide: daily_goals is computed
/// live for v1 rather than a synced snapshot collection).
class GoalsSummary {
  final int studyMinutesToday;
  final int studyMinutesTarget;
  final int topicsCompletedToday;
  final int topicsTarget;
  final int revisionsCompletedToday;
  final int revisionsTarget;
  final int mcqsSolvedToday;
  final int mcqsTarget;

  /// Monday..Sunday, null = day hasn't happened yet this week.
  final List<bool?> weekMetStatus;
  final int currentStreakDays;

  const GoalsSummary({
    required this.studyMinutesToday,
    required this.studyMinutesTarget,
    required this.topicsCompletedToday,
    required this.topicsTarget,
    required this.revisionsCompletedToday,
    required this.revisionsTarget,
    required this.mcqsSolvedToday,
    required this.mcqsTarget,
    required this.weekMetStatus,
    required this.currentStreakDays,
  });
}
