import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPreferencesModel {
  final String userId;
  final bool studyReminderEnabled;
  final bool revisionReminderEnabled;
  final bool dailyPlanReminderEnabled;
  final bool goalReminderEnabled;
  final String morningReminderTime; // 'HH:mm'
  final String eveningReminderTime; // 'HH:mm'
  final bool pushEnabled;
  final int breakReminderMinutes; // interval between break reminders
  final DateTime? updatedAt;

  const NotificationPreferencesModel({
    required this.userId,
    this.studyReminderEnabled = true,
    this.revisionReminderEnabled = true,
    this.dailyPlanReminderEnabled = true,
    this.goalReminderEnabled = true,
    this.morningReminderTime = '08:00',
    this.eveningReminderTime = '20:00',
    this.pushEnabled = true,
    this.breakReminderMinutes = 60,
    this.updatedAt,
  });

  factory NotificationPreferencesModel.defaultsFor(String userId) =>
      NotificationPreferencesModel(userId: userId);

  factory NotificationPreferencesModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationPreferencesModel(
      userId: d['userId'] ?? doc.id,
      studyReminderEnabled: d['studyReminderEnabled'] ?? true,
      revisionReminderEnabled: d['revisionReminderEnabled'] ?? true,
      dailyPlanReminderEnabled: d['dailyPlanReminderEnabled'] ?? true,
      goalReminderEnabled: d['goalReminderEnabled'] ?? true,
      morningReminderTime: d['morningReminderTime'] ?? '08:00',
      eveningReminderTime: d['eveningReminderTime'] ?? '20:00',
      pushEnabled: d['pushEnabled'] ?? true,
      breakReminderMinutes: d['breakReminderMinutes'] ?? 60,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'studyReminderEnabled': studyReminderEnabled,
    'revisionReminderEnabled': revisionReminderEnabled,
    'dailyPlanReminderEnabled': dailyPlanReminderEnabled,
    'goalReminderEnabled': goalReminderEnabled,
    'morningReminderTime': morningReminderTime,
    'eveningReminderTime': eveningReminderTime,
    'pushEnabled': pushEnabled,
    'breakReminderMinutes': breakReminderMinutes,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  NotificationPreferencesModel copyWith({int? breakReminderMinutes}) =>
      NotificationPreferencesModel(
        userId: userId,
        studyReminderEnabled: studyReminderEnabled,
        revisionReminderEnabled: revisionReminderEnabled,
        dailyPlanReminderEnabled: dailyPlanReminderEnabled,
        goalReminderEnabled: goalReminderEnabled,
        morningReminderTime: morningReminderTime,
        eveningReminderTime: eveningReminderTime,
        pushEnabled: pushEnabled,
        breakReminderMinutes:
            breakReminderMinutes ?? this.breakReminderMinutes,
        updatedAt: updatedAt,
      );
}
