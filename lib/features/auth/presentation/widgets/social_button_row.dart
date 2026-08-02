import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Layout-only Google/Apple sign-in buttons matching the mockup.
/// No OAuth package (google_sign_in / sign_in_with_apple) is in the
/// project's dependency scope yet, so these show a "coming soon" notice
/// instead of claiming to authenticate.
class SocialButtonRow extends StatelessWidget {
  const SocialButtonRow({super.key});

  void _showComingSoon(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is not available yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'G',
            onPressed: () => _showComingSoon(context, 'Google'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SocialButton(
            icon: Icons.apple,
            onPressed: () => _showComingSoon(context, 'Apple'),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _SocialButton({this.label, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: icon != null
            ? Icon(icon, color: AppColors.textPrimary)
            : Text(
                label!,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }
}
