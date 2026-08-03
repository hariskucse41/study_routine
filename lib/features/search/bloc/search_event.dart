import 'package:equatable/equatable.dart';
import 'search_state.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchDataRequested extends SearchEvent {
  final String planId;
  const SearchDataRequested(this.planId);
  @override
  List<Object?> get props => [planId];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchSubjectFilterChanged extends SearchEvent {
  final String? subjectId;
  const SearchSubjectFilterChanged(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class SearchStatusFilterChanged extends SearchEvent {
  final String? status;
  const SearchStatusFilterChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class SearchDifficultyFilterChanged extends SearchEvent {
  final String? difficulty;
  const SearchDifficultyFilterChanged(this.difficulty);
  @override
  List<Object?> get props => [difficulty];
}

class SearchPriorityFilterChanged extends SearchEvent {
  final String? priority;
  const SearchPriorityFilterChanged(this.priority);
  @override
  List<Object?> get props => [priority];
}

class SearchSortChanged extends SearchEvent {
  final SearchSortOption sort;
  const SearchSortChanged(this.sort);
  @override
  List<Object?> get props => [sort];
}
