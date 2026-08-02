import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../study_plan/model/study_plan_model.dart';

class ActivePlanCard extends StatelessWidget {
  final StudyPlanModel plan;

  const ActivePlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final daysUntilExam = plan.daysUntilExam;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.title,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          if (plan.examName != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              plan.examName!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (daysUntilExam != null)
            Text(
              daysUntilExam >= 0
                  ? 'Exam in $daysUntilExam Days'
                  : 'Exam date passed',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              'No exam date set',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.85),
              ),
            ),
        ],
      ),
    );
  }
}
