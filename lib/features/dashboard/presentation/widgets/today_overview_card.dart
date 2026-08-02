import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../model/dashboard_summary.dart';

class TodayOverviewCard extends StatelessWidget {
  final DashboardSummary summary;
  final VoidCallback? onTap;

  const TodayOverviewCard({super.key, required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final percent = (summary.dailyProgressRatio * 100).round();

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today Overview', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _StatTile(label: 'Tasks', value: '${summary.totalTasksToday}'),
                _StatTile(
                  label: 'Completed',
                  value: '${summary.completedTasksToday}',
                ),
                _StatTile(
                  label: 'Remaining',
                  value: '${summary.remainingTasksToday}',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Text('Daily Progress', style: AppTextStyles.bodyMedium),
                const Spacer(),
                Text(
                  '$percent%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: summary.dailyProgressRatio,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Study Time ${formatMinutesAsHoursMinutes(summary.studyMinutesToday)} '
              '/ ${formatMinutesAsHoursMinutes(summary.plan.dailyTargetMinutes)}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
