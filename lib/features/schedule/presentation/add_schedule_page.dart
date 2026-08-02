import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../subject/bloc/subject_bloc.dart';
import '../../subject/bloc/subject_event.dart';
import '../../subject/bloc/subject_state.dart';
import '../../topic/bloc/topic_bloc.dart';
import '../../topic/bloc/topic_event.dart';
import '../../topic/bloc/topic_state.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

class AddSchedulePage extends StatelessWidget {
  const AddSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final planId = context.read<AuthBloc>().state.user?.activeStudyPlanId;
    return MultiBlocProvider(
      providers: [
        BlocProvider<SubjectBloc>(
          create: (_) {
            final bloc = getIt<SubjectBloc>();
            if (planId != null) bloc.add(WatchSubjectsRequested(planId));
            return bloc;
          },
        ),
        BlocProvider<TopicBloc>(create: (_) => getIt<TopicBloc>()),
        BlocProvider<ScheduleBloc>(create: (_) => getIt<ScheduleBloc>()),
      ],
      child: _AddScheduleView(planId: planId),
    );
  }
}

class _AddScheduleView extends StatefulWidget {
  final String? planId;

  const _AddScheduleView({required this.planId});

  @override
  State<_AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<_AddScheduleView> {
  final _plannedMinutesController = TextEditingController(text: '45');
  final _reminderMinutesController = TextEditingController(text: '10');
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String? _selectedSubjectId;
  String? _selectedTopicId;
  String _selectedPriority = 'medium';
  bool _reminderEnabled = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _plannedMinutesController.dispose();
    _reminderMinutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _onSubjectChanged(String? subjectId) {
    setState(() {
      _selectedSubjectId = subjectId;
      _selectedTopicId = null;
    });
    if (subjectId != null) {
      context.read<TopicBloc>().add(WatchTopicsRequested(subjectId));
    }
  }

  void _save() {
    final planId = widget.planId;
    final subjectId = _selectedSubjectId;
    final topicId = _selectedTopicId;
    if (planId == null || subjectId == null || topicId == null) return;

    final startTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime.minute.toString().padLeft(2, '0')}';

    context.read<ScheduleBloc>().add(
      AddScheduleRequested(
        planId: planId,
        subjectId: subjectId,
        topicId: topicId,
        scheduledDate: localMidnight(_selectedDate),
        startTime: startTime,
        plannedMinutes: int.tryParse(_plannedMinutesController.text) ?? 0,
        priority: _selectedPriority,
        reminderEnabled: _reminderEnabled,
        reminderMinutesBefore:
            int.tryParse(_reminderMinutesController.text) ?? 10,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Schedule')),
      body: BlocListener<ScheduleBloc, ScheduleState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus,
        listener: (context, state) {
          if (state.submissionStatus == ScheduleSubmissionStatus.submitting) {
            setState(() => _isSubmitting = true);
          } else if (state.submissionStatus ==
              ScheduleSubmissionStatus.success) {
            setState(() => _isSubmitting = false);
            context.pop();
          } else if (state.submissionStatus ==
              ScheduleSubmissionStatus.failure) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Date', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                _PickerField(
                  label: formatFriendlyDate(_selectedDate),
                  icon: Icons.calendar_today_outlined,
                  onTap: _pickDate,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Select Subject', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                BlocBuilder<SubjectBloc, SubjectState>(
                  builder: (context, subjectState) {
                    if (subjectState.status == SubjectStatus.empty) {
                      return Text(
                        'Add a subject first before scheduling a task.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedSubjectId,
                      decoration: const InputDecoration(
                        hintText: 'Choose a subject',
                      ),
                      items: subjectState.subjects
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          )
                          .toList(),
                      onChanged: _onSubjectChanged,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Select Topic', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                BlocBuilder<TopicBloc, TopicState>(
                  builder: (context, topicState) {
                    if (_selectedSubjectId == null) {
                      return Text(
                        'Choose a subject to see its topics.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                    if (topicState.status == TopicListStatus.empty) {
                      return Text(
                        'This subject has no topics yet.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    }
                    final topics = topicState.topics
                      ..sort((a, b) => a.order.compareTo(b.order));
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedTopicId,
                      decoration: const InputDecoration(
                        hintText: 'Choose a topic',
                      ),
                      items: topics
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(t.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedTopicId = value),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Start Time', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                _PickerField(
                  label: _selectedTime.format(context),
                  icon: Icons.access_time_outlined,
                  onTap: _pickTime,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _plannedMinutesController,
                  label: 'Duration (minutes)',
                  hint: 'e.g. 45',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Priority', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: ['low', 'medium', 'high'].map((priority) {
                    final selected = priority == _selectedPriority;
                    return ChoiceChip(
                      label: Text(priority),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedPriority = priority),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reminder'),
                  value: _reminderEnabled,
                  onChanged: (value) =>
                      setState(() => _reminderEnabled = value),
                ),
                if (_reminderEnabled)
                  AppTextField(
                    controller: _reminderMinutesController,
                    label: 'Minutes before',
                    hint: 'e.g. 10',
                    keyboardType: TextInputType.number,
                  ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  hint: 'Add a note',
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Save Task',
                  isLoading: _isSubmitting,
                  onPressed:
                      (_isSubmitting ||
                          widget.planId == null ||
                          _selectedSubjectId == null ||
                          _selectedTopicId == null)
                      ? null
                      : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
