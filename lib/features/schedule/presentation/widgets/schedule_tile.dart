import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../study_session/presentation/session_start_args.dart';
import '../../model/schedule_model.dart';
import 'schedule_visuals.dart';

/// Shared by every screen that renders a [ScheduleTile] and wants tapping
/// it to launch a focus session for that scheduled task (Today's Routine,
/// Calendar agenda).
SessionStartArgs sessionArgsForSchedule(
  ScheduleModel schedule,
  String subjectName,
  String topicName,
) {
  return SessionStartArgs(
    planId: schedule.planId,
    subjectId: schedule.subjectId,
    topicId: schedule.topicId,
    subjectName: subjectName,
    topicName: topicName,
    scheduleId: schedule.id,
    plannedMinutes: schedule.plannedMinutes > 0 ? schedule.plannedMinutes : 25,
  );
}

class ScheduleTile extends StatelessWidget {
  final ScheduleModel schedule;
  final String subjectName;
  final String topicName;
  final VoidCallback? onTap;

  const ScheduleTile({
    super.key,
    required this.schedule,
    required this.subjectName,
    required this.topicName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = scheduleStatusColor(schedule.status);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                formatStartTime(schedule.startTime),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName.isEmpty ? 'Subject' : subjectName,
                    style: AppTextStyles.heading3,
                  ),
                  Text(
                    topicName.isEmpty ? 'Topic' : topicName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                scheduleStatusLabel(schedule.status),
                style: AppTextStyles.caption.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
