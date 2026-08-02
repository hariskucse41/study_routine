import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Local-midnight boundaries for "today", in the device's local timezone.
/// See §10 of the implementation guide: a full per-user IANA timezone
/// (users/{uid}.timezone) would need the `timezone` package on top of this;
/// this pragmatic version uses the device's own local time, which is
/// correct as long as the device and the user are in the same zone.
class TodayRange {
  final DateTime start;
  final DateTime end;
  const TodayRange(this.start, this.end);

  Timestamp get startTimestamp => Timestamp.fromDate(start);
  Timestamp get endTimestamp => Timestamp.fromDate(end);
}

TodayRange todayRange() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return TodayRange(start, end);
}

DateTime localMidnight(DateTime date) =>
    DateTime(date.year, date.month, date.day);

String formatMinutesAsHoursMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) return '${mins}m';
  if (mins == 0) return '${hours}h';
  return '${hours}h ${mins}m';
}

String formatFriendlyDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning!';
  if (hour < 17) return 'Good Afternoon!';
  return 'Good Evening!';
}
