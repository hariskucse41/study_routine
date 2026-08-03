import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/study_plan_repository.dart';
import '../repository/syllabus_template_repository.dart';
import 'study_plan_event.dart';
import 'study_plan_state.dart';

class StudyPlanBloc extends Bloc<StudyPlanEvent, StudyPlanState> {
  final StudyPlanRepository _repo;
  final SyllabusTemplateRepository _templateRepo;

  StudyPlanBloc(this._repo, this._templateRepo)
    : super(const StudyPlanState()) {
    on<CreateStudyPlanRequested>(_onCreateRequested);
  }

  Future<void> _onCreateRequested(
    CreateStudyPlanRequested event,
    Emitter<StudyPlanState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StudyPlanSubmissionStatus.submitting,
        clearError: true,
      ),
    );
    try {
      final plan = await _repo.createAndActivatePlan(
        title: event.title,
        examName: event.examName,
        examDate: event.examDate,
        dailyTargetMinutes: event.dailyTargetMinutes,
      );

      // Custom Plan passes no templateName and skips this entirely; a
      // named plan with no matching template (none seeded yet) is treated
      // the same way — an empty plan the user fills in manually.
      if (event.templateName != null) {
        final template = await _templateRepo.fetchTemplateByName(
          event.templateName!,
        );
        if (template != null) {
          await _templateRepo.copyTemplateToPlan(
            templateId: template.id,
            planId: plan.id,
          );
        }
      }

      emit(
        state.copyWith(
          status: StudyPlanSubmissionStatus.success,
          createdPlan: plan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StudyPlanSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
