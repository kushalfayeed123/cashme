import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class WalletModel {
  final String id;
  final String userId;
  final int availableBalance;
  final int legderBalance;
  // final String createdBy;
  // final DateTime createdOn;
  // final String modifiedBy;
  // final DateTime modifiedOn;

  const WalletModel({
    this.id,
    @required this.userId,
    @required this.availableBalance,
    @required this.legderBalance,
    // @required this.createdBy,
    // @required this.createdOn,
    // @required this.modifiedBy,
    // @required this.modifiedOn,
  });
  WalletModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        userId = snapshot.data()['UserId'],
        availableBalance = snapshot.data()['AvailableBalance'],
        legderBalance = snapshot.data()['LegderBalance'];
  // createdBy = snapshot.data()['CreatedBy'],
  // createdOn = snapshot.data()['CreatedOn'],
  // modifiedBy = snapshot.data()['ModifiedBy'],
  // modifiedOn = snapshot.data()['ModifiedOn'];

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'AvailableBalance': availableBalance,
      'LegderBalance': legderBalance,
      // 'CreatedBy': createdBy,
      // 'CreatedOn': createdOn,
      // 'ModifiedBy': modifiedBy,
      // 'ModifiedOn': modifiedOn
    };
  }
}
