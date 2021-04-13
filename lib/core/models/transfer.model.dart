// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransferModel {
  final String senderId;
  final String transferValue;
  final String receiverId;

  const TransferModel(
      {@required this.senderId,
      @required this.receiverId,
      @required this.transferValue});
}
