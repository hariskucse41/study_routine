import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class WeeklyStreakRow extends StatelessWidget {
  final List<bool?> weekMetStatus;

  const WeeklyStreakRow({super.key, required this.weekMetStatus});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final met = weekMetStatus[i];
        final Color color;
        final Widget child;
        if (met == null) {
          color = AppColors.border;
          child = const SizedBox.shrink();
        } else if (met) {
          color = AppColors.success;
          child = const Icon(
            Icons.check,
            size: 14,
            color: AppColors.textOnPrimary,
          );
        } else {
          color = AppColors.error.withValues(alpha: 0.15);
          child = const Icon(Icons.close, size: 14, color: AppColors.error);
        }

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: child,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _labels[i],
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
