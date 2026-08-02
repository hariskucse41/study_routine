import 'package:equatable/equatable.dart';
import '../model/app_user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Tracks the outcome of the in-flight form action (login/register/reset)
/// separately from [AuthStatus], which tracks the persistent session state.
enum AuthFormStatus { idle, submitting, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUserModel? user;
  final AuthFormStatus formStatus;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.formStatus = AuthFormStatus.idle,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUserModel? user,
    bool clearUser = false,
    AuthFormStatus? formStatus,
    String? errorMessage,
    bool clearError = false,
  }) => AuthState(
    status: status ?? this.status,
    user: clearUser ? null : (user ?? this.user),
    formStatus: formStatus ?? this.formStatus,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [status, user, formStatus, errorMessage];
}
