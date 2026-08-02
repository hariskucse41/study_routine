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
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import 'widgets/schedule_tile.dart';

class TodaysRoutinePage extends StatelessWidget {
  const TodaysRoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final planId = context.read<AuthBloc>().state.user?.activeStudyPlanId;
    return BlocProvider<ScheduleBloc>(
      create: (_) {
        final bloc = getIt<ScheduleBloc>();
        if (planId != null) {
          bloc.add(
            WatchScheduleRequested(planId: planId, date: DateTime.now()),
          );
        }
        return bloc;
      },
      child: const _TodaysRoutineView(),
    );
  }
}

class _TodaysRoutineView extends StatelessWidget {
  const _TodaysRoutineView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Today's Routine"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => context.push(AppRoutes.calendar),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addSchedule),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: SafeArea(
        child: BlocConsumer<ScheduleBloc, ScheduleState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    formatFriendlyDate(DateTime.now()),
                    style: AppTextStyles.heading3,
                  ),
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ScheduleState state) {
    switch (state.status) {
      case ScheduleListStatus.initial:
      case ScheduleListStatus.loading:
        return const LoadingIndicator();
      case ScheduleListStatus.error:
        return ErrorStateWidget(
          message: state.errorMessage ?? 'Something went wrong',
        );
      case ScheduleListStatus.empty:
        return EmptyStateWidget(
          message: 'Nothing scheduled for today',
          icon: Icons.event_available_outlined,
          action: TextButton(
            onPressed: () => context.push(AppRoutes.addSchedule),
            child: const Text('+ Add Task'),
          ),
        );
      case ScheduleListStatus.success:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          itemCount: state.schedules.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final schedule = state.schedules[index];
            final subjectName = state.subjectNames[schedule.subjectId] ?? '';
            final topicName = state.topicNames[schedule.topicId] ?? '';
            return ScheduleTile(
              schedule: schedule,
              subjectName: subjectName,
              topicName: topicName,
              onTap: () => context.push(
                AppRoutes.session,
                extra: sessionArgsForSchedule(schedule, subjectName, topicName),
              ),
            );
          },
        );
    }
  }
}
