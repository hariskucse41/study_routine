import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/nav_actions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'widgets/active_plan_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/revision_streak_row.dart';
import 'widgets/today_overview_card.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) =>
          getIt<DashboardBloc>()..add(const LoadDashboardRequested()),
      child: const _HomeDashboardView(),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            switch (state.status) {
              case DashboardStatus.initial:
              case DashboardStatus.loading:
                return const LoadingIndicator();
              case DashboardStatus.error:
                return ErrorStateWidget(
                  message: state.errorMessage ?? 'Something went wrong',
                  onRetry: () => context.read<DashboardBloc>().add(
                    const LoadDashboardRequested(),
                  ),
                );
              case DashboardStatus.noPlan:
                return EmptyStateWidget(
                  message: "You haven't selected a study plan yet.",
                  icon: Icons.menu_book_outlined,
                  action: TextButton(
                    onPressed: () => context.go(AppRoutes.selectPlan),
                    child: const Text('Choose a plan'),
                  ),
                );
              case DashboardStatus.success:
                final summary = state.summary!;
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DashboardBloc>().add(
                      const LoadDashboardRequested(),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      GreetingHeader(
                        onNotificationsTap: () => showComingSoon(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ActivePlanCard(plan: summary.plan),
                      const SizedBox(height: AppSpacing.lg),
                      TodayOverviewCard(
                        summary: summary,
                        onTap: () => context.push(AppRoutes.schedule),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      RevisionStreakRow(
                        summary: summary,
                        onRevisionDueTap: () =>
                            context.push(AppRoutes.revisions),
                        onStreakTap: () => context.push(AppRoutes.goals),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: AppNavTab.home,
        onTap: (tab) => handleBottomNavTap(context, tab, AppNavTab.home),
      ),
    );
  }
}
