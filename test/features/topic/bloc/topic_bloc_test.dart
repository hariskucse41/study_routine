import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_routine/features/topic/bloc/topic_bloc.dart';
import 'package:study_routine/features/topic/bloc/topic_event.dart';
import 'package:study_routine/features/topic/bloc/topic_state.dart';
import 'package:study_routine/features/topic/model/topic_model.dart';
import 'package:study_routine/features/topic/repository/topic_repository.dart';

class _MockTopicRepository extends Mock implements TopicRepository {}

const _topic = TopicModel(
  id: 't1',
  userId: 'u1',
  planId: 'p1',
  subjectId: 's1',
  title: 'Chapter 1',
  difficulty: 'medium',
  estimatedMinutes: 30,
  order: 0,
);

void main() {
  late _MockTopicRepository topicRepository;

  setUp(() {
    topicRepository = _MockTopicRepository();
  });

  group('WatchTopicsRequested', () {
    blocTest<TopicBloc, TopicState>(
      'emits [loading, success] when the repository stream yields topics',
      setUp: () {
        when(
          () => topicRepository.watchTopicsForSubject('s1'),
        ).thenAnswer((_) => Stream.value(const [_topic]));
      },
      build: () => TopicBloc(topicRepository),
      act: (bloc) => bloc.add(const WatchTopicsRequested('s1')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const TopicState(status: TopicListStatus.loading),
        const TopicState(status: TopicListStatus.success, topics: [_topic]),
      ],
    );

    blocTest<TopicBloc, TopicState>(
      'emits [loading, error] when the repository stream errors',
      setUp: () {
        when(
          () => topicRepository.watchTopicsForSubject('s1'),
        ).thenAnswer((_) => Stream.error(Exception('permission denied')));
      },
      build: () => TopicBloc(topicRepository),
      act: (bloc) => bloc.add(const WatchTopicsRequested('s1')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const TopicState(status: TopicListStatus.loading),
        isA<TopicState>()
            .having((s) => s.status, 'status', TopicListStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('permission denied'),
            ),
      ],
    );
  });
}
