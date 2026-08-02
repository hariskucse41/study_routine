import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/study_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/streak_utils.dart';
import '../../revision/repository/revision_repository.dart';
import '../../study_plan/repository/study_plan_repository.dart';
import '../../study_session/repository/study_session_repository.dart';
import '../../topic/repository/topic_repository.dart';
import '../model/goals_summary.dart';
import 'goals_event.dart';
import 'goals_state.dart';

/// No dedicated GoalsRepository — this reads directly from the existing
/// StudyPlanRepository/StudySessionRepository/TopicRepository/
/// RevisionRepository, per the Phase 8 instructions (goal progress is
/// computed live, no new Firestore writes).
class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final StudyPlanRepository _studyPlanRepo;
  final StudySessionRepository _studySessionRepo;
  final TopicRepository _topicRepo;
  final RevisionRepository _revisionRepo;

  GoalsBloc(
    this._studyPlanRepo,
    this._studySessionRepo,
    this._topicRepo,
    this._revisionRepo,
  ) : super(const GoalsState()) {
    on<LoadGoalsRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    LoadGoalsRequested event,
    Emitter<GoalsState> emit,
  ) async {
    emit(state.copyWith(status: GoalsStatus.loading));
    try {
      final plan = await _studyPlanRepo.fetchActivePlan();
      if (plan == null) {
        emit(state.copyWith(status: GoalsStatus.noPlan));
        return;
      }

      final today = todayRange();

      final studyMinutesToday = await _studySessionRepo
          .fetchTotalMinutesForRange(
            planId: plan.id,
            start: today.start,
            end: today.end,
          );
      final topicsCompletedToday = await _topicRepo.countCompletedInRange(
        planId: plan.id,
        start: today.start,
        end: today.end,
      );
      final revisionsCompletedToday = await _revisionRepo
          .countCompletedInRange(
            planId: plan.id,
            start: today.start,
            end: today.end,
          );

      const windowDays = 30;
      final windowStart = localMidnight(
        DateTime.now().subtract(const Duration(days: windowDays)),
      );
      final minutesByDay = await _studySessionRepo.fetchMinutesByDay(
        planId: plan.id,
        windowStart: windowStart,
      );

      emit(
        state.copyWith(
          status: GoalsStatus.success,
          summary: GoalsSummary(
            studyMinutesToday: studyMinutesToday,
            studyMinutesTarget: plan.dailyTargetMinutes,
            topicsCompletedToday: topicsCompletedToday,
            topicsTarget: defaultDailyTopicsTarget,
            revisionsCompletedToday: revisionsCompletedToday,
            revisionsTarget: defaultDailyRevisionsTarget,
            // No test/MCQ-tracking feature exists yet (Phase 10) — shown
            // honestly at zero rather than fabricated.
            mcqsSolvedToday: 0,
            mcqsTarget: defaultDailyMcqsTarget,
            weekMetStatus: computeWeekMetStatus(
              minutesByDay,
              plan.dailyTargetMinutes,
            ),
            currentStreakDays: computeStreakDays(
              minutesByDay,
              plan.dailyTargetMinutes,
            ),
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: GoalsStatus.error, errorMessage: e.toString()));
    }
  }
}
