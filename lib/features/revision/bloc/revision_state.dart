import 'package:equatable/equatable.dart';
import '../model/revision_model.dart';

enum RevisionListStatus { initial, loading, success, empty, error }

enum RevisionActionStatus { idle, submitting, success, failure }

class RevisionState extends Equatable {
  final RevisionListStatus status;
  final List<RevisionModel> revisions;
  final Map<String, String> subjectNames;
  final Map<String, String> topicNames;
  final RevisionActionStatus actionStatus;
  final String? errorMessage;

  const RevisionState({
    this.status = RevisionListStatus.initial,
    this.revisions = const [],
    this.subjectNames = const {},
    this.topicNames = const {},
    this.actionStatus = RevisionActionStatus.idle,
    this.errorMessage,
  });

  RevisionState copyWith({
    RevisionListStatus? status,
    List<RevisionModel>? revisions,
    Map<String, String>? subjectNames,
    Map<String, String>? topicNames,
    RevisionActionStatus? actionStatus,
    String? errorMessage,
    bool clearError = false,
  }) => RevisionState(
    status: status ?? this.status,
    revisions: revisions ?? this.revisions,
    subjectNames: subjectNames ?? this.subjectNames,
    topicNames: topicNames ?? this.topicNames,
    actionStatus: actionStatus ?? this.actionStatus,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    status,
    revisions,
    subjectNames,
    topicNames,
    actionStatus,
    errorMessage,
  ];
}
