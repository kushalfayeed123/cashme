import 'dart:io';

import 'package:cash_me/core/services/user.service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../locator.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // final _localAuth = LocalAuthentication();
  bool isAuthenticated = false;

  Future signIn({
    String email,
    String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future registerUser(
    String password,
    String email,
    String fullName,
    String cashMeName,
    String pin,
  ) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = _firebaseAuth.currentUser;
      await locator<UserService>()
          .addUserData(user.uid, email, fullName, cashMeName, pin);
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      User user = _firebaseAuth.currentUser;
      return user != null;
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw HttpException(e.message);
    }
  }
}
