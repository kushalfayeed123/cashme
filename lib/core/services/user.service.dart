import 'dart:io';

import 'package:cash_me/core/models/user.model.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'wallet.service.dart';

class UserService {
  final CollectionReference _userCollectionReference =
      FirebaseFirestore.instance.collection("User");

  Future<List<UserModel>> getAllUsers() async {
    try {
      var users = await _userCollectionReference.get();
      return users.docs.map((e) => UserModel.fromData(e)).toList();
    } catch (e) {
      throw HttpException(e);
    }
  }

  Future addUserData(String uid, String email, String fullName,
      String cashMeName, String pin) async {
    final UserModel _userData = UserModel(
        cashMeName: cashMeName,
        fullName: fullName,
        email: email,
        pin: pin,
        createdBy: cashMeName,
        createdOn: DateTime.now(),
        modifiedBy: cashMeName,
        modifiedOn: DateTime.now(),
        keyReference: uid,
        phoneNumber: null);
    final userId = Uuid().v1();
    try {
      await _userCollectionReference.doc(userId).set(
            _userData.toJson(),
          );
      WalletModel walletData = new WalletModel(
          availableBalance: 0,
          legderBalance: 0,
          userId: userId,
          accountbank: null,
          accountNumber: null,
          bvn: null);
      await locator<WalletService>().addWallet(userId, walletData);
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
      return UserModel.fromData(userRes.docs[0]);
    } catch (e) {
      throw HttpException(e);
    }
  }

  Future getUser(String email) async {
    try {
      final userRes = await _userCollectionReference
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();
      return UserModel.fromData(userRes.docs[0]);
    } catch (e) {
      throw HttpException(e);
    }
  }

  Future updateUserData(String userId, UserModel payload) async {
    try {
      _userCollectionReference.doc(userId).update({
        'Pin': payload.pin,
        'FullName': payload.fullName,
        'PhoneNumber': payload.phoneNumber,
        'modifiedOn': payload.modifiedOn,
        'modifiedBy': payload.modifiedBy
      });
    } catch (e) {
      throw HttpException(e);
    }
  }
}
