import 'package:cash_me/core/models/transaction.model.dart';
import 'package:cash_me/core/services/transaction.service.dart';
import 'package:cash_me/locator.dart';
import 'package:flutter/material.dart';

class TransactionProvider with ChangeNotifier {
  TransactionService _transactService = locator<TransactionService>();
  List<TransactionModel> _userTransactions;
  List<TransactionModel> get userTransactions => _userTransactions;

  Future addTransaction(TransactionModel transactionData) async {
    await _transactService.createTransaction(transactionData);
  }

  // Future getUserWallet(String userId) async {
  //   await _walletService.getWallet(userId);
  // }

  Future setUserTransactions(String userId) async {
    _transactService
        .getTransacts(userId)
        .asBroadcastStream()
        .listen((transact) {
      _userTransactions = transact;
      notifyListeners();
    });
  }

  Future updateTransaction(
      String transactionId, TransactionModel payload) async {
    await _transactService.updateTransaction(transactionId, payload);
  }
}
