import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

const String onboardingSeenKey = 'onboarding_seen';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 2), _redirect);
  }

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool(onboardingSeenKey) ?? false;
    if (!mounted) return;
    // If already authenticated, the router's redirect (see app/router.dart)
    // immediately bounces this /login navigation to /home — splash itself
    // only needs to decide between onboarding and the login gate.
    context.go(onboardingSeen ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(
                Icons.school_outlined,
                color: AppColors.textOnPrimary,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Study Routine', style: AppTextStyles.heading1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Plan your study. Track your progress. Achieve your goal.',
              textAlign: TextAlign.center,
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
