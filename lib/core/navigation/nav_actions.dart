import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Shared behavior for the persistent bottom nav bar, reused by every
/// top-level tab screen (Home, Subjects, Progress, and a future Settings
/// screen) so "coming soon" tabs and the Logout action stay consistent
/// and don't need to be re-implemented per page.
void handleBottomNavTap(
  BuildContext context,
  AppNavTab tapped,
  AppNavTab current,
) {
  if (tapped == current) return;
  switch (tapped) {
    case AppNavTab.home:
      context.go(AppRoutes.home);
    case AppNavTab.plan:
      context.go(AppRoutes.subjects);
    case AppNavTab.more:
      showMoreMenu(context);
    case AppNavTab.add:
      context.push(AppRoutes.addSchedule);
    case AppNavTab.progress:
      context.go(AppRoutes.progress);
  }
}

void showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Coming in a later phase')));
}

void showMoreMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Goals & Streaks'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              context.push(AppRoutes.goals);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              showComingSoon(context);
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
