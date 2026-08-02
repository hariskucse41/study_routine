import '../../subject/model/subject_model.dart';
import '../../topic/model/topic_aggregates.dart';

/// Computed aggregate for the Subject Analytics screen (23) — not a
/// Firestore document.
class SubjectAnalyticsData {
  final SubjectModel subject;
  final TopicAggregates aggregates;

  const SubjectAnalyticsData({required this.subject, required this.aggregates});
}
