import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String pin;
  final String cashMeName;
  final String createdBy;
  final DateTime createdOn;
  final String modifiedBy;
  final DateTime modifiedOn;
  final String keyReference;

  const UserModel({
    this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.pin,
    @required this.cashMeName,
    @required this.createdBy,
    @required this.createdOn,
    @required this.modifiedBy,
    @required this.modifiedOn,
    @required this.keyReference,
  });

  UserModel.fromData(DocumentSnapshot snapshot)
      : id = snapshot.id,
        firstName = snapshot.data()['FirstName'],
        lastName = snapshot.data()['LastName'],
        email = snapshot.data()['Email'],
        keyReference = snapshot.data()['KeyReference'],
        pin = snapshot.data()['Pin'],
        cashMeName = snapshot.data()['CashMeName'],
        createdBy = snapshot.data()['CreatedBy'],
        createdOn = snapshot.data()['CreatedOn'].toDate(),
        modifiedBy = snapshot.data()['ModifiedBy'],
        modifiedOn = snapshot.data()['ModifiedOn'].toDate();

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'Pin': pin,
      'CashMeName': cashMeName,
      'KeyReference': keyReference,
      'CreatedBy': createdBy,
      'CreatedOn': createdOn,
      'ModifiedBy': modifiedBy,
      'ModifiedOn': modifiedOn,
    };
  }
}
