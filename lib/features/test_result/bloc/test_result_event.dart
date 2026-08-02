import 'package:equatable/equatable.dart';
import '../model/test_result_model.dart';

sealed class TestResultEvent extends Equatable {
  const TestResultEvent();

  @override
  List<Object?> get props => [];
}

class WatchTestResultsRequested extends TestResultEvent {
  final String planId;
  const WatchTestResultsRequested(this.planId);
  @override
  List<Object?> get props => [planId];
}

/// Dispatched internally by TestResultBloc in response to the Firestore
/// stream — not intended to be added by the UI.
class TestResultsStreamUpdated extends TestResultEvent {
  final List<TestResultModel> results;
  const TestResultsStreamUpdated(this.results);
  @override
  List<Object?> get props => [results];
}

class TestResultStreamFailed extends TestResultEvent {
  final String message;
  const TestResultStreamFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class AddTestResultRequested extends TestResultEvent {
  final String planId;
  final String subjectId;
  final String title;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final int durationMinutes;
  final DateTime testDate;
  final String? notes;

  const AddTestResultRequested({
    required this.planId,
    required this.subjectId,
    required this.title,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.durationMinutes,
    required this.testDate,
    this.notes,
  });

  @override
  List<Object?> get props => [
    planId,
    subjectId,
    title,
    totalQuestions,
    correctAnswers,
    wrongAnswers,
    skippedAnswers,
    durationMinutes,
    testDate,
    notes,
  ];
}
