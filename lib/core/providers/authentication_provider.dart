import 'package:cash_me/core/services/auth.service.dart';
import 'package:cash_me/locator.dart';
import 'package:flutter/material.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationService _authService = locator<AuthenticationService>();

  Future<void> signIn({String email, String password}) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> registerUser({
    String password,
    String email,
    String firstName,
    String lastName,
    String cashMeName,
    String pin,
  }) async {
    await _authService.registerUser(
        password, email, firstName, lastName, cashMeName, pin);
  }

  Future<bool> isUserLoggedIn() async {
    return await _authService.isUserLoggedIn();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
