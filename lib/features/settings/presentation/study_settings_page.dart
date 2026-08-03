import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

const _themeOptions = [
  ('system', 'System'),
  ('light', 'Light'),
  ('dark', 'Dark'),
];

const _languageOptions = [('en', 'English'), ('bn', 'বাংলা')];

class StudySettingsPage extends StatelessWidget {
  const StudySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) =>
          getIt<SettingsBloc>()..add(const SettingsDataRequested()),
      child: const _StudySettingsView(),
    );
  }
}

class _StudySettingsView extends StatefulWidget {
  const _StudySettingsView();

  @override
  State<_StudySettingsView> createState() => _StudySettingsViewState();
}

class _StudySettingsViewState extends State<_StudySettingsView> {
  final _goalController = TextEditingController();
  final _breakController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  String _themeMode = 'system';
  String _language = 'en';
  bool _initialized = false;

  @override
  void dispose() {
    _goalController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  void _seedFrom(SettingsState state) {
    _goalController.text = state.dailyStudyGoalMinutes.toString();
    _breakController.text = state.breakReminderMinutes.toString();
    _startTime = _parseTime(state.studyStartTime);
    _endTime = _parseTime(state.studyEndTime);
    _themeMode = state.themeMode;
    _language = state.language;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _save() {
    context.read<SettingsBloc>().add(
      SettingsSaveRequested(
        dailyStudyGoalMinutes: int.tryParse(_goalController.text) ?? 120,
        studyStartTime: _formatTime(_startTime),
        studyEndTime: _formatTime(_endTime),
        breakReminderMinutes: int.tryParse(_breakController.text) ?? 60,
        themeMode: _themeMode,
        language: _language,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Study Settings')),
      body: SafeArea(
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listenWhen: (previous, current) =>
              previous.saveStatus != current.saveStatus ||
              previous.status != current.status,
          listener: (context, state) {
            if (state.status == SettingsStatus.success && !_initialized) {
              _initialized = true;
              _seedFrom(state);
            }
            if (state.saveStatus == SettingsSaveStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved')),
              );
            } else if (state.saveStatus == SettingsSaveStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Something went wrong'),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == SettingsStatus.initial ||
                state.status == SettingsStatus.loading) {
              return const LoadingIndicator();
            }
            if (state.status == SettingsStatus.error) {
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Something went wrong',
              );
            }

            final isSaving = state.saveStatus == SettingsSaveStatus.saving;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _goalController,
                    label: 'Daily Study Goal (minutes)',
                    hint: 'e.g. 120',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Study Start Time',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TimeField(
                    time: _startTime,
                    onTap: () => _pickTime(isStart: true),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Study End Time',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TimeField(
                    time: _endTime,
                    onTap: () => _pickTime(isStart: false),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _breakController,
                    label: 'Break Reminder Interval (minutes)',
                    hint: 'e.g. 60',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Theme', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _themeOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option.$2),
                        selected: _themeMode == option.$1,
                        onSelected: (_) =>
                            setState(() => _themeMode = option.$1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Language', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _languageOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option.$2),
                        selected: _language == option.$1,
                        onSelected: (_) =>
                            setState(() => _language = option.$1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Save Settings',
                    isLoading: isSaving,
                    onPressed: isSaving ? null : _save,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeField({required this.time, required this.onTap});

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
            const Icon(
              Icons.access_time_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(time.format(context), style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
