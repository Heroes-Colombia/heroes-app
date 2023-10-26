import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

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
}
