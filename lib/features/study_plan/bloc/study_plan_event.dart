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

  /// Name of the syllabus_templates doc to copy into the new plan
  /// (matched against its `name` field), or null to skip — the Custom
  /// Plan path always passes null.
  final String? templateName;

  const CreateStudyPlanRequested({
    required this.title,
    this.examName,
    this.examDate,
    required this.dailyTargetMinutes,
    this.templateName,
  });

  @override
  List<Object?> get props => [
    title,
    examName,
    examDate,
    dailyTargetMinutes,
    templateName,
  ];
}
