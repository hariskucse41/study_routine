import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPlanModel {
  final String id;
  final String userId;
  final String title;
  final String? examName;
  final DateTime? examDate;
  final String status; // active | paused | completed | archived
  final int dailyTargetMinutes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudyPlanModel({
    required this.id,
    required this.userId,
    required this.title,
    this.examName,
    this.examDate,
    this.status = 'active',
    required this.dailyTargetMinutes,
    this.createdAt,
    this.updatedAt,
  });

  factory StudyPlanModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StudyPlanModel(
      id: doc.id,
      userId: d['userId'],
      title: d['title'] ?? '',
      examName: d['examName'],
      examDate: (d['examDate'] as Timestamp?)?.toDate(),
      status: d['status'] ?? 'active',
      dailyTargetMinutes: d['dailyTargetMinutes'] ?? 120,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'examName': examName,
    'examDate': examDate == null ? null : Timestamp.fromDate(examDate!),
    'status': status,
    'dailyTargetMinutes': dailyTargetMinutes,
    'updatedAt': FieldValue.serverTimestamp(),
    if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
  };

  int? get daysUntilExam {
    if (examDate == null) return null;
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final examMidnight = DateTime(
      examDate!.year,
      examDate!.month,
      examDate!.day,
    );
    return examMidnight.difference(todayMidnight).inDays;
  }
}
