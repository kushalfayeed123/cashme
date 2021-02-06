import 'package:cash_me/core/providers/theme_provider.dart';
import 'package:cash_me/ui/shared/utils/app_theme.dart';
import 'package:cash_me/ui/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './ui/shared/utils/routes.dart' as rt;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).setDefaultTheme();
    });
    // getPermissions();
    super.initState();
  }

  // getPermissions() async {
  //   if (Settings.isAppInit) {
  //     var status = await Permission.contacts.status;
  //     if (status.isUndetermined) {
  //       await Permission.contacts.request();
  //     }
  //     Settings.isAppInit = false;
  //   }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Consumer<ThemeProvider>(
      builder: (ctx, theme, _) => MaterialApp(
        title: 'Cash Me',
        debugShowCheckedModeBanner: false,
        theme: theme.isDarkModeEnabled
            ? appThemeData[AppTheme.DarkTheme]
            : appThemeData[AppTheme.LightTheme],
        initialRoute: '/',
        routes: rt.routes,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (ctx) => SplashScreen());
        },
      ),
    );
  }
}
