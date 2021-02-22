import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String pin;
  final String cashMeName;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;
  final String keyReference;
  final String phoneNumber;

  const UserModel({
    this.id,
    @required this.fullName,
    @required this.email,
    @required this.pin,
    @required this.cashMeName,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
    @required this.keyReference,
    @required this.phoneNumber,
  });

  UserModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        fullName = snapshot.data()['FullName'],
        email = snapshot.data()['Email'],
        keyReference = snapshot.data()['KeyReference'],
        pin = snapshot.data()['Pin'],
        phoneNumber = snapshot.data()['PhoneNumber'],
        cashMeName = snapshot.data()['CashMeName'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'FullName': fullName,
      'Email': email,
      'Pin': pin,
      'PhoneNumber': phoneNumber,
      'CashMeName': cashMeName,
      'KeyReference': keyReference,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
