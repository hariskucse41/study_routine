import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';

String revisionStatusLabel(String status) {
  switch (status) {
    case 'completed':
      return 'Completed';
    case 'missed':
      return 'Missed';
    case 'rescheduled':
      return 'Rescheduled';
    case 'pending':
    default:
      return 'Pending';
  }
}

Color revisionStatusColor(String status) {
  switch (status) {
    case 'completed':
      return AppColors.success;
    case 'missed':
      return AppColors.error;
    case 'rescheduled':
      return AppColors.primary;
    case 'pending':
    default:
      return AppColors.warning;
  }
}

/// "Today" / "Overdue" / a friendly date, for the due-date badge.
String dueDateLabel(DateTime scheduledDate) {
  final today = localMidnight(DateTime.now());
  final due = localMidnight(scheduledDate);
  if (due == today) return 'Today';
  if (due.isBefore(today)) return 'Overdue';
  return formatFriendlyDate(due);
}
