import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  final String id;
  final String userId;
  final String planId;
  final String subjectId;
  final String? parentTopicId; // null for a top-level chapter
  final String title;
  final String? description;
  final String priority; // low | medium | high
  final String difficulty; // easy | medium | hard
  final int estimatedMinutes;
  final int actualMinutes;
  final int progressPercentage; // 0-100
  final String status; // notStarted | inProgress | completed | revisionNeeded | mastered
  final double confidenceScore;
  final bool revisionRequired;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const TopicModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.subjectId,
    this.parentTopicId,
    required this.title,
    this.description,
    this.priority = 'medium',
    required this.difficulty,
    required this.estimatedMinutes,
    this.actualMinutes = 0,
    this.progressPercentage = 0,
    this.status = 'notStarted',
    this.confidenceScore = 0.0,
    this.revisionRequired = false,
    required this.order,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  bool get isChapter => parentTopicId == null;

  factory TopicModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TopicModel(
      id: doc.id,
      userId: d['userId'],
      planId: d['planId'],
      subjectId: d['subjectId'],
      parentTopicId: d['parentTopicId'],
      title: d['title'] ?? '',
      description: d['description'],
      priority: d['priority'] ?? 'medium',
      difficulty: d['difficulty'] ?? 'medium',
      estimatedMinutes: d['estimatedMinutes'] ?? 0,
      actualMinutes: d['actualMinutes'] ?? 0,
      progressPercentage: d['progressPercentage'] ?? 0,
      status: d['status'] ?? 'notStarted',
      confidenceScore: (d['confidenceScore'] ?? 0.0).toDouble(),
      revisionRequired: d['revisionRequired'] ?? false,
      order: d['order'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'planId': planId,
    'subjectId': subjectId,
    'parentTopicId': parentTopicId,
    'title': title,
    'description': description,
    'priority': priority,
    'difficulty': difficulty,
    'estimatedMinutes': estimatedMinutes,
    'actualMinutes': actualMinutes,
    'progressPercentage': progressPercentage,
    'status': status,
    'confidenceScore': confidenceScore,
    'revisionRequired': revisionRequired,
    'order': order,
    'updatedAt': FieldValue.serverTimestamp(),
    if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
  };
}
