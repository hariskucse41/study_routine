import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../topic/bloc/topic_bloc.dart';
import '../../topic/bloc/topic_event.dart';
import '../../topic/bloc/topic_state.dart';
import '../../topic/presentation/widgets/topic_visuals.dart';
import '../bloc/study_session_bloc.dart';

class UpdateProgressPage extends StatelessWidget {
  const UpdateProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = getIt<StudySessionBloc>().state;
    return MultiBlocProvider(
      providers: [
        BlocProvider<StudySessionBloc>.value(value: getIt<StudySessionBloc>()),
        BlocProvider<TopicBloc>(create: (_) => getIt<TopicBloc>()),
      ],
      child: _UpdateProgressView(
        topicId: sessionState.topicId,
        sessionId: sessionState.sessionId,
        subjectId: sessionState.subjectId,
        subjectName: sessionState.subjectName,
        topicName: sessionState.topicName,
      ),
    );
  }
}

const _statusOptions = [
  'notStarted',
  'inProgress',
  'completed',
  'revisionNeeded',
  'mastered',
];

class _UpdateProgressView extends StatefulWidget {
  final String? topicId;
  final String? sessionId;
  final String? subjectId;
  final String subjectName;
  final String topicName;

  const _UpdateProgressView({
    required this.topicId,
    required this.sessionId,
    required this.subjectId,
    required this.subjectName,
    required this.topicName,
  });

  @override
  State<_UpdateProgressView> createState() => _UpdateProgressViewState();
}

class _UpdateProgressViewState extends State<_UpdateProgressView> {
  final _notesController = TextEditingController();
  double _percentage = 50;
  String _selectedStatus = 'inProgress';
  int _confidence = 3;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _applyPreset(int value) {
    setState(() {
      _percentage = value.toDouble();
      if (value == 100) _selectedStatus = 'completed';
    });
  }

  void _save() {
    final topicId = widget.topicId;
    final sessionId = widget.sessionId;
    if (topicId == null || sessionId == null) return;

    context.read<TopicBloc>().add(
      UpdateTopicProgressRequested(
        topicId: topicId,
        sessionId: sessionId,
        progressPercentage: _percentage.round(),
        status: _selectedStatus,
        confidenceScore: _confidence.toDouble(),
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
      appBar: AppBar(title: const Text('Update Progress')),
      body: BlocListener<TopicBloc, TopicState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus,
        listener: (context, state) {
          if (state.submissionStatus == TopicSubmissionStatus.submitting) {
            setState(() => _isSubmitting = true);
          } else if (state.submissionStatus == TopicSubmissionStatus.success) {
            setState(() => _isSubmitting = false);
            final subjectId = widget.subjectId;
            context.go(
              subjectId == null
                  ? AppRoutes.home
                  : AppRoutes.subjectDetail(subjectId),
            );
          } else if (state.submissionStatus == TopicSubmissionStatus.failure) {
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
                Text(
                  '${widget.subjectName} • ${widget.topicName}',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CircularProgressIndicator(
                            value: _percentage / 100,
                            strokeWidth: 10,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          '${_percentage.round()}%',
                          style: AppTextStyles.heading1,
                        ),
                      ],
                    ),
                  ),
                ),
                Slider(
                  value: _percentage,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_percentage.round()}%',
                  onChanged: (value) => setState(() => _percentage = value),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  children: [25, 50, 75, 100].map((preset) {
                    return ChoiceChip(
                      label: Text('$preset%'),
                      selected: _percentage.round() == preset,
                      onSelected: (_) => _applyPreset(preset),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Status', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(),
                  items: _statusOptions
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(topicStatusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedStatus = value);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Confidence', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return IconButton(
                      onPressed: () =>
                          setState(() => _confidence = starValue),
                      icon: Icon(
                        starValue <= _confidence
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.warning,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  hint: 'What did you notice while studying this?',
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Update',
                  isLoading: _isSubmitting,
                  onPressed:
                      (_isSubmitting ||
                          widget.topicId == null ||
                          widget.sessionId == null)
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
