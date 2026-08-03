import 'package:flutter_bloc/flutter_bloc.dart';

import '../../schedule/repository/schedule_repository.dart';
import '../../subject/repository/subject_repository.dart';
import '../../topic/repository/topic_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

/// No dedicated repository — reads through the already-registered
/// Topic/Schedule/Subject repositories with their existing fetch/watch
/// methods (same rationale as GoalsBloc/ProgressAnalyticsBloc), then
/// filters/sorts entirely client-side in [SearchState.results].
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final TopicRepository _topicRepository;
  final ScheduleRepository _scheduleRepository;
  final SubjectRepository _subjectRepository;

  SearchBloc(
    this._topicRepository,
    this._scheduleRepository,
    this._subjectRepository,
  ) : super(const SearchState()) {
    on<SearchDataRequested>(_onDataRequested);
    on<SearchQueryChanged>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
    on<SearchSubjectFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          subjectFilter: event.subjectId,
          clearSubjectFilter: event.subjectId == null,
        ),
      ),
    );
    on<SearchStatusFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          statusFilter: event.status,
          clearStatusFilter: event.status == null,
        ),
      ),
    );
    on<SearchDifficultyFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          difficultyFilter: event.difficulty,
          clearDifficultyFilter: event.difficulty == null,
        ),
      ),
    );
    on<SearchPriorityFilterChanged>(
      (event, emit) => emit(
        state.copyWith(
          priorityFilter: event.priority,
          clearPriorityFilter: event.priority == null,
        ),
      ),
    );
    on<SearchSortChanged>(
      (event, emit) => emit(state.copyWith(sort: event.sort)),
    );
  }

  Future<void> _onDataRequested(
    SearchDataRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final topicsFuture = _topicRepository.fetchTopicsForPlan(event.planId);
      final subjectsFuture = _subjectRepository.fetchSubjects(event.planId);
      final schedulesFuture = _scheduleRepository
          .watchSchedules(
            planId: event.planId,
            start: DateTime(2000),
            end: DateTime(2100),
          )
          .first;

      final topics = await topicsFuture;
      final subjects = await subjectsFuture;
      final schedules = await schedulesFuture;

      emit(
        state.copyWith(
          status: SearchStatus.success,
          allTopics: topics,
          subjects: subjects,
          schedules: schedules,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: SearchStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
