import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../subject/model/subject_model.dart';
import '../../subject/presentation/widgets/subject_visuals.dart';
import '../../topic/model/topic_model.dart';
import '../bloc/progress_analytics_bloc.dart';
import '../bloc/progress_analytics_event.dart';
import '../bloc/progress_analytics_state.dart';

class WeakTopicsPage extends StatelessWidget {
  const WeakTopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgressAnalyticsBloc>(
      create: (_) =>
          getIt<ProgressAnalyticsBloc>()..add(const LoadWeakTopicsRequested()),
      child: const _WeakTopicsView(),
    );
  }
}

class _WeakTopicsView extends StatefulWidget {
  const _WeakTopicsView();

  @override
  State<_WeakTopicsView> createState() => _WeakTopicsViewState();
}

class _WeakTopicsViewState extends State<_WeakTopicsView> {
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Weak Topics')),
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
                final topics = _selectedSubjectId == null
                    ? state.weakTopics
                    : state.weakTopics
                        .where((t) => t.subjectId == _selectedSubjectId)
                        .toList();
                final subjectsById = {
                  for (final s in state.subjects) s.id: s,
                };

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(
                              label: 'All Subjects',
                              selected: _selectedSubjectId == null,
                              onSelected: () =>
                                  setState(() => _selectedSubjectId = null),
                            ),
                            for (final subject in state.subjects) ...[
                              const SizedBox(width: AppSpacing.sm),
                              _FilterChip(
                                label: subject.name,
                                selected: _selectedSubjectId == subject.id,
                                onSelected: () => setState(
                                  () => _selectedSubjectId = subject.id,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: topics.isEmpty
                          ? const EmptyStateWidget(
                              message: 'No weak topics — great job!',
                              icon: Icons.emoji_events_outlined,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.lg,
                              ),
                              itemCount: topics.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final topic = topics[index];
                                return _WeakTopicTile(
                                  topic: topic,
                                  subject: subjectsById[topic.subjectId],
                                );
                              },
                            ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _WeakTopicTile extends StatelessWidget {
  final TopicModel topic;
  final SubjectModel? subject;

  const _WeakTopicTile({required this.topic, this.subject});

  @override
  Widget build(BuildContext context) {
    final color = subject == null
        ? AppColors.textSecondary
        : subjectColorFor(subject!.color);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: subject == null
                ? const Icon(Icons.menu_book_outlined, size: 18)
                : Icon(subjectIconFor(subject!.icon), color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.title, style: AppTextStyles.bodyLarge),
                Text(
                  subject?.name ?? 'Subject',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.warning),
                  const SizedBox(width: 2),
                  Text(
                    topic.confidenceScore.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${topic.progressPercentage}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
