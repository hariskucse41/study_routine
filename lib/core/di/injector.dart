import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';

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
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));

  getIt.registerLazySingleton<GoRouter>(() => buildRouter(getIt<AuthBloc>()));
  // repeat one repository line + one factory line per feature as you build it
}
