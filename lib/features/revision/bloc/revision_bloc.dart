import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/revision_repository.dart';
import 'revision_event.dart';
import 'revision_state.dart';

class RevisionBloc extends Bloc<RevisionEvent, RevisionState> {
  final RevisionRepository _repo;
  StreamSubscription? _revisionsSub;
  final Map<String, String> _subjectNameCache = {};
  final Map<String, String> _topicNameCache = {};

  String? _planId;
  String? _subjectId;
  String? _topicId;

  RevisionBloc(this._repo) : super(const RevisionState()) {
    on<WatchDueRevisionsRequested>(_onWatchDueRequested);
    on<WatchRevisionHistoryRequested>(_onWatchHistoryRequested);
    on<RevisionsStreamUpdated>(_onStreamUpdated);
    on<RevisionStreamFailed>(_onStreamFailed);
    on<MarkAllCompleteRequested>(_onMarkAllComplete);
    on<RescheduleRevisionRequested>(_onReschedule);
    on<LogNextRevisionRequested>(_onLogNextRevision);
  }

  Future<void> _onWatchDueRequested(
    WatchDueRevisionsRequested event,
    Emitter<RevisionState> emit,
  ) async {
    emit(state.copyWith(status: RevisionListStatus.loading));
    await _revisionsSub?.cancel();
    _revisionsSub = _repo.watchDueRevisions().listen(
      (list) => add(RevisionsStreamUpdated(list)),
      onError: (Object e) => add(RevisionStreamFailed(e.toString())),
    );
  }

  Future<void> _onWatchHistoryRequested(
    WatchRevisionHistoryRequested event,
    Emitter<RevisionState> emit,
  ) async {
    _planId = event.planId;
    _subjectId = event.subjectId;
    _topicId = event.topicId;
    emit(state.copyWith(status: RevisionListStatus.loading));
    await _revisionsSub?.cancel();
    _revisionsSub = _repo.watchRevisionHistory(event.topicId).listen(
      (list) => add(RevisionsStreamUpdated(list)),
      onError: (Object e) => add(RevisionStreamFailed(e.toString())),
    );
  }

  Future<void> _onStreamUpdated(
    RevisionsStreamUpdated event,
    Emitter<RevisionState> emit,
  ) async {
    final subjectIds = event.revisions.map((r) => r.subjectId).toSet();
    final topicIds = event.revisions.map((r) => r.topicId).toSet();
    final newSubjectIds = subjectIds.difference(_subjectNameCache.keys.toSet());
    final newTopicIds = topicIds.difference(_topicNameCache.keys.toSet());

    if (newSubjectIds.isNotEmpty) {
      _subjectNameCache.addAll(await _repo.fetchSubjectNames(newSubjectIds));
    }
    if (newTopicIds.isNotEmpty) {
      _topicNameCache.addAll(await _repo.fetchTopicNames(newTopicIds));
    }

    emit(
      state.copyWith(
        status: event.revisions.isEmpty
            ? RevisionListStatus.empty
            : RevisionListStatus.success,
        revisions: event.revisions,
        subjectNames: Map.of(_subjectNameCache),
        topicNames: Map.of(_topicNameCache),
      ),
    );
  }

  void _onStreamFailed(RevisionStreamFailed event, Emitter<RevisionState> emit) {
    emit(
      state.copyWith(
        status: RevisionListStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onMarkAllComplete(
    MarkAllCompleteRequested event,
    Emitter<RevisionState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: RevisionActionStatus.submitting,
        clearError: true,
      ),
    );
    try {
      await _repo.markAllComplete(state.revisions.map((r) => r.id).toList());
      emit(state.copyWith(actionStatus: RevisionActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: RevisionActionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onReschedule(
    RescheduleRevisionRequested event,
    Emitter<RevisionState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: RevisionActionStatus.submitting,
        clearError: true,
      ),
    );
    try {
      await _repo.reschedule(
        revisionId: event.revisionId,
        newDate: event.newDate,
      );
      emit(state.copyWith(actionStatus: RevisionActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: RevisionActionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLogNextRevision(
    LogNextRevisionRequested event,
    Emitter<RevisionState> emit,
  ) async {
    final planId = _planId;
    final subjectId = _subjectId;
    final topicId = _topicId;
    if (planId == null || subjectId == null || topicId == null) return;

    emit(
      state.copyWith(
        actionStatus: RevisionActionStatus.submitting,
        clearError: true,
      ),
    );
    try {
      final nextNumber = state.revisions.fold<int>(
            0,
            (max, r) => r.revisionNumber > max ? r.revisionNumber : max,
          ) +
          1;
      await _repo.logNextRevision(
        planId: planId,
        subjectId: subjectId,
        topicId: topicId,
        revisionNumber: nextNumber,
      );
      emit(state.copyWith(actionStatus: RevisionActionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          actionStatus: RevisionActionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _revisionsSub?.cancel();
    return super.close();
  }
}
