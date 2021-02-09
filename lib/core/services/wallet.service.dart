import 'dart:io';

import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class WalletService {
  final CollectionReference _walletCollectionReference =
      FirebaseFirestore.instance.collection("Wallet");

  Future addWallet(String userId, WalletModel walletData) async {
    final walletId = Uuid().v1();
    try {
      await _walletCollectionReference.doc(walletId).set(
            walletData.toJson(),
          );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<WalletModel> getWallet(String userId) {
    try {
      return _walletCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .asyncMap((doc) =>
              doc.docs.map((e) => WalletModel.fromData(e)).toList()[0]);
    } catch (e) {
      throw HttpException(e);
    }
  }
}
