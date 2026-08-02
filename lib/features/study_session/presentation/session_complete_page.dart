import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/study_session_bloc.dart';

class SessionCompletePage extends StatelessWidget {
  const SessionCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StudySessionBloc>.value(
      value: getIt<StudySessionBloc>(),
      child: const _SessionCompleteView(),
    );
  }
}

class _SessionCompleteView extends StatelessWidget {
  const _SessionCompleteView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudySessionBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_outlined,
                  color: AppColors.success,
                  size: 56,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Great Work!',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                "You've completed the session.",
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      '${state.subjectName} • ${state.topicName}',
                      style: AppTextStyles.heading3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TimeStat(
                          label: 'Planned Time',
                          value: formatMinutesAsHoursMinutes(
                            state.plannedMinutes,
                          ),
                        ),
                        _TimeStat(
                          label: 'Actual Time',
                          value: formatMinutesAsHoursMinutes(
                            state.actualMinutes,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Update Progress',
                onPressed: () => context.go(AppRoutes.updateProgress),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  final subjectId = state.subjectId;
                  context.go(
                    subjectId == null
                        ? AppRoutes.home
                        : AppRoutes.subjectDetail(subjectId),
                  );
                },
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeStat extends StatelessWidget {
  final String label;
  final String value;

  const _TimeStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading2),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
