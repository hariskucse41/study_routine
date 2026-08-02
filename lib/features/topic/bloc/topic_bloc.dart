import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/topic_repository.dart';
import 'topic_event.dart';
import 'topic_state.dart';

class TopicBloc extends Bloc<TopicEvent, TopicState> {
  final TopicRepository _repo;
  StreamSubscription? _topicsSub;
  String? _subjectId;

  TopicBloc(this._repo) : super(const TopicState()) {
    on<WatchTopicsRequested>(_onWatchRequested);
    on<TopicsStreamUpdated>(_onStreamUpdated);
    on<TopicStreamFailed>(_onStreamFailed);
    on<AddTopicRequested>(_onAddRequested);
    on<UpdateTopicProgressRequested>(_onUpdateProgressRequested);
  }

  Future<void> _onWatchRequested(
    WatchTopicsRequested event,
    Emitter<TopicState> emit,
  ) async {
    _subjectId = event.subjectId;
    emit(state.copyWith(status: TopicListStatus.loading));
    await _topicsSub?.cancel();
    _topicsSub = _repo.watchTopicsForSubject(event.subjectId).listen(
      (list) => add(TopicsStreamUpdated(list)),
      onError: (Object e) => add(TopicStreamFailed(e.toString())),
    );
  }

  void _onStreamUpdated(TopicsStreamUpdated event, Emitter<TopicState> emit) {
    emit(
      state.copyWith(
        status: event.topics.isEmpty
            ? TopicListStatus.empty
            : TopicListStatus.success,
        topics: event.topics,
      ),
    );
  }

  void _onStreamFailed(TopicStreamFailed event, Emitter<TopicState> emit) {
    emit(
      state.copyWith(status: TopicListStatus.error, errorMessage: event.message),
    );
  }

  Future<void> _onAddRequested(
    AddTopicRequested event,
    Emitter<TopicState> emit,
  ) async {
    if (_subjectId == null) return;
    emit(
      state.copyWith(
        submissionStatus: TopicSubmissionStatus.submitting,
        clearError: true,
      ),
    );
    try {
      final siblingCount = state.topics
          .where((t) => t.parentTopicId == event.parentTopicId)
          .length;
      await _repo.addTopic(
        subjectId: _subjectId!,
        parentTopicId: event.parentTopicId,
        title: event.title,
        description: event.description,
        difficulty: event.difficulty,
        estimatedMinutes: event.estimatedMinutes,
        order: siblingCount,
      );
      emit(
        state.copyWith(
          submissionStatus: TopicSubmissionStatus.success,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: TopicSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Failure here doesn't flip [TopicState.status] either — same reasoning
  /// as [_onAddRequested]: this is a transient action against whichever
  /// list/detail is already on screen, not a reason to blow it away.
  Future<void> _onUpdateProgressRequested(
    UpdateTopicProgressRequested event,
    Emitter<TopicState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: TopicSubmissionStatus.submitting,
        clearError: true,
      ),
    );
    try {
      await _repo.updateTopicProgress(
        topicId: event.topicId,
        sessionId: event.sessionId,
        progressPercentage: event.progressPercentage,
        status: event.status,
        confidenceScore: event.confidenceScore,
        notes: event.notes,
      );
      emit(
        state.copyWith(
          submissionStatus: TopicSubmissionStatus.success,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: TopicSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _topicsSub?.cancel();
    return super.close();
  }
}
