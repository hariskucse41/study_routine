import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../model/test_result_model.dart';

class TestResultCard extends StatelessWidget {
  final TestResultModel result;
  final String subjectName;

  const TestResultCard({
    super.key,
    required this.result,
    required this.subjectName,
  });

  Color get _scoreColor {
    if (result.scorePercentage >= 80) return AppColors.success;
    if (result.scorePercentage >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(result.title, style: AppTextStyles.heading3),
                Text(
                  subjectName.isEmpty ? 'Subject' : subjectName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatFriendlyDate(result.testDate),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${result.scorePercentage.round()}%',
            style: AppTextStyles.heading2.copyWith(color: _scoreColor),
          ),
        ],
      ),
    );
  }
}
