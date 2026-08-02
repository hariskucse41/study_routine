import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injector.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/bloc/auth_bloc.dart';

class StudyRoutineApp extends StatelessWidget {
  const StudyRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Study Routine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: getIt<GoRouter>(),
      ),
    );
  }
}
