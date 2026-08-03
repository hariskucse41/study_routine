import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../schedule/model/schedule_model.dart';
import '../../../topic/model/topic_model.dart';
import '../../../topic/presentation/widgets/topic_visuals.dart';

class SearchResultTile extends StatelessWidget {
  final TopicModel topic;
  final String subjectName;
  final ScheduleModel? nextSchedule;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.topic,
    required this.subjectName,
    this.nextSchedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = topicStatusColor(topic.status);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(topic.title, style: AppTextStyles.heading3)),
                Text(
                  '${topic.progressPercentage}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subjectName,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _Badge(label: topicStatusLabel(topic.status), color: statusColor),
                _Badge(
                  label: 'Priority: ${topic.priority}',
                  color: AppColors.textSecondary,
                ),
                _Badge(
                  label: 'Difficulty: ${topic.difficulty}',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            if (nextSchedule != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Scheduled ${formatFriendlyDate(nextSchedule!.scheduledDate)} · '
                    '${nextSchedule!.startTime}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
