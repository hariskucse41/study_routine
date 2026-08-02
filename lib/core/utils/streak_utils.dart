import 'date_utils.dart';

/// Consecutive days (ending today, or yesterday if today isn't finished
/// yet) whose total minutes met [targetMinutes]. Shared by DashboardRepository
/// (Home) and GoalsBloc (screen 26) so the "current streak" means the same
/// thing everywhere it's shown.
int computeStreakDays(Map<DateTime, int> minutesByDay, int targetMinutes) {
  bool metTarget(DateTime day) => (minutesByDay[day] ?? 0) >= targetMinutes;

  final today = localMidnight(DateTime.now());
  var streak = 0;
  if (metTarget(today)) streak++;

  var cursor = today.subtract(const Duration(days: 1));
  while (metTarget(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Monday..Sunday status for the current calendar week: true = met target,
/// false = target missed (day already happened), null = day hasn't
/// happened yet.
List<bool?> computeWeekMetStatus(
  Map<DateTime, int> minutesByDay,
  int targetMinutes,
) {
  final today = localMidnight(DateTime.now());
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return List.generate(7, (i) {
    final day = monday.add(Duration(days: i));
    if (day.isAfter(today)) return null;
    return (minutesByDay[day] ?? 0) >= targetMinutes;
  });
}
