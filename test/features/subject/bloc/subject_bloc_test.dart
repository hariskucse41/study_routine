import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_routine/features/subject/bloc/subject_bloc.dart';
import 'package:study_routine/features/subject/bloc/subject_event.dart';
import 'package:study_routine/features/subject/bloc/subject_state.dart';
import 'package:study_routine/features/subject/model/subject_model.dart';
import 'package:study_routine/features/subject/repository/subject_repository.dart';

class _MockSubjectRepository extends Mock implements SubjectRepository {}

const _subject = SubjectModel(
  id: 's1',
  userId: 'u1',
  planId: 'p1',
  name: 'Bangla',
  icon: 'book',
  color: '5B3FD6',
  priority: 'medium',
  order: 0,
  estimatedMinutes: 60,
);

void main() {
  late _MockSubjectRepository subjectRepository;

  setUp(() {
    subjectRepository = _MockSubjectRepository();
  });

  group('WatchSubjectsRequested', () {
    blocTest<SubjectBloc, SubjectState>(
      'emits [loading, success] when the repository stream yields subjects',
      setUp: () {
        when(
          () => subjectRepository.watchSubjects('p1'),
        ).thenAnswer((_) => Stream.value(const [_subject]));
      },
      build: () => SubjectBloc(subjectRepository),
      act: (bloc) => bloc.add(const WatchSubjectsRequested('p1')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const SubjectState(status: SubjectStatus.loading),
        const SubjectState(
          status: SubjectStatus.success,
          subjects: [_subject],
        ),
      ],
    );

    blocTest<SubjectBloc, SubjectState>(
      'emits [loading, error] when the repository stream errors',
      setUp: () {
        when(
          () => subjectRepository.watchSubjects('p1'),
        ).thenAnswer((_) => Stream.error(Exception('network down')));
      },
      build: () => SubjectBloc(subjectRepository),
      act: (bloc) => bloc.add(const WatchSubjectsRequested('p1')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const SubjectState(status: SubjectStatus.loading),
        isA<SubjectState>()
            .having((s) => s.status, 'status', SubjectStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('network down'),
            ),
      ],
    );
  });
}
