import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/notification_item.dart';

(IconData, Color) _visualsFor(NotificationItemType type) {
  switch (type) {
    case NotificationItemType.studyReminder:
      return (Icons.timer_outlined, AppColors.primary);
    case NotificationItemType.dailyPlanReady:
      return (Icons.today_outlined, AppColors.info);
    case NotificationItemType.revisionDue:
      return (Icons.refresh, AppColors.warning);
    case NotificationItemType.goalReminder:
      return (Icons.flag_outlined, AppColors.error);
    case NotificationItemType.fcm:
      return (Icons.notifications_outlined, AppColors.primary);
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const NotificationTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _visualsFor(item.type);
    final hour = item.timestamp.hour.toString().padLeft(2, '0');
    final minute = item.timestamp.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$hour:$minute',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
