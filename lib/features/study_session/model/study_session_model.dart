import 'package:cloud_firestore/cloud_firestore.dart';

class StudySessionModel {
  final String id;
  final String userId;
  final String planId;
  final String? scheduleId; // null for ad-hoc sessions
  final String subjectId;
  final String topicId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int plannedMinutes;
  final int actualMinutes;
  final int completionPercentage;
  final double confidenceScore;
  final String? notes;
  final DateTime? createdAt;

  const StudySessionModel({
    required this.id,
    required this.userId,
    required this.planId,
    this.scheduleId,
    required this.subjectId,
    required this.topicId,
    required this.startedAt,
    this.endedAt,
    required this.plannedMinutes,
    this.actualMinutes = 0,
    this.completionPercentage = 0,
    this.confidenceScore = 0.0,
    this.notes,
    this.createdAt,
  });

  factory StudySessionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StudySessionModel(
      id: doc.id,
      userId: d['userId'],
      planId: d['planId'],
      scheduleId: d['scheduleId'],
      subjectId: d['subjectId'],
      topicId: d['topicId'],
      startedAt: (d['startedAt'] as Timestamp).toDate(),
      endedAt: (d['endedAt'] as Timestamp?)?.toDate(),
      plannedMinutes: d['plannedMinutes'] ?? 0,
      actualMinutes: d['actualMinutes'] ?? 0,
      completionPercentage: d['completionPercentage'] ?? 0,
      confidenceScore: (d['confidenceScore'] ?? 0.0).toDouble(),
      notes: d['notes'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'planId': planId,
    'scheduleId': scheduleId,
    'subjectId': subjectId,
    'topicId': topicId,
    'startedAt': Timestamp.fromDate(startedAt),
    'endedAt': endedAt == null ? null : Timestamp.fromDate(endedAt!),
    'plannedMinutes': plannedMinutes,
    'actualMinutes': actualMinutes,
    'completionPercentage': completionPercentage,
    'confidenceScore': confidenceScore,
    'notes': notes,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
