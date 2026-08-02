import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/study_plan_repository.dart';
import 'study_plan_event.dart';
import 'study_plan_state.dart';

class StudyPlanBloc extends Bloc<StudyPlanEvent, StudyPlanState> {
  final StudyPlanRepository _repo;

  StudyPlanBloc(this._repo) : super(const StudyPlanState()) {
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
