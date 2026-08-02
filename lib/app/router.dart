import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/go_router_refresh_stream.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/onboarding/presentation/splash_page.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
}

const _authRoutes = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

/// Builds the app's GoRouter, wired to [authBloc] so navigation stays in
/// sync with the signed-in state: unauthenticated users are forced onto
/// /login (except while on splash/onboarding), and authenticated users are
/// bounced off the auth screens straight to /home.
GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final status = authBloc.state.status;
      final location = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        // Initial auth check still resolving — splash owns this window.
        return null;
      }

      if (status == AuthStatus.unauthenticated) {
        final onSplashOrOnboarding =
            location == AppRoutes.splash || location == AppRoutes.onboarding;
        if (onSplashOrOnboarding || _authRoutes.contains(location)) {
          return null;
        }
        return AppRoutes.login;
      }

      // authenticated
      if (_authRoutes.contains(location) || location == AppRoutes.splash) {
        return AppRoutes.home;
      }
      return null;
    },
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
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _HomePlaceholderPage(),
      ),
    ],
  );
}

/// Temporary placeholder for the Home Dashboard, built for real in Phase 2.
/// Includes a working logout action so the auth flow is testable end-to-end.
class _HomePlaceholderPage extends StatelessWidget {
  const _HomePlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: const Center(
        child: Text('Home Dashboard — coming in Phase 2'),
      ),
    );
  }
}
