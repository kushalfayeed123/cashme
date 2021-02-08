import 'package:cash_me/ui/views/create_account/create_account_screen.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:cash_me/ui/views/splash/splash_screen.dart';

final routes = {
  // EntryScreen.routeName: (ctx) => EntryScreen(),
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  CreateAccountScreen.routeName: (context) => CreateAccountScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
};
