import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/navigation/nav_actions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              _initials(user?.name ?? ''),
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (user?.name.isNotEmpty ?? false)
                                ? user!.name
                                : 'Your Profile',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            user?.email ?? '',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.divider),
                _MenuTile(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () => showComingSoon(context),
                ),
                _MenuTile(
                  icon: Icons.tune_outlined,
                  label: 'Study Settings',
                  onTap: () => context.push(AppRoutes.studySettings),
                ),
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  label: 'Reminder Settings',
                  onTap: () => context.push(AppRoutes.studySettings),
                ),
                _MenuTile(
                  icon: Icons.cloud_sync_outlined,
                  label: 'Backup & Sync',
                  onTap: () => showComingSoon(context),
                ),
                _MenuTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () => showComingSoon(context),
                ),
                _MenuTile(
                  icon: Icons.info_outline,
                  label: 'About',
                  onTap: () => showComingSoon(context),
                ),
                const Divider(color: AppColors.divider),
                _MenuTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  iconColor: AppColors.error,
                  labelColor: AppColors.error,
                  onTap: () =>
                      context.read<AuthBloc>().add(const LogoutRequested()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(color: labelColor),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
