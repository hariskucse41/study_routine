import 'package:equatable/equatable.dart';
import '../../schedule/model/schedule_model.dart';
import '../../subject/model/subject_model.dart';
import '../../topic/model/topic_model.dart';

enum SearchStatus { initial, loading, success, error }

enum SearchSortOption {
  titleAsc,
  priorityHighFirst,
  difficultyEasyFirst,
  progressHighFirst,
  status,
}

int _priorityRank(String priority) =>
    switch (priority) { 'high' => 2, 'medium' => 1, _ => 0 };

int _difficultyRank(String difficulty) =>
    switch (difficulty) { 'easy' => 0, 'medium' => 1, _ => 2 };

class SearchState extends Equatable {
  final SearchStatus status;
  final List<TopicModel> allTopics;
  final List<SubjectModel> subjects;
  final List<ScheduleModel> schedules;
  final String query;
  final String? subjectFilter;
  final String? statusFilter;
  final String? difficultyFilter;
  final String? priorityFilter;
  final SearchSortOption sort;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.allTopics = const [],
    this.subjects = const [],
    this.schedules = const [],
    this.query = '',
    this.subjectFilter,
    this.statusFilter,
    this.difficultyFilter,
    this.priorityFilter,
    this.sort = SearchSortOption.titleAsc,
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<TopicModel>? allTopics,
    List<SubjectModel>? subjects,
    List<ScheduleModel>? schedules,
    String? query,
    String? subjectFilter,
    bool clearSubjectFilter = false,
    String? statusFilter,
    bool clearStatusFilter = false,
    String? difficultyFilter,
    bool clearDifficultyFilter = false,
    String? priorityFilter,
    bool clearPriorityFilter = false,
    SearchSortOption? sort,
    String? errorMessage,
  }) => SearchState(
    status: status ?? this.status,
    allTopics: allTopics ?? this.allTopics,
    subjects: subjects ?? this.subjects,
    schedules: schedules ?? this.schedules,
    query: query ?? this.query,
    subjectFilter: clearSubjectFilter
        ? null
        : (subjectFilter ?? this.subjectFilter),
    statusFilter: clearStatusFilter
        ? null
        : (statusFilter ?? this.statusFilter),
    difficultyFilter: clearDifficultyFilter
        ? null
        : (difficultyFilter ?? this.difficultyFilter),
    priorityFilter: clearPriorityFilter
        ? null
        : (priorityFilter ?? this.priorityFilter),
    sort: sort ?? this.sort,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  Map<String, String> get subjectNames => {
    for (final s in subjects) s.id: s.name,
  };

  /// Earliest upcoming/most-recent schedule entry for a topic, pulled from
  /// the already-loaded schedule list (see SearchBloc) rather than a new
  /// per-topic query.
  ScheduleModel? nextScheduleFor(String topicId) {
    final matches = schedules.where((s) => s.topicId == topicId).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return matches.isEmpty ? null : matches.first;
  }

  List<TopicModel> get results {
    final q = query.trim().toLowerCase();
    final list = allTopics.where((t) {
      if (q.isNotEmpty && !t.title.toLowerCase().contains(q)) return false;
      if (subjectFilter != null && t.subjectId != subjectFilter) return false;
      if (statusFilter != null && t.status != statusFilter) return false;
      if (difficultyFilter != null && t.difficulty != difficultyFilter) {
        return false;
      }
      if (priorityFilter != null && t.priority != priorityFilter) {
        return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case SearchSortOption.titleAsc:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case SearchSortOption.priorityHighFirst:
        list.sort(
          (a, b) =>
              _priorityRank(b.priority).compareTo(_priorityRank(a.priority)),
        );
      case SearchSortOption.difficultyEasyFirst:
        list.sort(
          (a, b) => _difficultyRank(
            a.difficulty,
          ).compareTo(_difficultyRank(b.difficulty)),
        );
      case SearchSortOption.progressHighFirst:
        list.sort(
          (a, b) => b.progressPercentage.compareTo(a.progressPercentage),
        );
      case SearchSortOption.status:
        list.sort((a, b) => a.status.compareTo(b.status));
    }
    return list;
  }

  @override
  List<Object?> get props => [
    status,
    allTopics,
    subjects,
    schedules,
    query,
    subjectFilter,
    statusFilter,
    difficultyFilter,
    priorityFilter,
    sort,
    errorMessage,
  ];
}
