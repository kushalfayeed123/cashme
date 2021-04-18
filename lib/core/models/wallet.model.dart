import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class WalletModel {
  final String id;
  final String userId;
  final int availableBalance;
  final int legderBalance;
  final String accountNumber;
  final String accountbank;
  final String bvn;
  // final DateTime createdOn;
  // final DateTime modifiedOn;

  const WalletModel({
    this.id,
    @required this.userId,
    @required this.availableBalance,
    @required this.legderBalance,
    @required this.accountNumber,
    @required this.accountbank,
    @required this.bvn,
    // @required this.createdOn,
    // @required this.modifiedOn,
  });
  WalletModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        availableBalance = snapshot.data()['AvailableBalance'] ?? 0,
        legderBalance = snapshot.data()['LegderBalance'] ?? 0,
        accountNumber = snapshot.data()['AccountNumber'],
        accountbank = snapshot.data()['Accountbank'],
        bvn = snapshot.data()['Bvn'];
  // createdOn = snapshot.data()['CreatedOn'].toDate(),
  // modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'AvailableBalance': availableBalance,
      'LegderBalance': legderBalance,
      'AccountNumber': accountNumber,
      'Accountbank': accountbank,
      'Bvn': bvn,
      // 'CreatedOn': createdOn,
      // 'ModifiedOn': modifiedOn
    };
  }
}
