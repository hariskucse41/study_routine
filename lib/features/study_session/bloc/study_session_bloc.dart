import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/study_session_repository.dart';
import 'study_session_event.dart';
import 'study_session_state.dart';

class StudySessionBloc extends Bloc<StudySessionEvent, StudySessionState> {
  final StudySessionRepository _repo;

  DateTime? _pauseStartedAt;
  Duration _totalPaused = Duration.zero;

  StudySessionBloc(this._repo) : super(const StudySessionState()) {
    on<StartSessionRequested>(_onStartRequested);
    on<PauseSessionRequested>(_onPauseRequested);
    on<EndSessionRequested>(_onEndRequested);
  }

  Future<void> _onStartRequested(
    StartSessionRequested event,
    Emitter<StudySessionState> emit,
  ) async {
    _pauseStartedAt = null;
    _totalPaused = Duration.zero;
    emit(
      state.copyWith(
        phase: StudySessionPhase.starting,
        planId: event.planId,
        subjectId: event.subjectId,
        topicId: event.topicId,
        subjectName: event.subjectName,
        topicName: event.topicName,
        scheduleId: event.scheduleId,
        plannedMinutes: event.plannedMinutes,
        actualMinutes: 0,
        clearError: true,
      ),
    );
    try {
      final startedAt = DateTime.now();
      final sessionId = await _repo.startSession(
        planId: event.planId,
        subjectId: event.subjectId,
        topicId: event.topicId,
        scheduleId: event.scheduleId,
        plannedMinutes: event.plannedMinutes,
      );
      emit(
        state.copyWith(
          phase: StudySessionPhase.active,
          sessionId: sessionId,
          startedAt: startedAt,
        ),
      );
    } catch (e) {
      emit(state.copyWith(phase: StudySessionPhase.error, errorMessage: e.toString()));
    }
  }

  void _onPauseRequested(
    PauseSessionRequested event,
    Emitter<StudySessionState> emit,
  ) {
    if (state.phase == StudySessionPhase.active) {
      _pauseStartedAt = DateTime.now();
      emit(state.copyWith(phase: StudySessionPhase.paused));
    } else if (state.phase == StudySessionPhase.paused) {
      if (_pauseStartedAt != null) {
        _totalPaused += DateTime.now().difference(_pauseStartedAt!);
        _pauseStartedAt = null;
      }
      emit(state.copyWith(phase: StudySessionPhase.active));
    }
  }

  Future<void> _onEndRequested(
    EndSessionRequested event,
    Emitter<StudySessionState> emit,
  ) async {
    final sessionId = state.sessionId;
    final startedAt = state.startedAt;
    if (sessionId == null || startedAt == null) return;

    emit(state.copyWith(phase: StudySessionPhase.ending));

    final endedAt = DateTime.now();
    var totalPaused = _totalPaused;
    if (state.phase == StudySessionPhase.paused && _pauseStartedAt != null) {
      totalPaused += endedAt.difference(_pauseStartedAt!);
    }
    final activeDuration = endedAt.difference(startedAt) - totalPaused;
    final actualMinutes = (activeDuration.inSeconds / 60).round().clamp(
      0,
      1 << 30,
    );

    try {
      await _repo.endSession(
        sessionId: sessionId,
        endedAt: endedAt,
        actualMinutes: actualMinutes,
      );
      emit(
        state.copyWith(
          phase: StudySessionPhase.completed,
          actualMinutes: actualMinutes,
        ),
      );
    } catch (e) {
      emit(state.copyWith(phase: StudySessionPhase.error, errorMessage: e.toString()));
    }
  }
}
