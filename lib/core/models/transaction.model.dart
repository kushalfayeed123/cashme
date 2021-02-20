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

  const TransactionModel({
    this.id,
    @required this.type,
    @required this.value,
    @required this.senderName,
    @required this.receiverName,
    @required this.createdOn,
    @required this.modifiedOn,
    @required this.status,
  });
  TransactionModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        type = snapshot.data()['Type'],
        value = snapshot.data()['Value'],
        senderName = snapshot.data()['SenderName'],
        receiverName = snapshot.data()['ReceiverName'],
        createdOn = snapshot.data()['CreatedOn'],
        modifiedOn = snapshot.data()['ModifiedOn'],
        status = snapshot.data()['Status'];
  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Value': value,
      'SenderName': senderName,
      'ReceiverName': receiverName,
      'CreatedOn': createdOn,
      'ModifiedOn': modifiedOn,
      'Status': status,
    };
  }
}
