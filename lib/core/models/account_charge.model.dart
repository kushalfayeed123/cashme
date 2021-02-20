import 'dart:convert';

import 'package:tripledes/tripledes.dart';

class AccountCharge {
  final String pbfPubKey;
  final String accountbank;
  final String accountnumber;
  final String currency;
  final String paymentType;
  final String country;
  final String amount;
  final String firstName;
  final String lastName;
  final String email;
  final String passcode;
  final String phonenumber;
  final String txRef;
  final String bvn;
  final String redirectUrl;

  const AccountCharge({
    this.pbfPubKey,
    this.accountbank,
    this.accountnumber,
    this.currency,
    this.paymentType,
    this.country,
    this.amount,
    this.firstName,
    this.lastName,
    this.email,
    this.passcode,
    this.phonenumber,
    this.txRef,
    this.bvn,
    this.redirectUrl,
  });

  Map<String, dynamic> toJson() => {
        'PBFPubKey': pbfPubKey,
        'accountbank': accountbank,
        'accountnumber': accountnumber,
        'currency': currency,
        'payment_type': paymentType,
        'country': country,
        'amount': amount,
        'email': email,
        'firstname': firstName,
        'lastname': lastName,
        'passcode': passcode,
        'phonenumber': phonenumber,
        'txRef': txRef,
        'bvn': bvn,
        'redirect_url': redirectUrl,
      };

  Map<String, String> encryptJsonPayload(
      String encryptionKey, String publicKey) {
    String encoded = jsonEncode(this);
    String encrypted = getEncryptedData(encoded, encryptionKey);

    final encryptedPayload = {
      "PBFPubKey": publicKey,
      "client": encrypted,
      "alg": "3DES-24"
    };

    return encryptedPayload;
  }

  String getEncryptedData(encoded, encryptionKey) {
    return encrypt(encryptionKey, encoded);
  }

  String encrypt(key, text) {
    var blockCipher = BlockCipher(TripleDESEngine(), key);
    var i = blockCipher.encodeB64(text);
    return i;
  }
}
