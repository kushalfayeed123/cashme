import 'dart:convert';

BankModel postFromJson(String str) {
  final jsonData = json.decode(str);
  return BankModel.fromJson(jsonData);
}

class BankModel {
  String bankname;
  String bankcode;
  bool internetbanking;

  BankModel(String bankname, String bankcode, bool internetbanking) {
    this.bankname = bankname;
    this.bankcode = bankcode;
    this.internetbanking = internetbanking;
  }

  BankModel.fromJson(Map json)
      : bankname = json['bankname'],
        bankcode = json['bankcode'],
        internetbanking = json['internetbanking'];

  Map tojson() {
    return {
      'bankname': bankname,
      'bankcode': bankcode,
      'internetbanking': internetbanking
    };
  }
}
