import 'package:cash_me/core/enums/theme_model.dart';
import 'package:cash_me/ui/shared/utils/settings.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Settings darkThemePref = Settings();

  bool _isDarkMode = false;
  bool get isDarkModeEnabled => _isDarkMode;

  String _currentTheme;
  String get currentTheme => _currentTheme;

  ThemeData _themeData;
  ThemeData get currentThemeData => _themeData;

  toggle() async {
    var theme = _currentTheme == CmThemeMode.dark
        ? CmThemeMode.light
        : CmThemeMode.dark;
    changeTheme(theme);
  }

  Future changeTheme(String theme) async {
    _currentTheme = theme;
    _isDarkMode = theme == CmThemeMode.auto
        ? MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .platformBrightness ==
            Brightness.dark
        : theme == CmThemeMode.dark;

    // AppColors.darkMode = _isDarkMode;
    Settings.themeMode = theme;
    notifyListeners();
  }

  Future setDefaultTheme() async {
    _currentTheme = Settings.themeMode ?? CmThemeMode.auto;
    _isDarkMode = _currentTheme == CmThemeMode.auto
        ? MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .platformBrightness ==
            Brightness.dark
        : _currentTheme == CmThemeMode.dark;

    // AppColors.darkMode = _isDarkMode;
    Settings.themeMode = _currentTheme;
    notifyListeners();
  }
}
