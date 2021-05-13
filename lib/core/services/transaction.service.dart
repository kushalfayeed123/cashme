import 'dart:io';

import 'package:cash_me/core/models/transaction.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TransactionService {
  final CollectionReference _trasactCollectionReference =
      FirebaseFirestore.instance.collection("Transaction");

  Future createTransaction(TransactionModel transactData) async {
    final transactId = Uuid().v1();
    try {
      await _trasactCollectionReference.doc(transactId).set(
            transactData.toJson(),
          );
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  Stream<List<TransactionModel>> getTransacts(String userId) {
    try {
      return _trasactCollectionReference
          .where('UserId', isEqualTo: userId)
          // .orderBy('ModifiedOn')
          .snapshots()
          .asyncMap((doc) =>
              doc.docs.map((e) => TransactionModel.fromData(e)).toList());
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  Future updateTransaction(
      String transactionId, TransactionModel payload) async {
    try {
      _trasactCollectionReference
          .doc(transactionId)
          .update({'Status': payload.status, 'ModifiedOn': payload.modifiedOn});
    } catch (e) {
      throw Exception(e);
    }
  }
}
