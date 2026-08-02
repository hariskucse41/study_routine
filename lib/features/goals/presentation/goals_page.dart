import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../model/goals_summary.dart';
import 'widgets/goal_checklist_item.dart';
import 'widgets/weekly_streak_row.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GoalsBloc>(
      create: (_) => getIt<GoalsBloc>()..add(const LoadGoalsRequested()),
      child: const _GoalsView(),
    );
  }
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Goals & Streaks')),
      body: SafeArea(
        child: BlocBuilder<GoalsBloc, GoalsState>(
          builder: (context, state) {
            switch (state.status) {
              case GoalsStatus.initial:
              case GoalsStatus.loading:
                return const LoadingIndicator();
              case GoalsStatus.error:
                return ErrorStateWidget(
                  message: state.errorMessage ?? 'Something went wrong',
                  onRetry: () => context.read<GoalsBloc>().add(
                    const LoadGoalsRequested(),
                  ),
                );
              case GoalsStatus.noPlan:
                return EmptyStateWidget(
                  message: "You haven't selected a study plan yet.",
                  icon: Icons.flag_outlined,
                  action: TextButton(
                    onPressed: () => context.go(AppRoutes.selectPlan),
                    child: const Text('Choose a plan'),
                  ),
                );
              case GoalsStatus.success:
                return _GoalsContent(summary: state.summary!);
            }
          },
        ),
      ),
    );
  }
}

class _GoalsContent extends StatelessWidget {
  final GoalsSummary summary;

  const _GoalsContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text('Daily Goals', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.md),
        GoalChecklistItem(
          icon: Icons.timer_outlined,
          label: 'Study Time',
          valueLabel:
              '${formatMinutesAsHoursMinutes(summary.studyMinutesToday)} / '
              '${formatMinutesAsHoursMinutes(summary.studyMinutesTarget)}',
          progress: summary.studyMinutesTarget <= 0
              ? 0
              : summary.studyMinutesToday / summary.studyMinutesTarget,
        ),
        const SizedBox(height: AppSpacing.sm),
        GoalChecklistItem(
          icon: Icons.menu_book_outlined,
          label: 'Complete Topics',
          valueLabel: '${summary.topicsCompletedToday}/${summary.topicsTarget}',
          progress: summary.topicsTarget <= 0
              ? 0
              : summary.topicsCompletedToday / summary.topicsTarget,
        ),
        const SizedBox(height: AppSpacing.sm),
        GoalChecklistItem(
          icon: Icons.refresh,
          label: 'Revise Topics',
          valueLabel:
              '${summary.revisionsCompletedToday}/${summary.revisionsTarget}',
          progress: summary.revisionsTarget <= 0
              ? 0
              : summary.revisionsCompletedToday / summary.revisionsTarget,
        ),
        const SizedBox(height: AppSpacing.sm),
        GoalChecklistItem(
          icon: Icons.quiz_outlined,
          label: 'Solve MCQs',
          valueLabel: '${summary.mcqsSolvedToday}/${summary.mcqsTarget}',
          progress: summary.mcqsTarget <= 0
              ? 0
              : summary.mcqsSolvedToday / summary.mcqsTarget,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('This Week', style: AppTextStyles.heading3),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${summary.currentStreakDays} '
                        '${summary.currentStreakDays == 1 ? 'Day' : 'Days'}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              WeeklyStreakRow(weekMetStatus: summary.weekMetStatus),
            ],
          ),
        ),
      ],
    );
  }
}
