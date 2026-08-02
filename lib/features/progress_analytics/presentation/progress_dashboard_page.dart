import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/nav_actions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/progress_analytics_bloc.dart';
import '../bloc/progress_analytics_event.dart';
import '../bloc/progress_analytics_state.dart';
import '../model/overall_progress_data.dart';
import 'widgets/subject_progress_bar.dart';
import 'widgets/weekly_hours_chart.dart';

class ProgressDashboardPage extends StatelessWidget {
  const ProgressDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgressAnalyticsBloc>(
      create: (_) =>
          getIt<ProgressAnalyticsBloc>()
            ..add(const LoadOverallProgressRequested()),
      child: const _ProgressDashboardView(),
    );
  }
}

class _ProgressDashboardView extends StatelessWidget {
  const _ProgressDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Progress')),
      body: SafeArea(
        child: BlocBuilder<ProgressAnalyticsBloc, ProgressAnalyticsState>(
          builder: (context, state) {
            switch (state.status) {
              case ProgressStatus.initial:
              case ProgressStatus.loading:
                return const LoadingIndicator();
              case ProgressStatus.error:
                return ErrorStateWidget(
                  message: state.errorMessage ?? 'Something went wrong',
                  onRetry: () => context.read<ProgressAnalyticsBloc>().add(
                    const LoadOverallProgressRequested(),
                  ),
                );
              case ProgressStatus.noPlan:
                return EmptyStateWidget(
                  message: "You haven't selected a study plan yet.",
                  icon: Icons.insights_outlined,
                  action: TextButton(
                    onPressed: () => context.go(AppRoutes.selectPlan),
                    child: const Text('Choose a plan'),
                  ),
                );
              case ProgressStatus.success:
                return _ProgressContent(data: state.overallProgress!);
            }
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: AppNavTab.progress,
        onTap: (tab) => handleBottomNavTap(context, tab, AppNavTab.progress),
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  final OverallProgressData data;

  const _ProgressContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: data.overallProgressPercent / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${data.overallProgressPercent}%',
                      style: AppTextStyles.heading1,
                    ),
                    Text(
                      'Overall Progress',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This Week', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),
              WeeklyHoursChart(hoursByDay: data.weeklyHours),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subject Progress', style: AppTextStyles.heading3),
            Wrap(
              children: [
                TextButton(
                  onPressed: () => context.push(AppRoutes.weakTopics),
                  child: const Text('Weak Topics'),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.testResults),
                  child: const Text('Test Results'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (data.subjectProgress.isEmpty)
          const EmptyStateWidget(
            message: 'Add a subject to see your progress here',
            icon: Icons.menu_book_outlined,
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (final entry in data.subjectProgress)
                  SubjectProgressBar(
                    entry: entry,
                    onTap: () => context.push(
                      AppRoutes.subjectAnalytics(entry.subject.id),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
