import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../subject/presentation/widgets/subject_visuals.dart';
import '../../model/overall_progress_data.dart';

class SubjectProgressBar extends StatelessWidget {
  final SubjectProgressEntry entry;
  final VoidCallback? onTap;

  const SubjectProgressBar({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = subjectColorFor(entry.subject.color);
    final ratio = entry.progressPercent / 100;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(subjectIconFor(entry.subject.icon), color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 90,
              child: Text(
                entry.subject.name,
                style: AppTextStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 40,
              child: Text(
                '${entry.progressPercent}%',
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
