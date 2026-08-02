import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../bloc/subject_bloc.dart';
import '../../bloc/subject_event.dart';
import 'subject_visuals.dart';

/// Shows the add-subject bottom sheet, wired to the [SubjectBloc] already
/// active on the calling page.
Future<void> showAddSubjectSheet(BuildContext context) {
  final bloc = context.read<SubjectBloc>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (sheetContext) => BlocProvider.value(
      value: bloc,
      child: const AddSubjectSheet(),
    ),
  );
}

class AddSubjectSheet extends StatefulWidget {
  const AddSubjectSheet({super.key});

  @override
  State<AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<AddSubjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedMinutesController = TextEditingController(text: '60');

  String _selectedIcon = subjectIconChoices.keys.first;
  String _selectedColor = subjectColorChoices.first;
  String _selectedPriority = 'medium';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SubjectBloc>().add(
      AddSubjectRequested(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        priority: _selectedPriority,
        estimatedMinutes: int.tryParse(_estimatedMinutesController.text) ?? 0,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Subject', style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _nameController,
                label: 'Subject Name',
                hint: 'e.g. Mathematics',
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Subject name is required'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add a short description',
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Icon', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: subjectIconChoices.entries.map((entry) {
                  final selected = entry.key == _selectedIcon;
                  return ChoiceChip(
                    label: Icon(
                      entry.value,
                      size: 20,
                      color: selected
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedIcon = entry.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Color', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: subjectColorChoices.map((hex) {
                  final selected = hex == _selectedColor;
                  final color = subjectColorFor(hex);
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = hex),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusFull,
                    ),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: AppColors.textPrimary,
                                width: 2,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
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
              AppTextField(
                controller: _estimatedMinutesController,
                label: 'Estimated Minutes',
                hint: 'e.g. 60',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Save', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
