import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final String type;
  final String value;
  final String senderName;
  final String transactionMode;
  // final String transactionMode;
  final DateTime createdOn;
  final DateTime modifiedOn;
  final String status;
  final String userId;
  final String transactionRef;
  final String receiverName;

  const TransactionModel(
      {this.id,
      @required this.type,
      @required this.value,
      @required this.senderName,
      @required this.transactionMode,
      @required this.createdOn,
      @required this.modifiedOn,
      @required this.status,
      @required this.userId,
      @required this.receiverName,
      @required this.transactionRef});
  TransactionModel.fromData(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        type = snapshot.data()['Type'],
        value = snapshot.data()['Value'] ?? '',
        senderName = snapshot.data()['SenderName'] ?? '',
        transactionMode = snapshot.data()['TransactionMode'] ?? '',
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedOn = snapshot.data()['ModifiedOn'].toDate(),
        status = snapshot.data()['Status'],
        transactionRef = snapshot.data()['TransactionReference'] ?? '',
        userId = snapshot.data()['UserId'],
        receiverName = snapshot.data()['ReceiverName'] ?? '';
  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Value': value,
      'SenderName': senderName,
      'TransactionMode': transactionMode,
      'CreatedOn': createdOn,
      'ModifiedOn': modifiedOn,
      'Status': status,
      'UserId': userId,
      'ReceiverName': receiverName,
      'TransactionReference': transactionRef,
    };
  }
}
