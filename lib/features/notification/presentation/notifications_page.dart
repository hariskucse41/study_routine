import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../model/notification_item.dart';
import 'widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (_) =>
          getIt<NotificationBloc>()..add(const LoadNotificationsRequested()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  bool _rationaleShown = false;

  Future<void> _maybeShowRationale(NotificationState state) async {
    if (_rationaleShown || state.permissionGranted != null) return;
    _rationaleShown = true;

    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Stay on track'),
        content: const Text(
          'Enable notifications to get study reminders, revision alerts, '
          'and daily goal check-ins right when you need them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (shouldRequest == true && mounted) {
      context.read<NotificationBloc>().add(const RequestPermissionRequested());
    }
  }

  Map<DateTime, List<NotificationItem>> _groupByDay(
    List<NotificationItem> items,
  ) {
    final grouped = <DateTime, List<NotificationItem>>{};
    for (final item in items) {
      final day = localMidnight(item.timestamp);
      grouped.putIfAbsent(day, () => []).add(item);
    }
    return grouped;
  }

  String _dayLabel(DateTime day) {
    final today = localMidnight(DateTime.now());
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return formatFriendlyDate(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) => _maybeShowRationale(state),
          builder: (context, state) {
            switch (state.status) {
              case NotificationLoadStatus.initial:
              case NotificationLoadStatus.loading:
                return const LoadingIndicator();
              case NotificationLoadStatus.error:
                return ErrorStateWidget(
                  message: state.errorMessage ?? 'Something went wrong',
                );
              case NotificationLoadStatus.noPlan:
                return const EmptyStateWidget(
                  message: "You haven't selected a study plan yet.",
                  icon: Icons.notifications_outlined,
                );
              case NotificationLoadStatus.success:
                if (state.items.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No notifications yet',
                    icon: Icons.notifications_none_outlined,
                  );
                }
                final grouped = _groupByDay(state.items);
                final days = grouped.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    for (final day in days) ...[
                      Text(_dayLabel(day), style: AppTextStyles.heading3),
                      const SizedBox(height: AppSpacing.sm),
                      for (final item in grouped[day]!) ...[
                        NotificationTile(item: item),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
