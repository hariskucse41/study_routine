import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const String _reminderChannelId = 'study_routine_reminders';
const String _reminderChannelName = 'Study Reminders';
const String _reminderChannelDescription =
    'Study session, revision and goal reminders';

/// Thin wrapper around flutter_local_notifications + FirebaseMessaging.
///
/// flutter_local_notifications has no web implementation (confirmed: no
/// platform package for web got resolved when it was added), so every call
/// into it is guarded by `kIsWeb` — on web, scheduling silently no-ops
/// instead of throwing a MissingPluginException, since Chrome is this
/// project's only currently-verified test target. FirebaseMessaging's
/// permission request and foreground listener DO work on web, so those
/// aren't guarded.
class NotificationService {
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb) return;

    tz_data.initializeTimeZones();
    // The app's schema already assumes Asia/Dhaka as the default user
    // timezone (see AuthRepository.signUp's default) — reused here rather
    // than adding a separate device-timezone-detection package for v1.
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _localPlugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    const channel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: _reminderChannelDescription,
      importance: Importance.high,
    );
    await _localPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Shows the OS permission prompt directly — callers should show their
  /// own rationale dialog first (see NotificationsPage).
  Future<bool> requestPermission() async {
    final fcmSettings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    var granted =
        fcmSettings.authorizationStatus == AuthorizationStatus.authorized ||
        fcmSettings.authorizationStatus == AuthorizationStatus.provisional;

    if (!kIsWeb) {
      final androidImpl = _localPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        final androidGranted = await androidImpl
            .requestNotificationsPermission();
        granted = granted || (androidGranted ?? false);
      }
    }
    return granted;
  }

  /// Schedules a one-off notification at [dateTime]. No-ops on web, if the
  /// service hasn't initialized, or if [dateTime] has already passed.
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (kIsWeb || !_initialized) return;
    final scheduled = tz.TZDateTime.from(dateTime, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _localPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Schedules a notification that repeats daily at [hour]:[minute] local
  /// time (e.g. "Daily Plan Ready", "Goal Reminder").
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb || !_initialized) return;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _localPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _localPlugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _localPlugin.cancelAll();
  }

  NotificationDetails _notificationDetails() => const NotificationDetails(
    android: AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Real and cross-platform (including web) — but nothing in this
  /// project's architecture ever sends an FCM push (no Cloud Functions),
  /// so this stays silent unless a message is sent manually via the
  /// Firebase Console for testing.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;
}
