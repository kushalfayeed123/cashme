import 'dart:convert';
import 'dart:io';

import 'package:cash_me/core/constants.dart';
import 'package:cash_me/core/models/account_charge.model.dart';
import 'package:cash_me/core/models/charge_response.model.dart';
import 'package:cash_me/core/models/charge_verification_response.dart';
import 'package:cash_me/core/models/transfer.model.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class WalletService {
  final CollectionReference _walletCollectionReference =
      FirebaseFirestore.instance.collection("Wallet");
  final CollectionReference _transferCollectionReference =
      FirebaseFirestore.instance.collection("Transfer");

  // var dio = Dio(BaseOptions(followRedirects: false));

  Map<String, String> get headers => {
        "Authorization":
            //     // "Bearer FLWSECK-2e71fb7432ce8d2baba8e2ddb320d6bf-X",

            "Bearer FLWSECK_TEST-88e6e737751438039c0a2875396babc1-X",
        "Content-Type": " application/json",
        "Accept": " application/json"
      };

  Future getResponseFromEndpoint(String url) async {
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception $e');
      return null;
    }
  }

  Future verifyAccount(AccountCharge payload) async {
    var res = await http.post(ACCOUNT_VERIFICATION_ENDPOINT,
        body: json.encode(payload), headers: headers);
    return jsonDecode(res.body);
  }

  Future verifyCharge(String id) async {
    var url = 'https://api.flutterwave.com/v3/transactions/$id/verify';
    try {
      var res = await http.get(url, headers: headers);
      print(res.body);
      return ChargeVerificationResponse.fromJson(jsonDecode(res.body), false);
    } catch (e) {
      print(e);
      throw HttpException(e);
    }
  }

  Future validateCharge(payload) async {
    try {
      var res = await http.post(VALIDATE_CHARGE_ENDPOINT,
          body: json.encode(payload), headers: headers);
      print(res.body);
      return ChargeResponse.fromJson(jsonDecode(res.body), false);
    } catch (e) {
      print(e);

      throw HttpException(e);
    }
  }

  Future loadWallet(String url, body) async {
    try {
      var res = await http.post(url, body: json.encode(body), headers: headers);
      if (res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204 ||
          res.statusCode == 206) {
        return ChargeResponse.fromJson(jsonDecode(res.body), false);
      } else {
        print('Error: ${res.statusCode}  response : ${res.body}');
        return null;
      }
    } catch (e) {
      print('Exception $e');
      return null;
    }
  }

  Future addWallet(String userId, WalletModel walletData) async {
    final walletId = Uuid().v1();
    try {
      await _walletCollectionReference.doc(walletId).set(
            walletData.toJson(),
          );
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Future createTransferRecord(TransferModel transferData) async {
    final transferId = Uuid().v1();
    try {
      await _transferCollectionReference
          .doc(transferId)
          .set(transferData.toJson());
    } catch (e) {
      throw HttpException(e.message);
    }
  }

  Stream<WalletModel> getWallet(String userId) {
    try {
      return _walletCollectionReference
          .where('UserId', isEqualTo: userId)
          .snapshots()
          .asyncMap((doc) =>
              doc.docs.map((e) => WalletModel.fromData(e)).toList()[0]);
    } catch (e) {
      throw HttpException(e);
    }
  }

  static Future getBanks() {
    try {
      return http.get(BANKS_ENDPOINT);
      // if (response.statusCode == 200) {
      //   return postFromJson(response.body);
      // } else {
      //   throw Exception('Failed to load');
      // }
    } catch (e) {
      print(e);

      throw HttpException(e);
    }
  }

  Future intitialUpdateWalletData(String walletId, WalletModel payload) async {
    try {
      _walletCollectionReference.doc(walletId).update({
        'AccountNumber': payload.accountNumber,
        'Accountbank': payload.accountbank,
        'Bvn': payload.bvn,
        'AvailableBalance': payload.availableBalance,
        'LegderBalance': payload.legderBalance
      });
    } catch (e) {
      throw HttpException(e);
    }
  }

  Future updateWallet(String walletId, WalletModel payload) async {
    try {
      _walletCollectionReference.doc(walletId).update({
        'AvailableBalance': payload.availableBalance,
        'LegderBalance': payload.legderBalance
      });
    } catch (e) {
      throw HttpException(e);
    }
  }
}
