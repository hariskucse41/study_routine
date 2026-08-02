import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/revision_model.dart';
import 'revision_visuals.dart';

class RevisionTile extends StatelessWidget {
  final RevisionModel revision;
  final String subjectName;
  final String topicName;
  final VoidCallback? onTap;

  const RevisionTile({
    super.key,
    required this.revision,
    required this.subjectName,
    required this.topicName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = revisionStatusColor(revision.status);
    final isOverdue = dueDateLabel(revision.scheduledDate) == 'Overdue';

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
                color: (isOverdue ? AppColors.error : statusColor).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                dueDateLabel(revision.scheduledDate),
                style: AppTextStyles.caption.copyWith(
                  color: isOverdue ? AppColors.error : statusColor,
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
