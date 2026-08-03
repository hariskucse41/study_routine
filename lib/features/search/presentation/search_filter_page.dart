import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../study_session/presentation/session_start_args.dart';
import '../../topic/model/topic_model.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import 'widgets/filter_section.dart';
import 'widgets/search_result_tile.dart';

const _statusOptions = [
  ('notStarted', 'Not Started'),
  ('inProgress', 'In Progress'),
  ('completed', 'Completed'),
  ('revisionNeeded', 'Revision Needed'),
  ('mastered', 'Mastered'),
];

const _difficultyOptions = [
  ('easy', 'Easy'),
  ('medium', 'Medium'),
  ('hard', 'Hard'),
];

const _priorityOptions = [
  ('low', 'Low'),
  ('medium', 'Medium'),
  ('high', 'High'),
];

const _sortLabels = {
  SearchSortOption.titleAsc: 'Title (A-Z)',
  SearchSortOption.priorityHighFirst: 'Priority (High First)',
  SearchSortOption.difficultyEasyFirst: 'Difficulty (Easy First)',
  SearchSortOption.progressHighFirst: 'Progress (High First)',
  SearchSortOption.status: 'Status',
};

class SearchFilterPage extends StatelessWidget {
  const SearchFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planId = context.read<AuthBloc>().state.user?.activeStudyPlanId;
    return BlocProvider<SearchBloc>(
      create: (_) {
        final bloc = getIt<SearchBloc>();
        if (planId != null) bloc.add(SearchDataRequested(planId));
        return bloc;
      },
      child: _SearchFilterView(hasPlan: planId != null),
    );
  }
}

class _SearchFilterView extends StatefulWidget {
  final bool hasPlan;

  const _SearchFilterView({required this.hasPlan});

  @override
  State<_SearchFilterView> createState() => _SearchFilterViewState();
}

class _SearchFilterViewState extends State<_SearchFilterView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSession(TopicModel topic, String subjectName) {
    context.push(
      AppRoutes.session,
      extra: SessionStartArgs(
        planId: topic.planId,
        subjectId: topic.subjectId,
        topicId: topic.id,
        subjectName: subjectName,
        topicName: topic.title,
        plannedMinutes: topic.estimatedMinutes > 0
            ? topic.estimatedMinutes
            : 25,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Search & Filter')),
      body: SafeArea(
        child: !widget.hasPlan
            ? const EmptyStateWidget(
                message: "You haven't selected a study plan yet.",
                icon: Icons.menu_book_outlined,
              )
            : BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.status == SearchStatus.initial ||
                      state.status == SearchStatus.loading) {
                    return const LoadingIndicator();
                  }
                  if (state.status == SearchStatus.error) {
                    return ErrorStateWidget(
                      message: state.errorMessage ?? 'Something went wrong',
                    );
                  }

                  final subjectNames = state.subjectNames;
                  final results = state.results;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          0,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => context.read<SearchBloc>().add(
                            SearchQueryChanged(value),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search topics...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FilterSection(
                              label: 'Subject',
                              options: [
                                for (final s in state.subjects) (s.id, s.name),
                              ],
                              selected: state.subjectFilter,
                              onChanged: (v) => context.read<SearchBloc>().add(
                                SearchSubjectFilterChanged(v),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FilterSection(
                              label: 'Status',
                              options: _statusOptions,
                              selected: state.statusFilter,
                              onChanged: (v) => context.read<SearchBloc>().add(
                                SearchStatusFilterChanged(v),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FilterSection(
                              label: 'Difficulty',
                              options: _difficultyOptions,
                              selected: state.difficultyFilter,
                              onChanged: (v) => context.read<SearchBloc>().add(
                                SearchDifficultyFilterChanged(v),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FilterSection(
                              label: 'Priority',
                              options: _priorityOptions,
                              selected: state.priorityFilter,
                              onChanged: (v) => context.read<SearchBloc>().add(
                                SearchPriorityFilterChanged(v),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                const Text(
                                  'Sort By',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: DropdownButtonFormField<SearchSortOption>(
                                    initialValue: state.sort,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                    ),
                                    items: [
                                      for (final entry in _sortLabels.entries)
                                        DropdownMenuItem(
                                          value: entry.key,
                                          child: Text(entry.value),
                                        ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        context.read<SearchBloc>().add(
                                          SearchSortChanged(value),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: results.isEmpty
                            ? EmptyStateWidget(
                                message: state.allTopics.isEmpty
                                    ? 'No topics yet'
                                    : 'No topics match your filters',
                                icon: Icons.search_off,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.lg,
                                  0,
                                  AppSpacing.lg,
                                  AppSpacing.lg,
                                ),
                                itemCount: results.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final topic = results[index];
                                  final subjectName =
                                      subjectNames[topic.subjectId] ?? '';
                                  return SearchResultTile(
                                    topic: topic,
                                    subjectName: subjectName,
                                    nextSchedule: state.nextScheduleFor(
                                      topic.id,
                                    ),
                                    onTap: () =>
                                        _startSession(topic, subjectName),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
