import 'dart:io';

import 'package:cash_me/core/models/transaction.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TransactionService {
  final CollectionReference _trasactCollectionReference =
      FirebaseFirestore.instance.collection("Transaction");

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

  Stream<TransactionModel> getTransacts(String userId) {
    try {
      return _trasactCollectionReference
          .where('UserId', isEqualTo: userId)
          .orderBy('ModifiedOn')
          .snapshots()
          .asyncMap((doc) =>
              doc.docs.map((e) => TransactionModel.fromData(e)).toList()[0]);
    } catch (e) {
      throw HttpException(e);
    }
  }
}
