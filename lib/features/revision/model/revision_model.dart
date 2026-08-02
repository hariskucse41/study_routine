import 'package:cloud_firestore/cloud_firestore.dart';

class RevisionModel {
  final String id;
  final String userId;
  final String planId;
  final String subjectId;
  final String topicId;
  final int revisionNumber;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status; // pending | completed | missed | rescheduled
  final double confidenceScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RevisionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.subjectId,
    required this.topicId,
    required this.revisionNumber,
    required this.scheduledDate,
    this.completedDate,
    this.status = 'pending',
    this.confidenceScore = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory RevisionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RevisionModel(
      id: doc.id,
      userId: d['userId'],
      planId: d['planId'],
      subjectId: d['subjectId'],
      topicId: d['topicId'],
      revisionNumber: d['revisionNumber'] ?? 1,
      scheduledDate: (d['scheduledDate'] as Timestamp).toDate(),
      completedDate: (d['completedDate'] as Timestamp?)?.toDate(),
      status: d['status'] ?? 'pending',
      confidenceScore: (d['confidenceScore'] ?? 0.0).toDouble(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'planId': planId,
    'subjectId': subjectId,
    'topicId': topicId,
    'revisionNumber': revisionNumber,
    'scheduledDate': Timestamp.fromDate(scheduledDate),
    'completedDate': completedDate == null
        ? null
        : Timestamp.fromDate(completedDate!),
    'status': status,
    'confidenceScore': confidenceScore,
    'updatedAt': FieldValue.serverTimestamp(),
    if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
  };
}
