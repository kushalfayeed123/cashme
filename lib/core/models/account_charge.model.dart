import 'dart:convert';

import 'package:tripledes/tripledes.dart';

class AccountCharge {
  final String pbfPubKey;
  final String accountbank;
  final String accountnumber;
  final String currency;
  final String paymentType;
  final String country;
  final int amount;
  final String fullname;
  final String lastName;
  final String email;
  final String passcode;
  final String phonenumber;
  final String txRef;
  final String bvn;
  final String redirectUrl;
  final String destbankcode;
  final String recipientaccount;
  final String ip;
  final String deviceFingerprint;

  const AccountCharge(
      {this.pbfPubKey,
      this.accountbank,
      this.accountnumber,
      this.currency,
      this.paymentType,
      this.country,
      this.amount,
      this.fullname,
      this.lastName,
      this.email,
      this.passcode,
      this.phonenumber,
      this.txRef,
      this.bvn,
      this.redirectUrl,
      this.recipientaccount,
      this.destbankcode,
      this.ip,
      this.deviceFingerprint});

  Map<String, dynamic> toJson() {
    return {
      'PBFPubKey': pbfPubKey,
      'account_bank': accountbank,
      'account_number': accountnumber,
      'currency': currency,
      'payment_type': paymentType,
      'country': country,
      'amount': amount,
      'email': email,
      'passcode': passcode,
      'bvn': bvn,
      'phone_number': phonenumber,
      'fullname': fullname,
      'lastname': lastName,
      'Ip': ip,
      'tx_ref ': txRef,
      'device_fingerprint': deviceFingerprint,
      'redirect_url': redirectUrl,
      'destbankcode': destbankcode,
      'recipientaccount': recipientaccount,
    };
  }

  encryptJsonPayload(String encryptionKey, String publicKey) {
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
