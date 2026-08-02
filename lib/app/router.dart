import 'package:go_router/go_router.dart';

import '../core/utils/go_router_refresh_stream.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/dashboard/presentation/home_dashboard_page.dart';
import '../features/goals/presentation/goals_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/onboarding/presentation/splash_page.dart';
import '../features/progress_analytics/presentation/progress_dashboard_page.dart';
import '../features/progress_analytics/presentation/subject_analytics_page.dart';
import '../features/progress_analytics/presentation/weak_topics_page.dart';
import '../features/revision/presentation/revision_detail_args.dart';
import '../features/revision/presentation/revision_detail_page.dart';
import '../features/revision/presentation/revision_list_page.dart';
import '../features/schedule/presentation/add_schedule_page.dart';
import '../features/schedule/presentation/calendar_view_page.dart';
import '../features/schedule/presentation/todays_routine_page.dart';
import '../features/study_plan/presentation/select_study_plan_page.dart';
import '../features/study_session/presentation/session_complete_page.dart';
import '../features/study_session/presentation/session_start_args.dart';
import '../features/study_session/presentation/session_timer_page.dart';
import '../features/study_session/presentation/update_progress_page.dart';
import '../features/subject/presentation/subject_detail_page.dart';
import '../features/subject/presentation/subject_list_page.dart';
import '../features/test_result/presentation/add_test_result_page.dart';
import '../features/test_result/presentation/test_results_page.dart';
import '../features/topic/presentation/add_topic_page.dart';
import '../features/topic/presentation/topics_list_page.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const selectPlan = '/select-plan';
  static const home = '/home';
  static const subjects = '/subjects';

  static String subjectDetail(String subjectId) => '/subjects/$subjectId';
  static String topicsList(String subjectId) => '/subjects/$subjectId/topics';
  static String addTopic(String subjectId) => '/subjects/$subjectId/topics/add';

  static const schedule = '/schedule';
  static const addSchedule = '/schedule/add';
  static const calendar = '/schedule/calendar';

  static const session = '/session';
  static const sessionComplete = '/session/complete';
  static const updateProgress = '/session/update-progress';

  static const revisions = '/revisions';
  static String revisionDetail(String topicId) => '/revisions/$topicId';

  static const goals = '/goals';

  static const progress = '/progress';
  static String subjectAnalytics(String subjectId) =>
      '/progress/subjects/$subjectId';
  static const weakTopics = '/progress/weak-topics';

  static const testResults = '/test-results';
  static const addTestResult = '/test-results/add';
}

const _authRoutes = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

/// Builds the app's GoRouter, wired to [authBloc] so navigation stays in
/// sync with both the signed-in state and whether the user has chosen a
/// study plan yet:
///  - unauthenticated users are forced onto /login (except splash/onboarding)
///  - authenticated users with no activeStudyPlanId are forced onto
///    /select-plan
///  - authenticated users with a plan are bounced off auth/select-plan/
///    splash straight to /home
GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final status = authState.status;
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
      final hasActivePlan = authState.user?.activeStudyPlanId != null;
      if (!hasActivePlan) {
        return location == AppRoutes.selectPlan
            ? null
            : AppRoutes.selectPlan;
      }

      final shouldLeave =
          _authRoutes.contains(location) ||
          location == AppRoutes.splash ||
          location == AppRoutes.selectPlan;
      return shouldLeave ? AppRoutes.home : null;
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
        path: AppRoutes.selectPlan,
        builder: (context, state) => const SelectStudyPlanPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeDashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.subjects,
        builder: (context, state) => const SubjectListPage(),
        routes: [
          GoRoute(
            path: ':subjectId',
            builder: (context, state) => SubjectDetailPage(
              subjectId: state.pathParameters['subjectId']!,
            ),
            routes: [
              GoRoute(
                path: 'topics',
                builder: (context, state) => TopicsListPage(
                  subjectId: state.pathParameters['subjectId']!,
                  subjectName: state.extra as String? ?? '',
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => AddTopicPage(
                      subjectId: state.pathParameters['subjectId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.schedule,
        builder: (context, state) => const TodaysRoutinePage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddSchedulePage(),
          ),
          GoRoute(
            path: 'calendar',
            builder: (context, state) => const CalendarViewPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) =>
            SessionTimerPage(args: state.extra as SessionStartArgs),
        routes: [
          GoRoute(
            path: 'complete',
            builder: (context, state) => const SessionCompletePage(),
          ),
          GoRoute(
            path: 'update-progress',
            builder: (context, state) => const UpdateProgressPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.revisions,
        builder: (context, state) => const RevisionListPage(),
        routes: [
          GoRoute(
            path: ':topicId',
            builder: (context, state) => RevisionDetailPage(
              topicId: state.pathParameters['topicId']!,
              args: state.extra as RevisionDetailArgs,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.goals,
        builder: (context, state) => const GoalsPage(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) => const ProgressDashboardPage(),
        routes: [
          GoRoute(
            path: 'subjects/:subjectId',
            builder: (context, state) => SubjectAnalyticsPage(
              subjectId: state.pathParameters['subjectId']!,
            ),
          ),
          GoRoute(
            path: 'weak-topics',
            builder: (context, state) => const WeakTopicsPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.testResults,
        builder: (context, state) => const TestResultsPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddTestResultPage(),
          ),
        ],
      ),
    ],
  );
}
