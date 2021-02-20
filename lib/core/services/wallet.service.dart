import 'dart:convert';
import 'dart:io';

import 'package:cash_me/core/constants.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class WalletService {
  final CollectionReference _walletCollectionReference =
      FirebaseFirestore.instance.collection("Wallet");

  // var dio = Dio(BaseOptions(followRedirects: false));

  Map<String, String> get headers => {
        "Authorization":
            // "Bearer FLWSECK_TEST-88e6e737751438039c0a2875396babc1-X"
            "Bearer FLWSECK-2e71fb7432ce8d2baba8e2ddb320d6bf-X"
      };

  Future getResponseFromEndpoint(String url) async {
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception $e');
      return null;
    }
  }

  Future loadWallet(String url, Map<String, String> body) async {
    try {
      var res = await http.post(url, body: body, headers: headers);
      if (res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204 ||
          res.statusCode == 206) {
        print(jsonDecode(res.body));
        return jsonDecode(res.body);
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
}
