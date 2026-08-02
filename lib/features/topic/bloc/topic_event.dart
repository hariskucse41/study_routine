import 'package:equatable/equatable.dart';
import '../model/topic_model.dart';

sealed class TopicEvent extends Equatable {
  const TopicEvent();

  @override
  List<Object?> get props => [];
}

class WatchTopicsRequested extends TopicEvent {
  final String subjectId;
  const WatchTopicsRequested(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

/// Dispatched internally by TopicBloc in response to the Firestore stream —
/// not intended to be added by the UI.
class TopicsStreamUpdated extends TopicEvent {
  final List<TopicModel> topics;
  const TopicsStreamUpdated(this.topics);
  @override
  List<Object?> get props => [topics];
}

class TopicStreamFailed extends TopicEvent {
  final String message;
  const TopicStreamFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class AddTopicRequested extends TopicEvent {
  final String? parentTopicId;
  final String title;
  final String? description;
  final String difficulty;
  final int estimatedMinutes;

  const AddTopicRequested({
    this.parentTopicId,
    required this.title,
    this.description,
    required this.difficulty,
    required this.estimatedMinutes,
  });

  @override
  List<Object?> get props => [
    parentTopicId,
    title,
    description,
    difficulty,
    estimatedMinutes,
  ];
}
