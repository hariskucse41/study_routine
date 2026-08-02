import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming in a later phase')),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showComingSoon(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.read<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, AppNavTab tab) {
    if (tab == AppNavTab.home) return;
    if (tab == AppNavTab.more) {
      _showMoreMenu(context);
      return;
    }
    _showComingSoon(context);
  }

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
                        onNotificationsTap: () => _showComingSoon(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ActivePlanCard(plan: summary.plan),
                      const SizedBox(height: AppSpacing.lg),
                      TodayOverviewCard(summary: summary),
                      const SizedBox(height: AppSpacing.lg),
                      RevisionStreakRow(summary: summary),
                    ],
                  ),
                );
            }
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: AppNavTab.home,
        onTap: (tab) => _onNavTap(context, tab),
      ),
    );
  }
}
