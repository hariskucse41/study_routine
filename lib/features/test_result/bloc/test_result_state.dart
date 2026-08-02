import 'package:equatable/equatable.dart';
import '../model/test_result_model.dart';

enum TestResultListStatus { initial, loading, success, empty, error }

enum TestResultSubmissionStatus { idle, submitting, success, failure }

class TestResultState extends Equatable {
  final TestResultListStatus status;
  final List<TestResultModel> results;
  final Map<String, String> subjectNames;
  final TestResultSubmissionStatus submissionStatus;
  final String? errorMessage;

  const TestResultState({
    this.status = TestResultListStatus.initial,
    this.results = const [],
    this.subjectNames = const {},
    this.submissionStatus = TestResultSubmissionStatus.idle,
    this.errorMessage,
  });

  TestResultState copyWith({
    TestResultListStatus? status,
    List<TestResultModel>? results,
    Map<String, String>? subjectNames,
    TestResultSubmissionStatus? submissionStatus,
    String? errorMessage,
    bool clearError = false,
  }) => TestResultState(
    status: status ?? this.status,
    results: results ?? this.results,
    subjectNames: subjectNames ?? this.subjectNames,
    submissionStatus: submissionStatus ?? this.submissionStatus,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    status,
    results,
    subjectNames,
    submissionStatus,
    errorMessage,
  ];
}
