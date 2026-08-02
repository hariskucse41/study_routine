import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/date_utils.dart';
import '../../study_plan/model/study_plan_model.dart';
import '../../study_plan/repository/study_plan_repository.dart';
import '../../study_session/repository/study_session_repository.dart';
import '../model/dashboard_summary.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StudyPlanRepository _studyPlanRepo;
  final StudySessionRepository _studySessionRepo;

  DashboardRepository(
    this._firestore,
    this._auth,
    this._studyPlanRepo,
    this._studySessionRepo,
  );

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

    final studyMinutesToday = await _studySessionRepo.fetchTotalMinutesForRange(
      planId: plan.id,
      start: today.start,
      end: today.end,
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

    final minutesByDay = await _studySessionRepo.fetchMinutesByDay(
      planId: plan.id,
      windowStart: windowStart,
    );

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
