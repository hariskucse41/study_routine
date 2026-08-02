import 'package:equatable/equatable.dart';
import '../model/subject_model.dart';

sealed class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object?> get props => [];
}

class WatchSubjectsRequested extends SubjectEvent {
  final String planId;
  const WatchSubjectsRequested(this.planId);
  @override
  List<Object?> get props => [planId];
}

class WatchSubjectDetailRequested extends SubjectEvent {
  final String subjectId;
  const WatchSubjectDetailRequested(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

/// Dispatched internally by SubjectBloc in response to Firestore streams —
/// not intended to be added by the UI.
class SubjectsStreamUpdated extends SubjectEvent {
  final List<SubjectModel> subjects;
  const SubjectsStreamUpdated(this.subjects);
  @override
  List<Object?> get props => [subjects];
}

class SubjectDetailStreamUpdated extends SubjectEvent {
  final SubjectModel? subject;
  const SubjectDetailStreamUpdated(this.subject);
  @override
  List<Object?> get props => [subject];
}

class SubjectStreamFailed extends SubjectEvent {
  final String message;
  const SubjectStreamFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class AddSubjectRequested extends SubjectEvent {
  final String name;
  final String? description;
  final String icon;
  final String color;
  final String priority;
  final int estimatedMinutes;

  const AddSubjectRequested({
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    required this.priority,
    required this.estimatedMinutes,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    icon,
    color,
    priority,
    estimatedMinutes,
  ];
}

class ArchiveSubjectRequested extends SubjectEvent {
  final String subjectId;
  const ArchiveSubjectRequested(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}
