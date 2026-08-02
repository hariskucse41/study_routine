import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import 'widgets/schedule_tile.dart';

class CalendarViewPage extends StatelessWidget {
  const CalendarViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planId = context.read<AuthBloc>().state.user?.activeStudyPlanId;
    return BlocProvider<ScheduleBloc>(
      create: (_) => getIt<ScheduleBloc>(),
      child: _CalendarView(planId: planId),
    );
  }
}

class _CalendarView extends StatefulWidget {
  final String? planId;

  const _CalendarView({required this.planId});

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  late DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime _selectedDate = localMidnight(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  void _loadMonth() {
    final planId = widget.planId;
    if (planId == null) return;
    final range = rangeForMonth(_focusedMonth);
    context.read<ScheduleBloc>().add(
      WatchScheduleRangeRequested(
        planId: planId,
        start: range.start,
        end: range.end,
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + delta,
      );
    });
    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Calendar')),
      body: SafeArea(
        child: BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            final scheduledDays = state.schedules
                .map((s) => localMidnight(s.scheduledDate))
                .toSet();
            final agenda = state.schedules
                .where(
                  (s) => localMidnight(s.scheduledDate) == _selectedDate,
                )
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedMonth),
                        style: AppTextStyles.heading3,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
                if (state.status == ScheduleListStatus.loading)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: LoadingIndicator(),
                  )
                else
                  _MonthGrid(
                    focusedMonth: _focusedMonth,
                    selectedDate: _selectedDate,
                    scheduledDays: scheduledDays,
                    onDaySelected: (day) =>
                        setState(() => _selectedDate = day),
                  ),
                const Divider(height: AppSpacing.xl),
                Expanded(
                  child: agenda.isEmpty
                      ? EmptyStateWidget(
                          message:
                              'Nothing scheduled for ${formatFriendlyDate(_selectedDate)}',
                          icon: Icons.event_available_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: agenda.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final schedule = agenda[index];
                            final subjectName =
                                state.subjectNames[schedule.subjectId] ?? '';
                            final topicName =
                                state.topicNames[schedule.topicId] ?? '';
                            return ScheduleTile(
                              schedule: schedule,
                              subjectName: subjectName,
                              topicName: topicName,
                              onTap: () => context.push(
                                AppRoutes.session,
                                extra: sessionArgsForSchedule(
                                  schedule,
                                  subjectName,
                                  topicName,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addSchedule),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Set<DateTime> scheduledDays;
  final ValueChanged<DateTime> onDaySelected;

  const _MonthGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.scheduledDays,
    required this.onDaySelected,
  });

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = firstDayOfMonth.weekday % 7;
    final today = localMidnight(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: _weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
              for (var day = 1; day <= daysInMonth; day++)
                _DayCell(
                  date: DateTime(focusedMonth.year, focusedMonth.month, day),
                  isToday:
                      DateTime(focusedMonth.year, focusedMonth.month, day) ==
                      today,
                  isSelected:
                      DateTime(focusedMonth.year, focusedMonth.month, day) ==
                      selectedDate,
                  hasSchedule: scheduledDays.contains(
                    DateTime(focusedMonth.year, focusedMonth.month, day),
                  ),
                  onTap: () => onDaySelected(
                    DateTime(focusedMonth.year, focusedMonth.month, day),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool hasSchedule;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.hasSchedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? AppColors.primary
                : isToday
                ? AppColors.primary.withValues(alpha: 0.1)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.textOnPrimary : null,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (hasSchedule)
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
