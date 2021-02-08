import 'package:flutter/material.dart';

enum AppTheme { DarkTheme, LightTheme }
final appThemeData = {
  AppTheme.DarkTheme: ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Avenir Next',
    appBarTheme: AppBarTheme(
      color: Color(0xffccf2f4),
    ),
  ),
  AppTheme.LightTheme: ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Avenir Next',
    appBarTheme: AppBarTheme(
      color: Color(0xffccf2f4),
    ),
  ),
};
