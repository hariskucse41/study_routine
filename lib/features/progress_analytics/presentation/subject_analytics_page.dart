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
import '../../subject/model/subject_model.dart';
import '../../subject/presentation/widgets/subject_visuals.dart';
import '../../topic/presentation/widgets/topic_tile.dart';
import '../bloc/progress_analytics_bloc.dart';
import '../bloc/progress_analytics_event.dart';
import '../bloc/progress_analytics_state.dart';
import '../model/subject_analytics_data.dart';

class SubjectAnalyticsPage extends StatelessWidget {
  final String subjectId;

  const SubjectAnalyticsPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgressAnalyticsBloc>(
      create: (_) => getIt<ProgressAnalyticsBloc>()
        ..add(LoadSubjectAnalyticsRequested(subjectId)),
      child: const _SubjectAnalyticsView(),
    );
  }
}

class _SubjectAnalyticsView extends StatelessWidget {
  const _SubjectAnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Subject Analytics')),
      body: SafeArea(
        child: BlocBuilder<ProgressAnalyticsBloc, ProgressAnalyticsState>(
          builder: (context, state) {
            switch (state.status) {
              case ProgressStatus.initial:
              case ProgressStatus.loading:
                return const LoadingIndicator();
              case ProgressStatus.error:
                return ErrorStateWidget(
                  message: state.errorMessage ?? 'Something went wrong',
                );
              case ProgressStatus.noPlan:
                return const EmptyStateWidget(
                  message: "You haven't selected a study plan yet.",
                  icon: Icons.insights_outlined,
                );
              case ProgressStatus.success:
                final data = state.subjectAnalytics;
                if (data == null) {
                  return const EmptyStateWidget(
                    message: 'Subject not found',
                    icon: Icons.error_outline,
                  );
                }
                return _SubjectAnalyticsContent(
                  data: data,
                  subjects: state.subjects,
                );
            }
          },
        ),
      ),
    );
  }
}

class _SubjectAnalyticsContent extends StatelessWidget {
  final SubjectAnalyticsData data;
  final List<SubjectModel> subjects;

  const _SubjectAnalyticsContent({required this.data, required this.subjects});

  @override
  Widget build(BuildContext context) {
    final color = subjectColorFor(data.subject.color);
    final aggregates = data.aggregates;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text('Select Subject', style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: data.subject.id,
          decoration: const InputDecoration(),
          items: subjects
              .map(
                (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null && value != data.subject.id) {
              context.read<ProgressAnalyticsBloc>().add(
                LoadSubjectAnalyticsRequested(value),
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(subjectIconFor(data.subject.icon), color: color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(data.subject.name, style: AppTextStyles.heading2),
                  ),
                  Text(
                    '${aggregates.overallProgressPercent}%',
                    style: AppTextStyles.heading2.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _StatChip(label: 'Completed', value: '${aggregates.completed}'),
                  _StatChip(
                    label: 'In Progress',
                    value: '${aggregates.inProgress}',
                  ),
                  _StatChip(
                    label: 'Not Started',
                    value: '${aggregates.notStarted}',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Study Time: ${formatMinutesAsHoursMinutes(aggregates.studyMinutes)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Avg Confidence: ${aggregates.avgConfidence.toStringAsFixed(1)}/5',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text('Chapter Progress', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.md),
        if (aggregates.chapters.isEmpty)
          const EmptyStateWidget(
            message: 'No chapters yet for this subject',
            icon: Icons.list_alt_outlined,
          )
        else
          for (final chapter in aggregates.chapters) ...[
            TopicTile(topic: chapter, indented: false, onTap: () {}),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
