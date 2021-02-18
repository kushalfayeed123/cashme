import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final String type;
  final String value;
  final String senderId;
  final String receiverId;
  final DateTime createdOn;
  final DateTime modifiedOn;
  final String status;

  const TransactionModel({
    this.id,
    @required this.type,
    @required this.value,
    @required this.senderId,
    @required this.receiverId,
    @required this.createdOn,
    @required this.modifiedOn,
    @required this.status,
  });
  TransactionModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        type = snapshot.data()['Type'],
        value = snapshot.data()['Value'],
        senderId = snapshot.data()['SenderId'],
        receiverId = snapshot.data()['ReceiverId'],
        createdOn = snapshot.data()['CreatedOn'],
        modifiedOn = snapshot.data()['ModifiedOn'],
        status = snapshot.data()['Status'];
  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Value': value,
      'SenderId': senderId,
      'ReceiverId': receiverId,
      'CreatedOn': createdOn,
      'ModifiedOn': modifiedOn,
      'Status': status,
    };
  }
}
