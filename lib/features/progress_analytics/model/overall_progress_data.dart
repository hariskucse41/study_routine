import '../../subject/model/subject_model.dart';

class SubjectProgressEntry {
  final SubjectModel subject;
  final int progressPercent;

  const SubjectProgressEntry({
    required this.subject,
    required this.progressPercent,
  });
}

/// Computed aggregate for the Progress Dashboard (screen 22) — not a
/// Firestore document.
class OverallProgressData {
  final int overallProgressPercent;
  final List<SubjectProgressEntry> subjectProgress;

  /// Hours studied Monday..Sunday of the current calendar week.
  final List<double> weeklyHours;

  const OverallProgressData({
    required this.overallProgressPercent,
    required this.subjectProgress,
    required this.weeklyHours,
  });
}
