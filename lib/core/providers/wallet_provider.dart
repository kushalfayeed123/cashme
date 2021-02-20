import 'package:cash_me/core/models/account_charge.model.dart';
import 'package:cash_me/core/models/bank.model.dart';
import 'package:cash_me/core/models/charge_response.model.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/core/services/wallet.service.dart';
import 'package:cash_me/locator.dart';
import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  WalletService _walletService = locator<WalletService>();
  WalletModel _userWallet;
  WalletModel get userWallet => _userWallet;
  List<BankModel> _banks;
  List<BankModel> get banks => _banks;
  ChargeResponse _res;
  ChargeResponse get res => _res;

  Future addWalletData(WalletModel walletData, String _userId) async {
    await _walletService.addWallet(_userId, walletData);
  }

  Future loadWallet(url, payload) async {
    _res = await _walletService.loadWallet(url, payload);
  }

  // Future getUserWallet(String userId) async {
  //   await _walletService.getWallet(userId);
  // }

  Future setUserWallet(String userId) async {
    _walletService.getWallet(userId).asBroadcastStream().listen((wallet) {
      _userWallet = wallet;
      notifyListeners();
    });
  }

  // Future setBanks() async {
  //   var banks = await _walletService.getBanks();
  //   _banks = banks.toList();
  //   notifyListeners();
  // }
}
