import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';

class GreetingHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;

  const GreetingHeader({super.key, required this.onNotificationsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingForNow(),
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Keep going, you can do it.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onNotificationsTap,
              icon: const Icon(Icons.notifications_outlined),
            ),
            Text(
              formatFriendlyDate(DateTime.now()),
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }
}
