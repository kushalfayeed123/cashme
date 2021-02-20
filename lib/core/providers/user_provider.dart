import 'package:cash_me/core/models/user.model.dart';
import 'package:cash_me/core/services/user.service.dart';
import 'package:cash_me/locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = locator<UserService>();
  UserModel _currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel get currentUser => _currentUser;

  Future setCurrentUser(bool isLocalAuth) async {
    var keyRefernence = _firebaseAuth.currentUser.uid;
    _currentUser = await _userService.getCurrentUser(keyRefernence);
    notifyListeners();
  }

  UserModel get user {
    return _currentUser;
  }
}
