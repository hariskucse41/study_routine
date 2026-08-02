import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/test_result_repository.dart';
import 'test_result_event.dart';
import 'test_result_state.dart';

class TestResultBloc extends Bloc<TestResultEvent, TestResultState> {
  final TestResultRepository _repo;
  StreamSubscription? _resultsSub;
  final Map<String, String> _subjectNameCache = {};

  TestResultBloc(this._repo) : super(const TestResultState()) {
    on<WatchTestResultsRequested>(_onWatchRequested);
    on<TestResultsStreamUpdated>(_onStreamUpdated);
    on<TestResultStreamFailed>(_onStreamFailed);
    on<AddTestResultRequested>(_onAddRequested);
  }

  Future<void> _onWatchRequested(
    WatchTestResultsRequested event,
    Emitter<TestResultState> emit,
  ) async {
    emit(state.copyWith(status: TestResultListStatus.loading));
    await _resultsSub?.cancel();
    _resultsSub = _repo.watchTestResults(event.planId).listen(
      (list) => add(TestResultsStreamUpdated(list)),
      onError: (Object e) => add(TestResultStreamFailed(e.toString())),
    );
  }

  Future<void> _onStreamUpdated(
    TestResultsStreamUpdated event,
    Emitter<TestResultState> emit,
  ) async {
    final subjectIds = event.results.map((r) => r.subjectId).toSet();
    final newSubjectIds = subjectIds.difference(_subjectNameCache.keys.toSet());
    if (newSubjectIds.isNotEmpty) {
      _subjectNameCache.addAll(await _repo.fetchSubjectNames(newSubjectIds));
    }

    emit(
      state.copyWith(
        status: event.results.isEmpty
            ? TestResultListStatus.empty
            : TestResultListStatus.success,
        results: event.results,
        subjectNames: Map.of(_subjectNameCache),
      ),
    );
  }

  void _onStreamFailed(
    TestResultStreamFailed event,
    Emitter<TestResultState> emit,
  ) {
    emit(
      state.copyWith(
        status: TestResultListStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onAddRequested(
    AddTestResultRequested event,
    Emitter<TestResultState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: TestResultSubmissionStatus.submitting,
        clearError: true,
      ),
    );
    try {
      await _repo.addTestResult(
        planId: event.planId,
        subjectId: event.subjectId,
        title: event.title,
        totalQuestions: event.totalQuestions,
        correctAnswers: event.correctAnswers,
        wrongAnswers: event.wrongAnswers,
        skippedAnswers: event.skippedAnswers,
        durationMinutes: event.durationMinutes,
        testDate: event.testDate,
        notes: event.notes,
      );
      emit(
        state.copyWith(
          submissionStatus: TestResultSubmissionStatus.success,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: TestResultSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _resultsSub?.cancel();
    return super.close();
  }
}
