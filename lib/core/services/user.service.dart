import 'dart:io';

import 'package:cash_me/core/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final CollectionReference _userCollectionReference =
      FirebaseFirestore.instance.collection("User");

  Future addUserData(String uid, String email, String firstName,
      String lastName, String cashMeName, String pin) async {
    final UserModel _userData = UserModel(
        cashMeName: cashMeName,
        firstName: firstName,
        lastName: lastName,
        email: email,
        pin: pin,
        createdBy: cashMeName,
        createdOn: DateTime.now(),
        modifiedBy: cashMeName,
        modifiedOn: DateTime.now(),
        keyReference: uid);
    final userId = Uuid().v1();
    try {
      await _userCollectionReference.doc(userId).set(
            _userData.toJson(),
          );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future getCurrentUser(String keyReference) async {
    try {
      final userRes = await _userCollectionReference
          .where('KeyReference', isEqualTo: keyReference)
          .limit(1)
          .get();
      print(userRes.docs[0].data());

      return UserModel.fromData(userRes.docs[0]);
    } catch (e) {
      throw HttpException(e);
    }
  }
}
