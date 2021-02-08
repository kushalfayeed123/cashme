import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/core/services/wallet.service.dart';
import 'package:cash_me/locator.dart';
import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  WalletService _walletService = locator<WalletService>();

  Future addWalletData(WalletModel walletData, String _userId) async {
    await _walletService.addWallet(_userId, walletData);
  }

  Future getUserWallet(String userId) async {
    await _walletService.getWallet(userId);
  }
}
