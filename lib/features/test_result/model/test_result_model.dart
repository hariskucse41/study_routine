import 'package:cloud_firestore/cloud_firestore.dart';

class TestResultModel {
  final String id;
  final String userId;
  final String planId;
  final String subjectId;

  /// Present in the schema, but not collected by the v1 Add Test Result
  /// form — a test typically spans a whole subject, not one topic.
  final String? topicId;

  final String title;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final double scorePercentage;
  final int durationMinutes;
  final DateTime testDate;
  final String? notes;
  final DateTime? createdAt;

  const TestResultModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.subjectId,
    this.topicId,
    required this.title,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.scorePercentage,
    required this.durationMinutes,
    required this.testDate,
    this.notes,
    this.createdAt,
  });

  factory TestResultModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TestResultModel(
      id: doc.id,
      userId: d['userId'],
      planId: d['planId'],
      subjectId: d['subjectId'],
      topicId: d['topicId'],
      title: d['title'] ?? '',
      totalQuestions: d['totalQuestions'] ?? 0,
      correctAnswers: d['correctAnswers'] ?? 0,
      wrongAnswers: d['wrongAnswers'] ?? 0,
      skippedAnswers: d['skippedAnswers'] ?? 0,
      scorePercentage: (d['scorePercentage'] ?? 0.0).toDouble(),
      durationMinutes: d['durationMinutes'] ?? 0,
      testDate: (d['testDate'] as Timestamp).toDate(),
      notes: d['notes'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'planId': planId,
    'subjectId': subjectId,
    'topicId': topicId,
    'title': title,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'wrongAnswers': wrongAnswers,
    'skippedAnswers': skippedAnswers,
    'scorePercentage': scorePercentage,
    'durationMinutes': durationMinutes,
    'testDate': Timestamp.fromDate(testDate),
    'notes': notes,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
