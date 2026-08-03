import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_routine/features/schedule/bloc/schedule_bloc.dart';
import 'package:study_routine/features/schedule/bloc/schedule_event.dart';
import 'package:study_routine/features/schedule/bloc/schedule_state.dart';
import 'package:study_routine/features/schedule/model/schedule_model.dart';
import 'package:study_routine/features/schedule/repository/schedule_repository.dart';

class _MockScheduleRepository extends Mock implements ScheduleRepository {}

final _schedule = ScheduleModel(
  id: 'sc1',
  userId: 'u1',
  planId: 'p1',
  subjectId: 's1',
  topicId: 't1',
  scheduledDate: DateTime(2026, 1, 1),
  startTime: '08:00',
  plannedMinutes: 45,
);

void main() {
  late _MockScheduleRepository scheduleRepository;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  setUp(() {
    scheduleRepository = _MockScheduleRepository();
  });

  group('WatchScheduleRequested', () {
    blocTest<ScheduleBloc, ScheduleState>(
      'emits [loading, success] with resolved subject/topic names when the '
      'repository stream yields schedules',
      setUp: () {
        when(
          () => scheduleRepository.watchSchedules(
            planId: any(named: 'planId'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        ).thenAnswer((_) => Stream.value([_schedule]));
        when(
          () => scheduleRepository.fetchSubjectNames({'s1'}),
        ).thenAnswer((_) async => {'s1': 'Bangla'});
        when(
          () => scheduleRepository.fetchTopicNames({'t1'}),
        ).thenAnswer((_) async => {'t1': 'Chapter 1'});
      },
      build: () => ScheduleBloc(scheduleRepository),
      act: (bloc) => bloc.add(
        WatchScheduleRequested(planId: 'p1', date: DateTime(2026, 1, 1)),
      ),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const ScheduleState(status: ScheduleListStatus.loading),
        ScheduleState(
          status: ScheduleListStatus.success,
          schedules: [_schedule],
          subjectNames: const {'s1': 'Bangla'},
          topicNames: const {'t1': 'Chapter 1'},
        ),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'emits [loading, error] when the repository stream errors',
      setUp: () {
        when(
          () => scheduleRepository.watchSchedules(
            planId: any(named: 'planId'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        ).thenAnswer((_) => Stream.error(Exception('offline')));
      },
      build: () => ScheduleBloc(scheduleRepository),
      act: (bloc) => bloc.add(
        WatchScheduleRequested(planId: 'p1', date: DateTime(2026, 1, 1)),
      ),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const ScheduleState(status: ScheduleListStatus.loading),
        isA<ScheduleState>()
            .having((s) => s.status, 'status', ScheduleListStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('offline')),
      ],
    );
  });
}
