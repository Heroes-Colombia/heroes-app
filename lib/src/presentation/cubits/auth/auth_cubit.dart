import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthStateInitial());
  final getIt = GetIt.instance;

  Future<bool> logIn(Map<String, dynamic> userData) async {
    try {
      await getIt<AuthService>().signInWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );
      return true;
    } catch (e) {
      return false;
    }

    // ignore: avoid_print
  }

  Future<void> logOut() async {}

  Future<void> checkIfUserIsLoggedIn() async {
    try {
      var userIsSignedIn = getIt<AuthService>().checkUserSession();
      // ignore: avoid_print
      print('userIsSignedIn: $userIsSignedIn');
    } catch (e) {
      // ignore: avoid_print
      print('error: $e');
    }
  }

  Future<void> restoreErrorMessage() async {
    emit(AuthStateInitial());
  }
}
