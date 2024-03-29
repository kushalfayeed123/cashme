// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransferModel {
  final String id;
  final String senderId;
  final String transferValue;
  final String receiverId;
  final String type;
  final String email;
  final String walletId;
  final String senderAvailableBalance;
  final DateTime createdOn;
  final DateTime modifiedOn;

  TransferModel(
      {this.id,
      this.senderId,
      this.receiverId,
      this.email,
      this.type,
      this.transferValue,
      this.senderAvailableBalance,
      this.createdOn,
      this.modifiedOn,
      this.walletId});

  // TransferModel.fromData(DocumentSnapshot snapshot)
  //     : id = snapshot.id,
  //       senderId = snapshot.data()['SenderId'],
  //       receiverId = snapshot.data()['ReceiverId'],
  //       email = snapshot.data()['Email'],
  //       type = snapshot.data()['Type'],
  //       createdOn = snapshot.data()['CreatedOn'].toDate() ?? DateTime.now(),
  //       modifiedOn = snapshot.data()['ModifiedOn'].toDate() ?? DateTime.now(),
  //       transferValue = snapshot.data()['TransferValue'],
  //       senderAvailableBalance = snapshot.data()['SenderAvailableBalance'],
  //       walletId = snapshot.data()['WalletId'];

  TransferModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        senderId = json['SenderId'],
        receiverId = json['ReceiverId'],
        email = json['Email'],
        type = json['Type'],
        transferValue = json['TransferValue'],
        createdOn = json['CreatedOn'],
        modifiedOn = json['ModifiedOn'],
        senderAvailableBalance = json['SenderAvailableBalance'],
        walletId = json['WalletId'];

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'SenderId': senderId,
      'ReceiverId': receiverId,
      'Email': email,
      'TransferValue': transferValue,
      'CreatedOn': createdOn,
      'ModifiedOn': modifiedOn,
      'Type': type,
      'SenderAvailableBalance': senderAvailableBalance,
      'WalletId': walletId,
    };
  }
}
