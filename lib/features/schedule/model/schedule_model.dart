import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String userId;
  final String planId;
  final String subjectId;
  final String topicId;
  final DateTime scheduledDate; // local midnight
  final String startTime; // 24-hour zero-padded "HH:mm", sorts correctly as text
  final int plannedMinutes;
  final String priority; // low | medium | high
  final String status; // pending|inProgress|completed|partiallyCompleted|missed|skipped|rescheduled
  final int completionPercentage;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const ScheduleModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.subjectId,
    required this.topicId,
    required this.scheduledDate,
    required this.startTime,
    required this.plannedMinutes,
    this.priority = 'medium',
    this.status = 'pending',
    this.completionPercentage = 0,
    this.reminderEnabled = false,
    this.reminderMinutesBefore = 10,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ScheduleModel(
      id: doc.id,
      userId: d['userId'],
      planId: d['planId'],
      subjectId: d['subjectId'],
      topicId: d['topicId'],
      scheduledDate: (d['scheduledDate'] as Timestamp).toDate(),
      startTime: d['startTime'] ?? '00:00',
      plannedMinutes: d['plannedMinutes'] ?? 0,
      priority: d['priority'] ?? 'medium',
      status: d['status'] ?? 'pending',
      completionPercentage: d['completionPercentage'] ?? 0,
      reminderEnabled: d['reminderEnabled'] ?? false,
      reminderMinutesBefore: d['reminderMinutesBefore'] ?? 10,
      notes: d['notes'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'planId': planId,
    'subjectId': subjectId,
    'topicId': topicId,
    'scheduledDate': Timestamp.fromDate(scheduledDate),
    'startTime': startTime,
    'plannedMinutes': plannedMinutes,
    'priority': priority,
    'status': status,
    'completionPercentage': completionPercentage,
    'reminderEnabled': reminderEnabled,
    'reminderMinutesBefore': reminderMinutesBefore,
    'notes': notes,
    'updatedAt': FieldValue.serverTimestamp(),
    if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
  };
}
