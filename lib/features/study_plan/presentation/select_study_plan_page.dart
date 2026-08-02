import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/study_plan_bloc.dart';
import '../bloc/study_plan_event.dart';
import '../bloc/study_plan_state.dart';

class _PlanOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? examName;
  final int dailyTargetMinutes;
  final bool isCustom;

  const _PlanOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.examName,
    required this.dailyTargetMinutes,
    this.isCustom = false,
  });
}

const _options = [
  _PlanOption(
    title: 'BCS Preparation',
    subtitle: '50th BCS preparation',
    icon: Icons.school_outlined,
    examName: '50th BCS',
    dailyTargetMinutes: 180,
  ),
  _PlanOption(
    title: 'Bank Job',
    subtitle: 'PO, Clerk, SO etc.',
    icon: Icons.account_balance_outlined,
    examName: 'Bank Job',
    dailyTargetMinutes: 150,
  ),
  _PlanOption(
    title: 'University Admission',
    subtitle: 'DU, JU, RU, CU etc.',
    icon: Icons.apartment_outlined,
    examName: 'University Admission',
    dailyTargetMinutes: 150,
  ),
  _PlanOption(
    title: 'Custom Plan',
    subtitle: 'Create your own plan',
    icon: Icons.edit_outlined,
    dailyTargetMinutes: 120,
    isCustom: true,
  ),
];

class SelectStudyPlanPage extends StatelessWidget {
  const SelectStudyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StudyPlanBloc>(
      create: (_) => getIt<StudyPlanBloc>(),
      child: const _SelectStudyPlanView(),
    );
  }
}

class _SelectStudyPlanView extends StatefulWidget {
  const _SelectStudyPlanView();

  @override
  State<_SelectStudyPlanView> createState() => _SelectStudyPlanViewState();
}

class _SelectStudyPlanViewState extends State<_SelectStudyPlanView> {
  int? _selectedIndex;
  bool _isSubmitting = false;

  Future<void> _onContinue() async {
    if (_selectedIndex == null) return;
    final option = _options[_selectedIndex!];

    if (option.isCustom) {
      final customTitle = await _promptCustomTitle();
      if (customTitle == null || customTitle.trim().isEmpty) return;
      if (!mounted) return;
      context.read<StudyPlanBloc>().add(
        CreateStudyPlanRequested(
          title: customTitle.trim(),
          dailyTargetMinutes: option.dailyTargetMinutes,
        ),
      );
      return;
    }

    context.read<StudyPlanBloc>().add(
      CreateStudyPlanRequested(
        title: option.title,
        examName: option.examName,
        dailyTargetMinutes: option.dailyTargetMinutes,
      ),
    );
  }

  Future<String?> _promptCustomTitle() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Name your plan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. IELTS Prep'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<StudyPlanBloc, StudyPlanState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == StudyPlanSubmissionStatus.submitting) {
            setState(() => _isSubmitting = true);
          } else if (state.status == StudyPlanSubmissionStatus.success) {
            setState(() => _isSubmitting = false);
            // Refresh AuthBloc's cached user so the router redirect (which
            // reads user.activeStudyPlanId) sees the newly created plan
            // and promotes us to /home on its own.
            context.read<AuthBloc>().add(const AuthUserRefreshRequested());
          } else if (state.status == StudyPlanSubmissionStatus.failure) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Your Plan', style: AppTextStyles.heading1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'What are you preparing for?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: ListView.separated(
                    itemCount: _options.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final option = _options[index];
                      final selected = _selectedIndex == index;
                      return _PlanOptionCard(
                        option: option,
                        selected: selected,
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Continue',
                  isLoading: _isSubmitting,
                  onPressed: (_selectedIndex == null || _isSubmitting)
                      ? null
                      : _onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  final _PlanOption option;
  final bool selected;
  final VoidCallback onTap;

  const _PlanOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(option.icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: AppTextStyles.heading3),
                  Text(
                    option.subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}
