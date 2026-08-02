import 'topic_model.dart';

/// Computed stats over a list of topics — not a Firestore document itself.
/// Shared across Subject Detail (per-subject), and Progress Analytics
/// (per-subject rows, the plan-wide overall aggregate, and Subject
/// Analytics), so this math only lives in one place.
class TopicAggregates {
  final List<TopicModel> chapters;
  final int completed;
  final int inProgress;
  final int notStarted;
  final int overallProgressPercent;
  final int studyMinutes;
  final double avgConfidence;

  const TopicAggregates({
    required this.chapters,
    required this.completed,
    required this.inProgress,
    required this.notStarted,
    required this.overallProgressPercent,
    required this.studyMinutes,
    required this.avgConfidence,
  });

  factory TopicAggregates.from(List<TopicModel> topics) {
    final chapters = topics.where((t) => t.isChapter).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (topics.isEmpty) {
      return TopicAggregates(
        chapters: chapters,
        completed: 0,
        inProgress: 0,
        notStarted: 0,
        overallProgressPercent: 0,
        studyMinutes: 0,
        avgConfidence: 0,
      );
    }

    final completed = topics.where((t) => t.status == 'completed').length;
    final inProgress = topics.where((t) => t.status == 'inProgress').length;
    final notStarted = topics.where((t) => t.status == 'notStarted').length;
    final overallProgress =
        topics.fold<int>(0, (sum, t) => sum + t.progressPercentage) ~/
        topics.length;
    final studyMinutes = topics.fold<int>(0, (sum, t) => sum + t.actualMinutes);
    final avgConfidence =
        topics.fold<double>(0, (sum, t) => sum + t.confidenceScore) /
        topics.length;

    return TopicAggregates(
      chapters: chapters,
      completed: completed,
      inProgress: inProgress,
      notStarted: notStarted,
      overallProgressPercent: overallProgress,
      studyMinutes: studyMinutes,
      avgConfidence: avgConfidence,
    );
  }
}
