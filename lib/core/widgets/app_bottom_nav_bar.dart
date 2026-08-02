import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppNavTab { home, plan, add, progress, more }

/// Persistent bottom navigation shell shown across the main app screens
/// (mockup screens 09+). Only Home is wired to a real destination this
/// phase — the other tabs light up in later phases (Subjects: Phase 3,
/// Schedule: Phase 5, Progress: Phase 9, Settings: Phase 12); until then
/// [onTap] is expected to show a "coming soon" affordance for them.
class AppBottomNavBar extends StatelessWidget {
  final AppNavTab current;
  final ValueChanged<AppNavTab> onTap;

  const AppBottomNavBar({
    super.key,
    required this.current,
    required this.onTap,
  });

  static const _tabs = [
    (tab: AppNavTab.home, icon: Icons.home_outlined, label: 'Home'),
    (tab: AppNavTab.plan, icon: Icons.event_note_outlined, label: 'Plan'),
    (tab: AppNavTab.add, icon: Icons.add_circle, label: ''),
    (
      tab: AppNavTab.progress,
      icon: Icons.insights_outlined,
      label: 'Progress',
    ),
    (tab: AppNavTab.more, icon: Icons.menu_outlined, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((t) {
              final isSelected = t.tab == current;
              final isAdd = t.tab == AppNavTab.add;
              final color = isSelected || isAdd
                  ? AppColors.primary
                  : AppColors.textSecondary;
              return InkWell(
                onTap: () => onTap(t.tab),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(t.icon, color: color, size: isAdd ? 32 : 24),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
