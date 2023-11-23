import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/business_user_model.dart';
import 'package:heroes_app/src/domain/models/user_model.dart' as user_model;
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

//This class is a wrapper for Firebase Auth
class AuthService {
  AuthService();

  final locator = GetIt.instance;

  //This method is used to sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //This method is used to sign up with email and password -> Then return the user id to create the user profile inside firestore
  Future<String> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    var credentials = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    log('credentials: ${credentials.user!.uid}');
    return credentials.user!.uid;
  }

  //This method is used to sign out
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  //This method is used to send a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /*
  This method is used to check if the user is signed in
   -> If the user is signed in, return true.
   -> Otherwise, return false.
  And the caller can use this method to decide which screen to show
  */
  bool checkUserSession() {
    var isUserSignedIn = false;
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isUserSignedIn = true;
    }
    return isUserSignedIn;
  }

  //This method is used to get the user id of the current user
  String getUserId() {
    var userUid = FirebaseAuth.instance.currentUser!.uid;
    return userUid;
  }

  //This method is used to get the user object of the current user
  Future<user_model.User?> getUser() async {
    try {
      //First collect the user info collection from Firestore
      final userCollection = locator.get<AppConstants>().usersCollection;

      //Then get the user id from the auth service
      final userId = locator.get<AuthService>().getUserId();

      //Then get the user info from the firestore collection
      final userRawInfo = await locator
          .get<FirestoreService>()
          .readDocumentById(userCollection, userId, 'uid');

      //Finally create a user object from the raw info and emit the new state
      final user = user_model.User.fromJson(userRawInfo);

      //Set the user in the class property to avoid calling the method again
      return user;
    } catch (e) {
      log("Error: $e, Function: getUser, File: profile_cubit.dart");
      return null;
    }
  }

  //This method is used to get the business_user object of the current user
  Future<BusinessUser?> getBusinessUser() async {
    try {
      //First collect the user info collection from Firestore
      final userCollection = locator.get<AppConstants>().usersCollection;

      //Then get the user id from the auth service
      final userId = locator.get<AuthService>().getUserId();

      //Then get the user info from the firestore collection
      final userRawInfo = await locator
          .get<FirestoreService>()
          .readDocumentById(userCollection, userId, 'uid');

      //Finally create a user object from the raw info and emit the new state
      final user = BusinessUser.fromJson(userRawInfo);

      //Set the user in the class property to avoid calling the method again
      return user;
    } catch (e) {
      log("Error: $e, Function: getUser, File: profile_cubit.dart");
      return null;
    }
  }
}
