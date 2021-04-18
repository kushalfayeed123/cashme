// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransferModel {
  final String senderId;
  final String transferValue;
  final String receiverId;
  final String email;
  final String walletId;

  const TransferModel(
      {@required this.senderId,
      @required this.receiverId,
      @required this.email,
      @required this.transferValue,
      @required this.walletId});

  TransferModel.fromJson(Map<String, dynamic> json)
      : senderId = json['senderId'],
        receiverId = json['receiverId'],
        email = json['email'],
        transferValue = json['transferValue'],
        walletId = json['walletId'];

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'email': email,
        'transferValue': transferValue,
        'walletId': walletId,
      };
}
