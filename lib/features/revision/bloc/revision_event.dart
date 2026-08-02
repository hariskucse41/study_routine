import 'package:equatable/equatable.dart';
import '../model/revision_model.dart';

sealed class RevisionEvent extends Equatable {
  const RevisionEvent();

  @override
  List<Object?> get props => [];
}

class WatchDueRevisionsRequested extends RevisionEvent {
  const WatchDueRevisionsRequested();
}

class WatchRevisionHistoryRequested extends RevisionEvent {
  final String planId;
  final String subjectId;
  final String topicId;

  const WatchRevisionHistoryRequested({
    required this.planId,
    required this.subjectId,
    required this.topicId,
  });

  @override
  List<Object?> get props => [planId, subjectId, topicId];
}

/// Dispatched internally by RevisionBloc in response to the Firestore
/// stream — not intended to be added by the UI.
class RevisionsStreamUpdated extends RevisionEvent {
  final List<RevisionModel> revisions;
  const RevisionsStreamUpdated(this.revisions);
  @override
  List<Object?> get props => [revisions];
}

class RevisionStreamFailed extends RevisionEvent {
  final String message;
  const RevisionStreamFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class MarkAllCompleteRequested extends RevisionEvent {
  const MarkAllCompleteRequested();
}

class RescheduleRevisionRequested extends RevisionEvent {
  final String revisionId;
  final DateTime newDate;

  const RescheduleRevisionRequested({
    required this.revisionId,
    required this.newDate,
  });

  @override
  List<Object?> get props => [revisionId, newDate];
}

/// Uses the planId/subjectId/topicId cached from the most recent
/// WatchRevisionHistoryRequested and the next revisionNumber computed from
/// the currently loaded history.
class LogNextRevisionRequested extends RevisionEvent {
  const LogNextRevisionRequested();
}
