import 'dart:io';

import 'package:cash_me/core/models/transaction.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TransactionService {
  final CollectionReference _trasactCollectionReference =
      FirebaseFirestore.instance.collection("Transaction");

  final sandboxUrl = 'https://ravesandboxapi.flutterwave.com';
  final liveUrl = 'https://api.ravepay.co';

  Future addTransact(String userId, TransactionModel transactData) async {
    final transactId = Uuid().v1();
    try {
      await _trasactCollectionReference.doc(transactId).set(
            transactData.toJson(),
          );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<List<TransactionModel>> getTransacts(String userId) {
    try {
      return _trasactCollectionReference
          .where('UserId', isEqualTo: userId)
          .orderBy('ModifiedOn')
          .snapshots()
          .asyncMap((doc) =>
              doc.docs.map((e) => TransactionModel.fromData(e)).toList());
    } catch (e) {
      throw HttpException(e);
    }
  }
}
