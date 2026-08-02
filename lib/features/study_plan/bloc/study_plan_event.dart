import 'package:equatable/equatable.dart';

sealed class StudyPlanEvent extends Equatable {
  const StudyPlanEvent();

  @override
  List<Object?> get props => [];
}

class CreateStudyPlanRequested extends StudyPlanEvent {
  final String title;
  final String? examName;
  final DateTime? examDate;
  final int dailyTargetMinutes;

  const CreateStudyPlanRequested({
    required this.title,
    this.examName,
    this.examDate,
    required this.dailyTargetMinutes,
  });

  @override
  List<Object?> get props => [title, examName, examDate, dailyTargetMinutes];
}
