import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

class AuthService {
  AuthService();

  final locator = GetIt.instance;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<String> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    var credentials = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    log('credentials: ${credentials.user!.uid}');
    return credentials.user!.uid;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

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
