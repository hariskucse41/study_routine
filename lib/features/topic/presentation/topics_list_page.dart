import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../study_session/presentation/session_start_args.dart';
import '../bloc/topic_bloc.dart';
import '../bloc/topic_event.dart';
import '../bloc/topic_state.dart';
import '../model/topic_model.dart';
import 'widgets/topic_tile.dart';

class TopicsListPage extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const TopicsListPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TopicBloc>(
      create: (_) =>
          getIt<TopicBloc>()..add(WatchTopicsRequested(subjectId)),
      child: _TopicsListView(subjectId: subjectId, subjectName: subjectName),
    );
  }
}

class _TopicsListView extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const _TopicsListView({required this.subjectId, required this.subjectName});

  @override
  State<_TopicsListView> createState() => _TopicsListViewState();
}

class _TopicsListViewState extends State<_TopicsListView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSession(TopicModel topic) {
    context.push(
      AppRoutes.session,
      extra: SessionStartArgs(
        planId: topic.planId,
        subjectId: widget.subjectId,
        topicId: topic.id,
        subjectName: widget.subjectName,
        topicName: topic.title,
        plannedMinutes: topic.estimatedMinutes > 0
            ? topic.estimatedMinutes
            : 25,
      ),
    );
  }

  List<Widget> _buildGroupedList(List<TopicModel> topics) {
    final chapters = topics.where((t) => t.isChapter).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final widgets = <Widget>[];
    for (final chapter in chapters) {
      widgets.add(
        TopicTile(
          topic: chapter,
          indented: false,
          onTap: () => _startSession(chapter),
        ),
      );
      final children = topics.where((t) => t.parentTopicId == chapter.id).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      for (final child in children) {
        widgets.add(const SizedBox(height: AppSpacing.sm));
        widgets.add(
          TopicTile(
            topic: child,
            indented: true,
            onTap: () => _startSession(child),
          ),
        );
      }
      widgets.add(const SizedBox(height: AppSpacing.md));
    }
    return widgets;
  }

  List<Widget> _buildFilteredList(List<TopicModel> topics) {
    final query = _query.toLowerCase();
    final matches = topics
        .where((t) => t.title.toLowerCase().contains(query))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return [
      for (final topic in matches) ...[
        TopicTile(
          topic: topic,
          indented: !topic.isChapter,
          onTap: () => _startSession(topic),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Topics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                context.push(AppRoutes.addTopic(widget.subjectId)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search topics...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: BlocConsumer<TopicBloc, TopicState>(
                listenWhen: (previous, current) =>
                    previous.errorMessage != current.errorMessage &&
                    current.errorMessage != null,
                listener: (context, state) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                },
                builder: (context, state) {
                  switch (state.status) {
                    case TopicListStatus.initial:
                    case TopicListStatus.loading:
                      return const LoadingIndicator();
                    case TopicListStatus.error:
                      return ErrorStateWidget(
                        message: state.errorMessage ?? 'Something went wrong',
                      );
                    case TopicListStatus.empty:
                      return EmptyStateWidget(
                        message: 'No topics yet',
                        icon: Icons.list_alt_outlined,
                        action: TextButton(
                          onPressed: () => context.push(
                            AppRoutes.addTopic(widget.subjectId),
                          ),
                          child: const Text('+ Add Topic'),
                        ),
                      );
                    case TopicListStatus.success:
                      final items = _query.isEmpty
                          ? _buildGroupedList(state.topics)
                          : _buildFilteredList(state.topics);
                      if (items.isEmpty) {
                        return const EmptyStateWidget(
                          message: 'No topics match your search',
                          icon: Icons.search_off,
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        children: items,
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
