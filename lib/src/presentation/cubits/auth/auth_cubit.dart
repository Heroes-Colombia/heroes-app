import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/locator.dart';

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
  }

  Future<bool> signUp(Map<String, dynamic> userData) async {
    try {
      //First we create the user in firebase auth
      final uid = await getIt<AuthService>().signUpWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      //Then we add the uid to the user data
      userData['uid'] = uid;

      //Then we create the user in firestore
      createUserInFirestore(userData);

      //Finally we log in the user
      final isUserLoggedIn = await logIn(
        {'email': userData['email'], 'password': userData['password']},
      );

      return isUserLoggedIn;
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }

  Future<bool> logOut() async {
    try {
      await getIt<AuthService>().signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restorePassword(String email) async {
    try {
      await getIt<AuthService>().sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> createUserInFirestore(Map<String, dynamic> userData) async {
    await getIt<FirestoreService>().createDocument(
      locator<AppConstants>().usersCollection,
      userData,
    );
  }
}
