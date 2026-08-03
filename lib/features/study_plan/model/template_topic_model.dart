import 'package:cloud_firestore/cloud_firestore.dart';

/// Read-only reference doc for one topic within a syllabus template —
/// mirrors TopicModel's shape minus the per-user fields (userId, planId,
/// subjectId, progress/status) that only exist once it's copied into a
/// real topic. [subjectTemplateId] and [parentTopicTemplateId] point at
/// other template docs (template_subjects / template_topics) and get
/// remapped to real Firestore IDs at copy time.
class TemplateTopicModel {
  final String id;
  final String templateId;
  final String subjectTemplateId;
  final String? parentTopicTemplateId; // null for a top-level chapter
  final String title;
  final String? description;
  final String priority;
  final String difficulty;
  final int estimatedMinutes;
  final int order;

  const TemplateTopicModel({
    required this.id,
    required this.templateId,
    required this.subjectTemplateId,
    this.parentTopicTemplateId,
    required this.title,
    this.description,
    required this.priority,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.order,
  });

  factory TemplateTopicModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TemplateTopicModel(
      id: doc.id,
      templateId: d['templateId'] ?? '',
      subjectTemplateId: d['subjectTemplateId'] ?? '',
      parentTopicTemplateId: d['parentTopicTemplateId'],
      title: d['title'] ?? '',
      description: d['description'],
      priority: d['priority'] ?? 'medium',
      difficulty: d['difficulty'] ?? 'medium',
      estimatedMinutes: d['estimatedMinutes'] ?? 0,
      order: d['order'] ?? 0,
    );
  }
}
