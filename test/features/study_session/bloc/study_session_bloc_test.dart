import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_routine/features/study_session/bloc/study_session_bloc.dart';
import 'package:study_routine/features/study_session/bloc/study_session_event.dart';
import 'package:study_routine/features/study_session/bloc/study_session_state.dart';
import 'package:study_routine/features/study_session/repository/study_session_repository.dart';

class _MockStudySessionRepository extends Mock
    implements StudySessionRepository {}

const _startEvent = StartSessionRequested(
  planId: 'p1',
  subjectId: 's1',
  topicId: 't1',
  subjectName: 'Bangla',
  topicName: 'Chapter 1',
  plannedMinutes: 30,
);

void main() {
  late _MockStudySessionRepository studySessionRepository;

  setUp(() {
    studySessionRepository = _MockStudySessionRepository();
  });

  group('StartSessionRequested', () {
    blocTest<StudySessionBloc, StudySessionState>(
      'emits [starting, active] when the repository starts the session',
      setUp: () {
        when(
          () => studySessionRepository.startSession(
            planId: any(named: 'planId'),
            subjectId: any(named: 'subjectId'),
            topicId: any(named: 'topicId'),
            scheduleId: any(named: 'scheduleId'),
            plannedMinutes: any(named: 'plannedMinutes'),
          ),
        ).thenAnswer((_) async => 'session-1');
      },
      build: () => StudySessionBloc(studySessionRepository),
      act: (bloc) => bloc.add(_startEvent),
      expect: () => [
        isA<StudySessionState>()
            .having((s) => s.phase, 'phase', StudySessionPhase.starting)
            .having((s) => s.planId, 'planId', 'p1')
            .having((s) => s.subjectId, 'subjectId', 's1')
            .having((s) => s.topicId, 'topicId', 't1'),
        isA<StudySessionState>()
            .having((s) => s.phase, 'phase', StudySessionPhase.active)
            .having((s) => s.sessionId, 'sessionId', 'session-1')
            .having((s) => s.startedAt, 'startedAt', isNotNull),
      ],
      verify: (_) {
        verify(
          () => studySessionRepository.startSession(
            planId: 'p1',
            subjectId: 's1',
            topicId: 't1',
            scheduleId: null,
            plannedMinutes: 30,
          ),
        ).called(1);
      },
    );

    blocTest<StudySessionBloc, StudySessionState>(
      'emits [starting, error] when the repository throws',
      setUp: () {
        when(
          () => studySessionRepository.startSession(
            planId: any(named: 'planId'),
            subjectId: any(named: 'subjectId'),
            topicId: any(named: 'topicId'),
            scheduleId: any(named: 'scheduleId'),
            plannedMinutes: any(named: 'plannedMinutes'),
          ),
        ).thenThrow(Exception('firestore unavailable'));
      },
      build: () => StudySessionBloc(studySessionRepository),
      act: (bloc) => bloc.add(_startEvent),
      expect: () => [
        isA<StudySessionState>().having(
          (s) => s.phase,
          'phase',
          StudySessionPhase.starting,
        ),
        isA<StudySessionState>()
            .having((s) => s.phase, 'phase', StudySessionPhase.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('firestore unavailable'),
            ),
      ],
    );
  });
}
