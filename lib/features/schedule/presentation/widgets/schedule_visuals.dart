import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

String scheduleStatusLabel(String status) {
  switch (status) {
    case 'inProgress':
      return 'In Progress';
    case 'completed':
      return 'Completed';
    case 'partiallyCompleted':
      return 'Partially Done';
    case 'missed':
      return 'Missed';
    case 'skipped':
      return 'Skipped';
    case 'rescheduled':
      return 'Rescheduled';
    case 'pending':
    default:
      return 'Pending';
  }
}

Color scheduleStatusColor(String status) {
  switch (status) {
    case 'inProgress':
      return AppColors.info;
    case 'completed':
      return AppColors.success;
    case 'partiallyCompleted':
      return AppColors.warning;
    case 'missed':
      return AppColors.error;
    case 'rescheduled':
      return AppColors.primary;
    case 'skipped':
    case 'pending':
    default:
      return AppColors.textSecondary;
  }
}

/// Formats a "HH:mm" 24-hour stored startTime as a friendly 12-hour label,
/// e.g. "08:00" -> "8:00 AM".
String formatStartTime(String startTime) {
  final parts = startTime.split(':');
  if (parts.length != 2) return startTime;
  final hour24 = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour24 == null || minute == null) return startTime;
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minuteStr = minute.toString().padLeft(2, '0');
  return '$hour12:$minuteStr $period';
}
