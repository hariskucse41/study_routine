import 'package:equatable/equatable.dart';
import '../model/topic_model.dart';

/// Bloc-level list status. Named distinctly from the topic document's own
/// `status` field (notStarted/inProgress/completed/revisionNeeded/mastered,
/// see §6 of the implementation guide) to avoid a naming collision.
enum TopicListStatus { initial, loading, success, empty, error }

enum TopicSubmissionStatus { idle, submitting, success, failure }

class TopicState extends Equatable {
  final TopicListStatus status;
  final List<TopicModel> topics;
  final TopicSubmissionStatus submissionStatus;
  final String? errorMessage;

  const TopicState({
    this.status = TopicListStatus.initial,
    this.topics = const [],
    this.submissionStatus = TopicSubmissionStatus.idle,
    this.errorMessage,
  });

  TopicState copyWith({
    TopicListStatus? status,
    List<TopicModel>? topics,
    TopicSubmissionStatus? submissionStatus,
    String? errorMessage,
    bool clearError = false,
  }) => TopicState(
    status: status ?? this.status,
    topics: topics ?? this.topics,
    submissionStatus: submissionStatus ?? this.submissionStatus,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, topics, submissionStatus, errorMessage];
}
