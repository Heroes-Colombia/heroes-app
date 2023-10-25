import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestorage_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/locator.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());
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

      //Then we create the user in firestore
      final userDataCreated = User.toInitialFirebaseJson(userData, null);

      //Then we add the uid to the user data
      userDataCreated['uid'] = uid;

      await createUserInFirestore(userDataCreated);

      //Then we save in firebase storage the identification image
      await getIt
          .get<FireStorageService>()
          .uploadUserIdentification(userData["identification_card_img"], uid);

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

  //This method is used to sign up the business
  Future<bool> signUpBusiness(
      Map<String, dynamic> userData, Map<String, dynamic> businessData) async {
    try {
      //First we create the user from the business info in firebase auth
      final uid = await getIt<AuthService>().signUpWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      //Then we add the uid to the user data
      userData['uid'] = uid;

      //Then we create the user in firestore
      await createUserInFirestore(userData);

      //Then we add the owner_uid to the business data
      businessData['owner_uid'] = uid;

      //Then we create the business in firestore
      await createBusinessInFirestore(userData);

      //Finally we log in the user
      final isUserLoggedIn = await logIn(
        {'email': userData['email'], 'password': userData['password']},
      );

      //And return true or false in case of error
      return isUserLoggedIn;
    } catch (e) {
      log('Error: $e}');
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

  //This method is used to create a business in firestore,
  Future<void> createBusinessInFirestore(
      Map<String, dynamic> businessData) async {
    //We create the business in firestore
    await getIt<FirestoreService>().createDocument(
      locator<AppConstants>().businessCollection,
      businessData,
    );
  }

  //This method is used for the appEntryPoint states
  void getUserInformation() async {
    try {
      emit(state.copyWith(authStatus: AuthStatus.loading));

      //Check if the user is logged in
      final userIsLoggedIn = getIt.get<AuthService>().checkUserSession();
      if (!userIsLoggedIn) {
        emit(const AuthState(authStatus: AuthStatus.userNotLoggedIn));
        return;
      }

      //Check if the user status is active (Verified)
      final userUid = getIt.get<AuthService>().getUserId();
      final userJson = await getIt.get<FirestoreService>().readDocumentById(
          getIt.get<AppConstants>().usersCollection, userUid, "uid");
      final user = User.fromJson(userJson);
      if (!user.verified) {
        emit(const AuthState(authStatus: AuthStatus.userLoggedInNotVerified));
        return;
      }

      //Check if the user is a business
      if (user.permission == UserPermissions.business) {
        emit(const AuthState(authStatus: AuthStatus.businessLoggedIn));
        return;
      }

      //If the user is logged in and verified, we emit the userLoggedIn state
      emit(const AuthState(authStatus: AuthStatus.userLoggedIn));
    } catch (e) {
      emit(const AuthState(authStatus: AuthStatus.error));
    }
  }
}
