import 'package:equatable/equatable.dart';
import '../model/subject_model.dart';

enum SubjectStatus { initial, loading, success, empty, error }

class SubjectState extends Equatable {
  final SubjectStatus status;
  final List<SubjectModel> subjects;
  final SubjectModel? selectedSubject;
  final String? errorMessage;

  const SubjectState({
    this.status = SubjectStatus.initial,
    this.subjects = const [],
    this.selectedSubject,
    this.errorMessage,
  });

  SubjectState copyWith({
    SubjectStatus? status,
    List<SubjectModel>? subjects,
    SubjectModel? selectedSubject,
    bool clearSelectedSubject = false,
    String? errorMessage,
    bool clearError = false,
  }) => SubjectState(
    status: status ?? this.status,
    subjects: subjects ?? this.subjects,
    selectedSubject: clearSelectedSubject
        ? null
        : (selectedSubject ?? this.selectedSubject),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, subjects, selectedSubject, errorMessage];
}
