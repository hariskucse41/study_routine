import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/app_user_model.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  StreamSubscription<User?>? _authSub;

  AuthBloc(this._repo) : super(const AuthState()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<LogoutRequested>(_onLogoutRequested);

    _authSub = _repo.authStateChanges().listen(
      (user) => add(AuthStatusChanged(user)),
    );
  }

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    final firebaseUser = event.firebaseUser;
    if (firebaseUser == null) {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearUser: true),
      );
      return;
    }
    final profile =
        await _repo.fetchUserProfile(firebaseUser.uid) ??
        AppUserModel.fromFirebaseUser(firebaseUser);
    emit(state.copyWith(status: AuthStatus.authenticated, user: profile));
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    try {
      await _repo.signIn(email: event.email, password: event.password);
      emit(
        state.copyWith(formStatus: AuthFormStatus.success, clearError: true),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: _mapAuthError(e),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    try {
      await _repo.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(
        state.copyWith(formStatus: AuthFormStatus.success, clearError: true),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: _mapAuthError(e),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(formStatus: AuthFormStatus.submitting, clearError: true),
    );
    try {
      await _repo.sendPasswordResetEmail(event.email);
      emit(
        state.copyWith(formStatus: AuthFormStatus.success, clearError: true),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: _mapAuthError(e),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          formStatus: AuthFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.signOut();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
