import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/dashboard/repository/dashboard_repository.dart';
import '../../features/goals/bloc/goals_bloc.dart';
import '../../features/progress_analytics/bloc/progress_analytics_bloc.dart';
import '../../features/revision/bloc/revision_bloc.dart';
import '../../features/revision/repository/revision_repository.dart';
import '../../features/schedule/bloc/schedule_bloc.dart';
import '../../features/schedule/repository/schedule_repository.dart';
import '../../features/study_plan/bloc/study_plan_bloc.dart';
import '../../features/study_plan/repository/study_plan_repository.dart';
import '../../features/study_session/bloc/study_session_bloc.dart';
import '../../features/study_session/repository/study_session_repository.dart';
import '../../features/subject/bloc/subject_bloc.dart';
import '../../features/subject/repository/subject_repository.dart';
import '../../features/topic/bloc/topic_bloc.dart';
import '../../features/topic/repository/topic_repository.dart';

final getIt = GetIt.instance;

void setupInjector() {
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  // AuthBloc is a singleton (not a factory like feature Blocs) because it
  // drives the app-wide router redirect and must be shared across screens.
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<StudyPlanRepository>(
    () => StudyPlanRepository(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );
  getIt.registerFactory<StudyPlanBloc>(
    () => StudyPlanBloc(getIt<StudyPlanRepository>()),
  );

  getIt.registerLazySingleton<StudySessionRepository>(
    () => StudySessionRepository(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );
  // StudySessionBloc is a singleton (not a factory like most feature
  // Blocs) because Session Timer -> Session Complete -> Update Progress
  // is one continuous flow across separate route pushes, and Session
  // Complete specifically needs to read the state Session Timer just
  // emitted — there's only ever one active session app-wide anyway.
  getIt.registerLazySingleton<StudySessionBloc>(
    () => StudySessionBloc(getIt<StudySessionRepository>()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepository(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseAuth>(),
      getIt<StudyPlanRepository>(),
      getIt<StudySessionRepository>(),
    ),
  );
  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(getIt<DashboardRepository>()),
  );

  getIt.registerLazySingleton<SubjectRepository>(
    () => SubjectRepository(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );
  getIt.registerFactory<SubjectBloc>(
    () => SubjectBloc(getIt<SubjectRepository>()),
  );

  getIt.registerLazySingleton<TopicRepository>(
    () => TopicRepository(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );
  getIt.registerFactory<TopicBloc>(
    () => TopicBloc(getIt<TopicRepository>()),
  );

  getIt.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepository(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );
  getIt.registerFactory<ScheduleBloc>(
    () => ScheduleBloc(getIt<ScheduleRepository>()),
  );

  getIt.registerLazySingleton<RevisionRepository>(
    () => RevisionRepository(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );
  getIt.registerFactory<RevisionBloc>(
    () => RevisionBloc(getIt<RevisionRepository>()),
  );

  // GoalsBloc has no dedicated repository — it reads directly from the
  // repositories above, per Phase 8 (goal progress is computed live).
  getIt.registerFactory<GoalsBloc>(
    () => GoalsBloc(
      getIt<StudyPlanRepository>(),
      getIt<StudySessionRepository>(),
      getIt<TopicRepository>(),
      getIt<RevisionRepository>(),
    ),
  );

  // ProgressAnalyticsBloc has no dedicated repository either — same
  // rationale as GoalsBloc.
  getIt.registerFactory<ProgressAnalyticsBloc>(
    () => ProgressAnalyticsBloc(
      getIt<StudyPlanRepository>(),
      getIt<SubjectRepository>(),
      getIt<TopicRepository>(),
      getIt<StudySessionRepository>(),
    ),
  );

  getIt.registerLazySingleton<GoRouter>(() => buildRouter(getIt<AuthBloc>()));
  // repeat one repository line + one factory line per feature as you build it
}
