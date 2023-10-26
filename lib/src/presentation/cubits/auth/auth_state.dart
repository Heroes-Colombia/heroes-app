part of 'auth_cubit.dart';

final class AuthState extends Equatable {
  const AuthState({
    this.authStatus = AuthStatus.initial,
  });

  final AuthStatus authStatus;

  AuthState copyWith({
    AuthStatus? authStatus,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
    );
  }

  @override
  List<Object?> get props => [authStatus];
}
