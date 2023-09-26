part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  final String error;

  const AuthState({this.error = ''});
  @override
  List<Object> get props => [error];
}

class AuthStateInitial extends AuthState {}

class AuthStateError extends AuthState {
  const AuthStateError({super.error});
}
