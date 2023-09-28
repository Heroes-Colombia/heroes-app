import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    //TODO: implement signUpWithEmailAndPassword
    try {
      var credentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      log('credentials: $credentials');
    } on FirebaseAuthException catch (e) {
      log('error: $e');
    } catch (e) {
      log('error: $e');
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {}

  bool checkUserSession() {
    var isUserSignedIn = false;
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isUserSignedIn = true;
    }
    return isUserSignedIn;
  }

  Future<String> getUserInfo() async {
    return '';
  }
}
