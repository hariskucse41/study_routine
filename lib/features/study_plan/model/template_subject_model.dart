import 'package:cloud_firestore/cloud_firestore.dart';

/// Read-only reference doc for one subject within a syllabus template —
/// mirrors SubjectModel's shape minus the per-user fields (userId, planId,
/// isArchived) that only exist once it's copied into a real subject.
class TemplateSubjectModel {
  final String id;
  final String templateId;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final String priority;
  final int order;
  final int estimatedMinutes;

  const TemplateSubjectModel({
    required this.id,
    required this.templateId,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.priority,
    required this.order,
    required this.estimatedMinutes,
  });

  factory TemplateSubjectModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TemplateSubjectModel(
      id: doc.id,
      templateId: d['templateId'] ?? '',
      name: d['name'] ?? '',
      description: d['description'],
      icon: d['icon'] ?? 'book',
      color: d['color'] ?? '5B3FD6',
      priority: d['priority'] ?? 'medium',
      order: d['order'] ?? 0,
      estimatedMinutes: d['estimatedMinutes'] ?? 0,
    );
  }
}
