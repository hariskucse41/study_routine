import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String id;
  final String userId;
  final String planId;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final String priority; // low | medium | high
  final int order;
  final int estimatedMinutes;
  final bool isArchived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubjectModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.priority,
    required this.order,
    required this.estimatedMinutes,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      userId: d['userId'],
      planId: d['planId'],
      name: d['name'] ?? '',
      description: d['description'],
      icon: d['icon'] ?? 'book',
      color: d['color'] ?? '5B3FD6',
      priority: d['priority'] ?? 'medium',
      order: d['order'] ?? 0,
      estimatedMinutes: d['estimatedMinutes'] ?? 0,
      isArchived: d['isArchived'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'planId': planId,
    'name': name,
    'description': description,
    'icon': icon,
    'color': color,
    'priority': priority,
    'order': order,
    'estimatedMinutes': estimatedMinutes,
    'isArchived': isArchived,
    'updatedAt': FieldValue.serverTimestamp(),
    if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
  };
}
