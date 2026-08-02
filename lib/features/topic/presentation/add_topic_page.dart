import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/topic_bloc.dart';
import '../bloc/topic_event.dart';
import '../bloc/topic_state.dart';
import 'widgets/topic_visuals.dart';

class AddTopicPage extends StatelessWidget {
  final String subjectId;

  const AddTopicPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TopicBloc>(
      create: (_) =>
          getIt<TopicBloc>()..add(WatchTopicsRequested(subjectId)),
      child: const _AddTopicView(),
    );
  }
}

class _AddTopicView extends StatefulWidget {
  const _AddTopicView();

  @override
  State<_AddTopicView> createState() => _AddTopicViewState();
}

class _AddTopicViewState extends State<_AddTopicView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedMinutesController = TextEditingController(text: '45');

  String? _selectedChapterId;
  String _selectedDifficulty = 'medium';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<TopicBloc>().add(
      AddTopicRequested(
        parentTopicId: _selectedChapterId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        difficulty: _selectedDifficulty,
        estimatedMinutes:
            int.tryParse(_estimatedMinutesController.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Topic')),
      body: BlocConsumer<TopicBloc, TopicState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus,
        listener: (context, state) {
          if (state.submissionStatus == TopicSubmissionStatus.submitting) {
            setState(() => _isSubmitting = true);
          } else if (state.submissionStatus ==
              TopicSubmissionStatus.success) {
            setState(() => _isSubmitting = false);
            context.pop();
          } else if (state.submissionStatus ==
              TopicSubmissionStatus.failure) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            );
          }
        },
        builder: (context, state) {
          final chapters = state.topics.where((t) => t.isChapter).toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: 'Topic Name',
                      hint: 'e.g. Parts of Speech',
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Topic name is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('Select Chapter', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedChapterId,
                      decoration: const InputDecoration(),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No chapter (top-level)'),
                        ),
                        ...chapters.map(
                          (chapter) => DropdownMenuItem<String?>(
                            value: chapter.id,
                            child: Text(chapter.title),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedChapterId = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('Difficulty', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: difficultyChoices.map((difficulty) {
                        final selected = difficulty == _selectedDifficulty;
                        return ChoiceChip(
                          label: Text(difficulty),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedDifficulty = difficulty),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _estimatedMinutesController,
                      label: 'Estimated Time (minutes)',
                      hint: 'e.g. 45',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hint: 'Add a short description',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: 'Save Topic',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
