// Basic smoke test for the splash -> onboarding flow, built in Phase 0.
//
// This deliberately does NOT pump the real StudyRoutineApp: as of Phase 1,
// that app resolves AuthRepository through get_it, which touches real
// FirebaseAuth/FirebaseFirestore singletons — and no Firebase project is
// wired up in this environment (see lib/firebase_options.dart). Proper
// AuthBloc unit tests with mocked dependencies (bloc_test + mocktail) are
// planned for Phase 14. This test instead exercises SplashPage/
// OnboardingPage directly against a minimal local router.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:study_routine/app/router.dart' show AppRoutes;
import 'package:study_routine/features/onboarding/presentation/onboarding_page.dart';
import 'package:study_routine/features/onboarding/presentation/splash_page.dart';

void main() {
  testWidgets('Splash screen shows app name then navigates to onboarding', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final testRouter = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) =>
              const Scaffold(body: Text('Login Placeholder')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: testRouter));
    expect(find.text('Study Routine'), findsOneWidget);

    // Advance past the splash screen's 2s auto-navigate timer.
    await tester.pump(const Duration(seconds: 2, milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Organize Your Study'), findsOneWidget);
  });
}
