import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../topic/bloc/topic_bloc.dart';
import '../../topic/bloc/topic_event.dart';
import '../../topic/bloc/topic_state.dart';
import '../../topic/model/topic_model.dart';
import '../../topic/presentation/widgets/topic_tile.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';
import '../model/subject_model.dart';
import 'widgets/subject_visuals.dart';

class SubjectDetailPage extends StatelessWidget {
  final String subjectId;

  const SubjectDetailPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SubjectBloc>(
          create: (_) => getIt<SubjectBloc>()
            ..add(WatchSubjectDetailRequested(subjectId)),
        ),
        BlocProvider<TopicBloc>(
          create: (_) =>
              getIt<TopicBloc>()..add(WatchTopicsRequested(subjectId)),
        ),
      ],
      child: const _SubjectDetailView(),
    );
  }
}

class _SubjectDetailView extends StatelessWidget {
  const _SubjectDetailView();

  Future<void> _confirmArchive(BuildContext context, SubjectModel subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive subject?'),
        content: Text(
          '${subject.name} will be hidden from your subject list. '
          'This cannot be undone from here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<SubjectBloc>().add(ArchiveSubjectRequested(subject.id));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SubjectBloc, SubjectState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null &&
              current.status != SubjectStatus.error,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          },
          builder: (context, state) {
            switch (state.status) {
              case SubjectStatus.initial:
              case SubjectStatus.loading:
                return Scaffold(
                  appBar: AppBar(),
                  body: const LoadingIndicator(),
                );
              case SubjectStatus.error:
              case SubjectStatus.empty:
                return Scaffold(
                  appBar: AppBar(),
                  body: ErrorStateWidget(
                    message: state.errorMessage ?? 'Subject not found',
                  ),
                );
              case SubjectStatus.success:
                final subject = state.selectedSubject;
                if (subject == null) {
                  return const Scaffold(
                    body: LoadingIndicator(),
                  );
                }
                return BlocBuilder<TopicBloc, TopicState>(
                  builder: (context, topicState) {
                    return _SubjectDetailContent(
                      subject: subject,
                      topics: topicState.topics,
                      onArchive: () => _confirmArchive(context, subject),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

class _TopicAggregates {
  final List<TopicModel> chapters;
  final int completed;
  final int inProgress;
  final int notStarted;
  final int overallProgressPercent;
  final int studyMinutes;
  final double avgConfidence;

  const _TopicAggregates({
    required this.chapters,
    required this.completed,
    required this.inProgress,
    required this.notStarted,
    required this.overallProgressPercent,
    required this.studyMinutes,
    required this.avgConfidence,
  });

  factory _TopicAggregates.from(List<TopicModel> topics) {
    final chapters = topics.where((t) => t.isChapter).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (topics.isEmpty) {
      return _TopicAggregates(
        chapters: chapters,
        completed: 0,
        inProgress: 0,
        notStarted: 0,
        overallProgressPercent: 0,
        studyMinutes: 0,
        avgConfidence: 0,
      );
    }

    final completed = topics.where((t) => t.status == 'completed').length;
    final inProgress = topics.where((t) => t.status == 'inProgress').length;
    final notStarted = topics.where((t) => t.status == 'notStarted').length;
    final overallProgress =
        topics.fold<int>(0, (sum, t) => sum + t.progressPercentage) ~/
        topics.length;
    final studyMinutes = topics.fold<int>(0, (sum, t) => sum + t.actualMinutes);
    final avgConfidence =
        topics.fold<double>(0, (sum, t) => sum + t.confidenceScore) /
        topics.length;

    return _TopicAggregates(
      chapters: chapters,
      completed: completed,
      inProgress: inProgress,
      notStarted: notStarted,
      overallProgressPercent: overallProgress,
      studyMinutes: studyMinutes,
      avgConfidence: avgConfidence,
    );
  }
}

class _SubjectDetailContent extends StatelessWidget {
  final SubjectModel subject;
  final List<TopicModel> topics;
  final VoidCallback onArchive;

  const _SubjectDetailContent({
    required this.subject,
    required this.topics,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final color = subjectColorFor(subject.color);
    final aggregates = _TopicAggregates.from(topics);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archive',
            onPressed: onArchive,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
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
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        subjectIconFor(subject.icon),
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subject.name, style: AppTextStyles.heading2),
                          if (subject.description != null)
                            Text(
                              subject.description!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Chapters', style: AppTextStyles.heading3),
              if (aggregates.chapters.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.topicsList(subject.id)),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (aggregates.chapters.isEmpty)
            EmptyStateWidget(
              message: 'No chapters yet. Add a topic to get started.',
              icon: Icons.list_alt_outlined,
              action: TextButton(
                onPressed: () =>
                    context.push(AppRoutes.addTopic(subject.id)),
                child: const Text('+ Add Topic'),
              ),
            )
          else ...[
            for (final chapter in aggregates.chapters) ...[
              TopicTile(
                topic: chapter,
                indented: false,
                onTap: () => context.push(AppRoutes.topicsList(subject.id)),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            TextButton(
              onPressed: () => context.push(AppRoutes.addTopic(subject.id)),
              child: const Text('+ Add Topic'),
            ),
          ],
        ],
      ),
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
