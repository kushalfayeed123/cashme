import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/theme_provider.dart';
import 'package:cash_me/core/providers/transaction_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cash_me/ui/shared/utils/settings.dart' as st;
import 'package:cash_me/locator.dart';
import 'package:provider/provider.dart';
import 'app.dart';

bool userFirestoreEmulator = false;

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await st.Settings.init();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);

  if (userFirestoreEmulator) {
    FirebaseFirestore.instance.settings = Settings(
        host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }
  setupLocator();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
      ChangeNotifierProvider(create: (ctx) => AuthenticationProvider()),
      ChangeNotifierProvider(create: (ctx) => UserProvider()),
      ChangeNotifierProvider(create: (ctx) => WalletProvider()),
      ChangeNotifierProvider(create: (ctx) => TransactionProvider()),
    ], child: MyApp()
        // Builder(
        //     builder: (context) => MaterialApp(
        //           debugShowCheckedModeBanner: false,
        //           onUnknownRoute: (settings) {
        //             return MaterialPageRoute(builder: (ctx) => MyApp());
        //           }, // return MyApp();
        //         ))
        ),
  );
}
