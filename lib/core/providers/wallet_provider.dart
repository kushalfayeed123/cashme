import 'package:cash_me/core/models/bank.model.dart';
import 'package:cash_me/core/models/bank_transfer_response.model.dart';
import 'package:cash_me/core/models/cashout_response.model.dart';
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
  BankModel _banks;
  BankModel get banks => _banks;

  CashoutResponse _transfer;
  CashoutResponse get transfer => _transfer;

  ValidateChargeResponse _validateRes;
  ValidateChargeResponse get validateRes => _validateRes;

  VerifyChargeResponse _verifyRes;
  VerifyChargeResponse get verifyRes => _verifyRes;

  BankTransferResponse _res;
  BankTransferResponse get res => _res;

  CashoutResponse _cashOutRes;
  CashoutResponse get cashOutRes => _cashOutRes;

  Future addWalletData(WalletModel walletData, String _userId) async {
    await _walletService.addWallet(_userId, walletData);
  }

  Future createTransferRecord(TransferModel transferData) async {
    await _walletService.createTransferRecord(transferData);
  }

  Future loadWallet(payload) async {
    _res = await _walletService.loadWallet(payload);
  }

  Future cashOut(payload) async {
    _cashOutRes = await _walletService.cashOut(payload);
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

  Future setBanks() async {
    _walletService.getBanks().asStream().listen((bank) {
      _banks = bank;
      notifyListeners();
    });
  }

  Future setTransfer(int id) async {
    _walletService.getTransfer(id).asStream().listen((transfer) {
      _transfer = transfer;
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
}
