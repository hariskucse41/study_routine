import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/dashboard_summary.dart';

class RevisionStreakRow extends StatelessWidget {
  final DashboardSummary summary;
  final VoidCallback? onRevisionDueTap;
  final VoidCallback? onStreakTap;

  const RevisionStreakRow({
    super.key,
    required this.summary,
    this.onRevisionDueTap,
    this.onStreakTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.refresh,
            iconColor: AppColors.warning,
            label: 'Revision Due',
            value: '${summary.dueRevisionsCount}',
            suffix: summary.dueRevisionsCount == 1 ? 'Topic' : 'Topics',
            onTap: onRevisionDueTap,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.local_fire_department,
            iconColor: AppColors.error,
            label: 'Current Streak',
            value: '${summary.currentStreakDays}',
            suffix: summary.currentStreakDays == 1 ? 'Day' : 'Days',
            onTap: onStreakTap,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String suffix;
  final VoidCallback? onTap;

  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.suffix,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: AppTextStyles.heading1),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  suffix,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
