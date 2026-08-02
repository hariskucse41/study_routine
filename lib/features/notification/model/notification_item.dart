enum NotificationItemType {
  studyReminder,
  dailyPlanReady,
  revisionDue,
  goalReminder,
  fcm,
}

/// A single row in the in-app notification feed (screen 27). Not a
/// Firestore document — see NotificationBloc for how this list is built:
/// partly live-computed from existing data (schedules/revisions/goals),
/// partly whatever FCM messages arrived this session.
class NotificationItem {
  final NotificationItemType type;
  final String title;
  final String body;
  final DateTime timestamp;

  const NotificationItem({
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
  });
}
