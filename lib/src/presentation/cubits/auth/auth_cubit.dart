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

  //This method is used to log in the user
  Future<bool> logIn(Map<String, dynamic> userData) async {
    try {
      //First we log in the user in firebase auth
      await getIt<AuthService>().signInWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );
      //Then we get the user info from firestore and return true or false in case of error
      return true;
    } catch (e) {
      return false;
    }
  }

  //This method is used to sign up the user
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

      //And return true or false in case of error
      return isUserLoggedIn;
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }

  //This method is used to log out the user
  Future<bool> logOut() async {
    try {
      //First we log out the user from firebase auth
      await getIt<AuthService>().signOut();
      //Then we return true or false in case of error
      return true;
    } catch (e) {
      return false;
    }
  }

  //This method is used to restore the password
  Future<bool> restorePassword(String email) async {
    try {
      //First we send the password reset email
      await getIt<AuthService>().sendPasswordResetEmail(email);
      //Then we return true or false in case of error
      return true;
    } catch (e) {
      return false;
    }
  }

  //This method is used to create the user in firestore,
  //it is called inside signUp method if the user is created in firebase auth,
  Future<void> createUserInFirestore(Map<String, dynamic> userData) async {
    //We create the user in firestore
    await getIt<FirestoreService>().createDocument(
      locator<AppConstants>().usersCollection,
      userData,
    );
  }
}
