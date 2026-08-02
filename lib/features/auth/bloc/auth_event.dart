import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched internally by AuthBloc in response to FirebaseAuth's
/// authStateChanges() stream — not intended to be added by the UI.
class AuthStatusChanged extends AuthEvent {
  final User? firebaseUser;
  const AuthStatusChanged(this.firebaseUser);
  @override
  List<Object?> get props => [firebaseUser?.uid];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
