import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final String type;
  final String value;
  final String senderName;
  final String receiverName;
  final DateTime createdOn;
  final DateTime modifiedOn;
  final String status;
  final String userId;

  const TransactionModel({
    this.id,
    @required this.type,
    @required this.value,
    @required this.senderName,
    @required this.receiverName,
    @required this.createdOn,
    @required this.modifiedOn,
    @required this.status,
    @required this.userId,
  });
  TransactionModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        type = snapshot.data()['Type'],
        value = snapshot.data()['Value'],
        senderName = snapshot.data()['SenderName'],
        receiverName = snapshot.data()['ReceiverName'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedOn = snapshot.data()['ModifiedOn'].toDate(),
        status = snapshot.data()['Status'],
        userId = snapshot.data()['UserId'];
  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Value': value,
      'SenderName': senderName,
      'ReceiverName': receiverName,
      'CreatedOn': createdOn,
      'ModifiedOn': modifiedOn,
      'Status': status,
      'UserId': userId,
    };
  }
}
