import 'package:cash_me/core/models/user.model.dart';
import 'package:cash_me/core/services/user.service.dart';
import 'package:cash_me/locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserProvider with ChangeNotifier {
  UserService _userService = locator<UserService>();
  UserModel _currentUser;
  UserModel _user;

  List<UserModel> _allUsers;
  List<UserModel> get allUsers => _allUsers;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel get currentUser => _currentUser;
  UserModel get selectedUser => _user;

  Future setCurrentUser(bool isLocalAuth) async {
    var keyRefernence = _firebaseAuth.currentUser.uid;
    _currentUser = await _userService.getCurrentUser(keyRefernence);
    notifyListeners();
  }

  Future setUser(String email) async {
    _user = await _userService.getUser(email);
    notifyListeners();
  }

  Future setAllUsers(String userId) async {
    var users = await _userService.getAllUsers();

    _allUsers =
        users.where((e) => e.cashMeName != null || e.fullName != null).toList();
    _allUsers = _allUsers.where((e) => e.id != userId).toList();
    notifyListeners();
  }

  Future updateUserData(String userId, UserModel payload) async {
    await _userService.updateUserData(userId, payload);
  }

  UserModel get user {
    return _currentUser;
  }
}
