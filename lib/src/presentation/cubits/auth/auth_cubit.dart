import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final getIt = GetIt.instance;
  AuthCubit() : super(AuthStateInitial());

  Future<void> logIn(Map<String, dynamic> userData) async {}

  Future<void> logOut() async {}

  Future<void> checkIfUserIsLoggedIn() async {}

  Future<void> restoreErrorMessage() async {
    emit(AuthStateInitial());
  }
}
