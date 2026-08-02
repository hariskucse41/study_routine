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
import '../bloc/test_result_bloc.dart';
import '../bloc/test_result_event.dart';
import '../bloc/test_result_state.dart';

class AddTestResultPage extends StatelessWidget {
  const AddTestResultPage({super.key});

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
        BlocProvider<TestResultBloc>(create: (_) => getIt<TestResultBloc>()),
      ],
      child: _AddTestResultView(planId: planId),
    );
  }
}

class _AddTestResultView extends StatefulWidget {
  final String? planId;

  const _AddTestResultView({required this.planId});

  @override
  State<_AddTestResultView> createState() => _AddTestResultViewState();
}

class _AddTestResultViewState extends State<_AddTestResultView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _totalController = TextEditingController();
  final _correctController = TextEditingController();
  final _wrongController = TextEditingController();
  final _skippedController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _notesController = TextEditingController();

  String? _selectedSubjectId;
  DateTime _testDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    _correctController.dispose();
    _wrongController.dispose();
    _skippedController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _asInt(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  double get _livePercentage {
    final total = _asInt(_totalController);
    if (total <= 0) return 0;
    return (_asInt(_correctController) / total) * 100;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _testDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _testDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final planId = widget.planId;
    final subjectId = _selectedSubjectId;
    if (planId == null || subjectId == null) return;

    final total = _asInt(_totalController);
    final correct = _asInt(_correctController);
    final wrong = _asInt(_wrongController);
    final skipped = _asInt(_skippedController);
    if (correct + wrong + skipped != total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correct + Wrong + Skipped should add up to Total Questions',
          ),
        ),
      );
      return;
    }

    context.read<TestResultBloc>().add(
      AddTestResultRequested(
        planId: planId,
        subjectId: subjectId,
        title: _titleController.text.trim(),
        totalQuestions: total,
        correctAnswers: correct,
        wrongAnswers: wrong,
        skippedAnswers: skipped,
        durationMinutes: _asInt(_durationController),
        testDate: localMidnight(_testDate),
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
      appBar: AppBar(title: const Text('Add Test Result')),
      body: BlocListener<TestResultBloc, TestResultState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus,
        listener: (context, state) {
          if (state.submissionStatus == TestResultSubmissionStatus.submitting) {
            setState(() => _isSubmitting = true);
          } else if (state.submissionStatus ==
              TestResultSubmissionStatus.success) {
            setState(() => _isSubmitting = false);
            context.pop();
          } else if (state.submissionStatus ==
              TestResultSubmissionStatus.failure) {
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _titleController,
                    label: 'Test Title',
                    hint: 'e.g. Grammar Test',
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Subject', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  BlocBuilder<SubjectBloc, SubjectState>(
                    builder: (context, subjectState) {
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
                        onChanged: (value) =>
                            setState(() => _selectedSubjectId = value),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _totalController,
                          label: 'Total Questions',
                          hint: 'e.g. 50',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              (int.tryParse(value ?? '') ?? 0) <= 0
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          controller: _durationController,
                          label: 'Duration (min)',
                          hint: 'e.g. 30',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _correctController,
                          label: 'Correct',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppTextField(
                          controller: _wrongController,
                          label: 'Wrong',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppTextField(
                          controller: _skippedController,
                          label: 'Skipped',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _totalController,
                      _correctController,
                    ]),
                    builder: (context, _) => Text(
                      'Score: ${_livePercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Test Date', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            formatFriendlyDate(_testDate),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    hint: 'Add a note',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Save Test Result',
                    isLoading: _isSubmitting,
                    onPressed:
                        (_isSubmitting ||
                            widget.planId == null ||
                            _selectedSubjectId == null)
                        ? null
                        : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
