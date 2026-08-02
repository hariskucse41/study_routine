import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/study_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../study_plan/repository/study_plan_repository.dart';
import '../../study_session/repository/study_session_repository.dart';
import '../../subject/repository/subject_repository.dart';
import '../../test_result/repository/test_result_repository.dart';
import '../../topic/model/topic_aggregates.dart';
import '../../topic/model/topic_model.dart';
import '../../topic/repository/topic_repository.dart';
import '../model/overall_progress_data.dart';
import '../model/subject_analytics_data.dart';
import 'progress_analytics_event.dart';
import 'progress_analytics_state.dart';

/// No dedicated repository — reads directly from the existing
/// StudyPlanRepository/SubjectRepository/TopicRepository/
/// StudySessionRepository/TestResultRepository, same approach as GoalsBloc
/// in Phase 8.
class ProgressAnalyticsBloc
    extends Bloc<ProgressAnalyticsEvent, ProgressAnalyticsState> {
  final StudyPlanRepository _studyPlanRepo;
  final SubjectRepository _subjectRepo;
  final TopicRepository _topicRepo;
  final StudySessionRepository _studySessionRepo;
  final TestResultRepository _testResultRepo;

  ProgressAnalyticsBloc(
    this._studyPlanRepo,
    this._subjectRepo,
    this._topicRepo,
    this._studySessionRepo,
    this._testResultRepo,
  ) : super(const ProgressAnalyticsState()) {
    on<LoadOverallProgressRequested>(_onLoadOverall);
    on<LoadSubjectAnalyticsRequested>(_onLoadSubjectAnalytics);
    on<LoadWeakTopicsRequested>(_onLoadWeakTopics);
  }

  Future<void> _onLoadOverall(
    LoadOverallProgressRequested event,
    Emitter<ProgressAnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.loading));
    try {
      final plan = await _studyPlanRepo.fetchActivePlan();
      if (plan == null) {
        emit(state.copyWith(status: ProgressStatus.noPlan));
        return;
      }

      final subjects = await _subjectRepo.fetchSubjects(plan.id);
      final allTopics = await _topicRepo.fetchTopicsForPlan(plan.id);
      final overallAggregates = TopicAggregates.from(allTopics);

      final subjectProgress = subjects
          .map(
            (s) => SubjectProgressEntry(
              subject: s,
              progressPercent: TopicAggregates.from(
                allTopics.where((t) => t.subjectId == s.id).toList(),
              ).overallProgressPercent,
            ),
          )
          .toList();

      final today = localMidnight(DateTime.now());
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final minutesByDay = await _studySessionRepo.fetchMinutesByDay(
        planId: plan.id,
        windowStart: monday,
      );
      final weeklyHours = List.generate(
        7,
        (i) => (minutesByDay[monday.add(Duration(days: i))] ?? 0) / 60.0,
      );

      emit(
        state.copyWith(
          status: ProgressStatus.success,
          subjects: subjects,
          overallProgress: OverallProgressData(
            overallProgressPercent: overallAggregates.overallProgressPercent,
            subjectProgress: subjectProgress,
            weeklyHours: weeklyHours,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ProgressStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadSubjectAnalytics(
    LoadSubjectAnalyticsRequested event,
    Emitter<ProgressAnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.loading));
    try {
      final plan = await _studyPlanRepo.fetchActivePlan();
      if (plan == null) {
        emit(state.copyWith(status: ProgressStatus.noPlan));
        return;
      }

      final subjects = state.subjects.isNotEmpty
          ? state.subjects
          : await _subjectRepo.fetchSubjects(plan.id);
      final matches = subjects.where((s) => s.id == event.subjectId).toList();
      final subject = matches.isEmpty ? null : matches.first;
      if (subject == null) {
        emit(
          state.copyWith(
            status: ProgressStatus.error,
            errorMessage: 'Subject not found',
          ),
        );
        return;
      }

      final topics = await _topicRepo.watchTopicsForSubject(event.subjectId).first;

      emit(
        state.copyWith(
          status: ProgressStatus.success,
          subjects: subjects,
          subjectAnalytics: SubjectAnalyticsData(
            subject: subject,
            aggregates: TopicAggregates.from(topics),
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ProgressStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadWeakTopics(
    LoadWeakTopicsRequested event,
    Emitter<ProgressAnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.loading));
    try {
      final plan = await _studyPlanRepo.fetchActivePlan();
      if (plan == null) {
        emit(state.copyWith(status: ProgressStatus.noPlan));
        return;
      }

      final subjects = await _subjectRepo.fetchSubjects(plan.id);
      final allTopics = await _topicRepo.fetchTopicsForPlan(plan.id);

      final windowStart = localMidnight(
        DateTime.now().subtract(
          const Duration(days: recentTestResultsWindowDays),
        ),
      );
      final avgScoreBySubject = await _testResultRepo.fetchAverageScoreBySubject(
        planId: plan.id,
        since: windowStart,
      );
      final lowScoringSubjectIds = avgScoreBySubject.entries
          .where((e) => e.value < weakSubjectScoreThreshold)
          .map((e) => e.key)
          .toSet();

      bool isWeak(TopicModel t) =>
          t.confidenceScore < 3.0 ||
          (t.status == 'inProgress' && t.progressPercentage < 50) ||
          lowScoringSubjectIds.contains(t.subjectId);

      final weakTopics = allTopics.where(isWeak).toList()
        ..sort((a, b) => a.confidenceScore.compareTo(b.confidenceScore));

      emit(
        state.copyWith(
          status: ProgressStatus.success,
          subjects: subjects,
          weakTopics: weakTopics,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ProgressStatus.error, errorMessage: e.toString()));
    }
  }
}
