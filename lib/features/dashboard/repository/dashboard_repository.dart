import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/date_utils.dart';
import '../../study_plan/model/study_plan_model.dart';
import '../../study_plan/repository/study_plan_repository.dart';
import '../model/dashboard_summary.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StudyPlanRepository _studyPlanRepo;

  DashboardRepository(this._firestore, this._auth, this._studyPlanRepo);

  String get _uid => _auth.currentUser!.uid;

  /// Runs the combined queries needed for the Home Dashboard in one shot.
  /// Returns null if the user hasn't selected an active study plan yet.
  Future<DashboardSummary?> loadDashboard() async {
    final plan = await _studyPlanRepo.fetchActivePlan();
    if (plan == null) return null;

    final today = todayRange();

    final schedulesToday = await _firestore
        .collection('schedules')
        .where('userId', isEqualTo: _uid)
        .where('planId', isEqualTo: plan.id)
        .where('scheduledDate', isGreaterThanOrEqualTo: today.startTimestamp)
        .where('scheduledDate', isLessThan: today.endTimestamp)
        .get();
    final totalTasksToday = schedulesToday.docs.length;
    final completedTasksToday = schedulesToday.docs
        .where((d) => d.data()['status'] == 'completed')
        .length;

    // study_sessions only has a documented composite index on
    // (userId, startedAt) — not (userId, planId, startedAt) — so planId is
    // filtered client-side over the (small) per-day/window result set.
    final sessionsToday = await _firestore
        .collection('study_sessions')
        .where('userId', isEqualTo: _uid)
        .where('startedAt', isGreaterThanOrEqualTo: today.startTimestamp)
        .where('startedAt', isLessThan: today.endTimestamp)
        .get();
    final studyMinutesToday = sessionsToday.docs
        .where((d) => d.data()['planId'] == plan.id)
        .fold<int>(
          0,
          (total, d) => total + ((d.data()['actualMinutes'] ?? 0) as int),
        );

    final dueRevisions = await _firestore
        .collection('revisions')
        .where('userId', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .where('scheduledDate', isLessThan: today.endTimestamp)
        .get();
    final dueRevisionsCount = dueRevisions.docs.length;

    final currentStreakDays = await _computeStreak(plan);

    return DashboardSummary(
      plan: plan,
      totalTasksToday: totalTasksToday,
      completedTasksToday: completedTasksToday,
      studyMinutesToday: studyMinutesToday,
      dueRevisionsCount: dueRevisionsCount,
      currentStreakDays: currentStreakDays,
    );
  }

  /// Counts consecutive days (ending today, or yesterday if today isn't
  /// finished yet) whose total study_sessions minutes met the plan's
  /// dailyTargetMinutes.
  Future<int> _computeStreak(StudyPlanModel plan) async {
    const windowDays = 30;
    final windowStart = localMidnight(
      DateTime.now().subtract(const Duration(days: windowDays)),
    );

    final recentSessions = await _firestore
        .collection('study_sessions')
        .where('userId', isEqualTo: _uid)
        .where(
          'startedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(windowStart),
        )
        .get();

    final minutesByDay = <DateTime, int>{};
    for (final doc in recentSessions.docs) {
      final data = doc.data();
      if (data['planId'] != plan.id) continue;
      final startedAt = (data['startedAt'] as Timestamp?)?.toDate();
      if (startedAt == null) continue;
      final day = localMidnight(startedAt);
      final minutes = (data['actualMinutes'] ?? 0) as int;
      minutesByDay[day] = (minutesByDay[day] ?? 0) + minutes;
    }

    final today = localMidnight(DateTime.now());
    bool metTarget(DateTime day) =>
        (minutesByDay[day] ?? 0) >= plan.dailyTargetMinutes;

    var streak = 0;
    if (metTarget(today)) streak++;

    var cursor = today.subtract(const Duration(days: 1));
    while (metTarget(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
