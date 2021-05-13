import 'package:cash_me/core/models/bank.model.dart';
import 'package:cash_me/core/models/charge_response.model.dart';
import 'package:cash_me/core/models/validate_charge_response.model.dart';
import 'package:cash_me/core/models/transfer.model.dart';
import 'package:cash_me/core/models/verify_charge_response.model.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/core/services/wallet.service.dart';
import 'package:cash_me/locator.dart';
import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  WalletService _walletService = locator<WalletService>();
  WalletModel _userWallet;
  WalletModel get userWallet => _userWallet;
  WalletModel _senderWallet;
  WalletModel get senderWallet => _senderWallet;
  List<BankModel> _banks;
  List<BankModel> get banks => _banks;

  ValidateChargeResponse _validateRes;
  ValidateChargeResponse get validateRes => _validateRes;

  VerifyChargeResponse _verifyRes;
  VerifyChargeResponse get verifyRes => _verifyRes;

  ChargeResponse _res;
  ChargeResponse get res => _res;

  Future addWalletData(WalletModel walletData, String _userId) async {
    await _walletService.addWallet(_userId, walletData);
  }

  Future createTransferRecord(TransferModel transferData) async {
    await _walletService.createTransferRecord(transferData);
  }

  Future loadWallet(url, payload) async {
    _res = await _walletService.loadWallet(url, payload);
  }

  // Future getUserWallet(String userId) async {
  //   await _walletService.getWallet(userId);
  // }
  //
  Future validateCharge(payload) async {
    _validateRes = await _walletService.validateCharge(payload);
  }

  Future verifyCharge(int id) async {
    _walletService.verifyCharge(id).asStream().listen((res) {
      _verifyRes = res;
      notifyListeners();
    });
  }

  Future setUserWallet(String userId) async {
    _walletService.getWallet(userId).asBroadcastStream().listen((wallet) {
      _userWallet = wallet;
      notifyListeners();
    });
  }

  Future getSenderWallet(String senderID) async {
    _walletService.getWallet(senderID).asBroadcastStream().listen((wallet) {
      _senderWallet = wallet;
      notifyListeners();
    });
  }

  Future initialUpdate(String walletId, WalletModel payload) async {
    await _walletService.intitialUpdateWalletData(walletId, payload);
  }

  Future updateWallet(String walletId, WalletModel payload) async {
    await _walletService.updateWallet(walletId, payload);
  }

  // Future setBanks() async {
  //   _walletService.getBanks().asStream().listen((bank) {
  //     _banks = bank.map((model) => BankModel.fromJson(model)).toList();
  //   });
  //   notifyListeners();
  // }
}
