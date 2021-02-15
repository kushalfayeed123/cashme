import 'dart:io';

import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/core/services/user.service.dart';
import 'package:cash_me/core/services/wallet.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
    String firstName,
    String lastName,
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
          .addUserData(user.uid, email, firstName, lastName, cashMeName, pin);
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
