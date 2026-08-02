import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/subject_repository.dart';
import 'subject_event.dart';
import 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository _repo;
  StreamSubscription? _subjectsSub;
  StreamSubscription? _detailSub;
  String? _planId;

  SubjectBloc(this._repo) : super(const SubjectState()) {
    on<WatchSubjectsRequested>(_onWatchSubjects);
    on<WatchSubjectDetailRequested>(_onWatchDetail);
    on<SubjectsStreamUpdated>(_onSubjectsStreamUpdated);
    on<SubjectDetailStreamUpdated>(_onSubjectDetailStreamUpdated);
    on<SubjectStreamFailed>(_onStreamFailed);
    on<AddSubjectRequested>(_onAddSubject);
    on<ArchiveSubjectRequested>(_onArchiveSubject);
  }

  Future<void> _onWatchSubjects(
    WatchSubjectsRequested event,
    Emitter<SubjectState> emit,
  ) async {
    _planId = event.planId;
    emit(state.copyWith(status: SubjectStatus.loading));
    await _subjectsSub?.cancel();
    _subjectsSub = _repo.watchSubjects(event.planId).listen(
      (list) => add(SubjectsStreamUpdated(list)),
      onError: (Object e) => add(SubjectStreamFailed(e.toString())),
    );
  }

  Future<void> _onWatchDetail(
    WatchSubjectDetailRequested event,
    Emitter<SubjectState> emit,
  ) async {
    emit(state.copyWith(status: SubjectStatus.loading));
    await _detailSub?.cancel();
    _detailSub = _repo.watchSubject(event.subjectId).listen(
      (subject) => add(SubjectDetailStreamUpdated(subject)),
      onError: (Object e) => add(SubjectStreamFailed(e.toString())),
    );
  }

  void _onSubjectsStreamUpdated(
    SubjectsStreamUpdated event,
    Emitter<SubjectState> emit,
  ) {
    emit(
      state.copyWith(
        status: event.subjects.isEmpty
            ? SubjectStatus.empty
            : SubjectStatus.success,
        subjects: event.subjects,
      ),
    );
  }

  void _onSubjectDetailStreamUpdated(
    SubjectDetailStreamUpdated event,
    Emitter<SubjectState> emit,
  ) {
    emit(
      state.copyWith(
        status: event.subject == null
            ? SubjectStatus.error
            : SubjectStatus.success,
        selectedSubject: event.subject,
        clearSelectedSubject: event.subject == null,
        errorMessage: event.subject == null ? 'Subject not found' : null,
        clearError: event.subject != null,
      ),
    );
  }

  void _onStreamFailed(SubjectStreamFailed event, Emitter<SubjectState> emit) {
    emit(state.copyWith(status: SubjectStatus.error, errorMessage: event.message));
  }

  /// Failures here don't flip [SubjectState.status] — the list/detail view
  /// stays as-is and the page surfaces [errorMessage] as a transient
  /// notice (e.g. a SnackBar) instead of replacing the whole screen.
  Future<void> _onAddSubject(
    AddSubjectRequested event,
    Emitter<SubjectState> emit,
  ) async {
    if (_planId == null) return;
    try {
      await _repo.addSubject(
        planId: _planId!,
        name: event.name,
        description: event.description,
        icon: event.icon,
        color: event.color,
        priority: event.priority,
        order: state.subjects.length,
        estimatedMinutes: event.estimatedMinutes,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onArchiveSubject(
    ArchiveSubjectRequested event,
    Emitter<SubjectState> emit,
  ) async {
    try {
      await _repo.archiveSubject(event.subjectId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subjectsSub?.cancel();
    _detailSub?.cancel();
    return super.close();
  }
}
