import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_routine/features/auth/bloc/auth_bloc.dart';
import 'package:study_routine/features/auth/bloc/auth_event.dart';
import 'package:study_routine/features/auth/bloc/auth_state.dart';
import 'package:study_routine/features/auth/model/app_user_model.dart';
import 'package:study_routine/features/auth/repository/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockUser extends Mock implements User {}

void main() {
  late _MockAuthRepository authRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
    // Isolated from the constructor's own authStateChanges() subscription
    // for tests that only care about a single dispatched event.
    when(
      () => authRepository.authStateChanges(),
    ).thenAnswer((_) => const Stream<User?>.empty());
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [submitting, success] when sign in succeeds',
      setUp: () {
        when(
          () => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'a@b.com', password: 'secret123'),
      ),
      expect: () => [
        const AuthState(formStatus: AuthFormStatus.submitting),
        const AuthState(formStatus: AuthFormStatus.success),
      ],
      verify: (_) {
        verify(
          () => authRepository.signIn(email: 'a@b.com', password: 'secret123'),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [submitting, failure] with a mapped message when sign in '
      'throws FirebaseAuthException',
      setUp: () {
        when(
          () => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'a@b.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthState(formStatus: AuthFormStatus.submitting),
        const AuthState(
          formStatus: AuthFormStatus.failure,
          errorMessage: 'Incorrect email or password.',
        ),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'calls AuthRepository.signOut and emits no new state itself '
      '(authStateChanges() is what drives the transition)',
      setUp: () {
        when(() => authRepository.signOut()).thenAnswer((_) async {});
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => <AuthState>[],
      verify: (_) {
        verify(() => authRepository.signOut()).called(1);
      },
    );
  });

  group('AuthStatusChanged', () {
    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated with a cleared user when firebaseUser is null',
      build: () => AuthBloc(authRepository),
      act: (bloc) => bloc.add(const AuthStatusChanged(null)),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits authenticated with the fetched profile when firebaseUser is present',
      setUp: () {
        when(
          () => authRepository.fetchUserProfile('uid-1'),
        ).thenAnswer(
          (_) async => const AppUserModel(
            uid: 'uid-1',
            name: 'Jane',
            email: 'jane@example.com',
          ),
        );
      },
      build: () => AuthBloc(authRepository),
      act: (bloc) {
        final user = _MockUser();
        when(() => user.uid).thenReturn('uid-1');
        bloc.add(AuthStatusChanged(user));
      },
      expect: () => [
        const AuthState(
          status: AuthStatus.authenticated,
          user: AppUserModel(
            uid: 'uid-1',
            name: 'Jane',
            email: 'jane@example.com',
          ),
        ),
      ],
    );
  });
}
