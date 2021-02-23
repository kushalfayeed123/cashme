import 'package:cash_me/ui/views/create_account/create_account_screen.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/load_wallet/load_wallet.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:cash_me/ui/views/splash/splash_screen.dart';
import 'package:cash_me/ui/views/transfer_screen/transfer_screen.dart';

final routes = {
  // EntryScreen.routeName: (ctx) => EntryScreen(),
  SplashScreenUi.routeName: (context) => SplashScreenUi(),
  LoginScreen.routeName: (context) => LoginScreen(),
  CreateAccountScreen.routeName: (context) => CreateAccountScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  LoadWalletScreen.routeName: (context) => LoadWalletScreen(),
  TransferScreen.routeName: (context) => TransferScreen(),
};
