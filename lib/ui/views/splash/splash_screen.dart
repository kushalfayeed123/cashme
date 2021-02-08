import 'dart:async';

import 'package:cash_me/core/models/user.model.dart';
import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/ui/shared/utils/settings.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController _textAnimationController;
  AuthenticationProvider _authenticationProvider = AuthenticationProvider();
  var _isInit = true;

  @override
  void initState() {
    _textAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    super.dispose();
  }

  startTime() async {
    var duration = new Duration(seconds: 5);
    return new Timer(duration, () => route());
  }

  route() async {
    try {
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //   LoginScreen.routeName,
      //   (Route<dynamic> route) => false,
      // );
      final isLoggedIn = await _authenticationProvider.isUserLoggedIn();

      if (isLoggedIn) {
        await Provider.of<UserProvider>(context, listen: false)
            .setCurrentUser(false);
        UserModel _user =
            Provider.of<UserProvider>(context, listen: false).currentUser;

        // await Provider.of<NotificationProvider>(context, listen: false)
        //     .setUserNotifications(_user?.id);
        Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.routeName, (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startTime();
      });
      setState(() => _isInit = false);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: initScreen(context),
    );
  }

  initScreen(BuildContext context) {
    double targetValue = MediaQuery.of(context).size.height * 0.3;

    return Scaffold(
      backgroundColor: Color(0xffccf2f4),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFf4f9f9),
                Color(0xFFccf2f4),
                Color(0xFFa4ebf3),
                Color(0xFFa4ebf3),
              ]),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: targetValue),
                    onEnd: () {
                      setState(() => targetValue = targetValue);
                    },
                    duration: Duration(seconds: 2),
                    builder: (BuildContext context, double size, Widget child) {
                      return Container(
                        height: size,
                        // child: Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [Text('CASH ME')],
                        // ),
                        // child: Image.asset(
                        //   'assets/images/logo.png',
                        //   fit: BoxFit.cover,
                        // ),
                      );
                    },
                  )
                ],
              ),
            ),
            // AnimatedBuilder(
            //   animation: _textAnimationController,
            //   builder: (context, widget) {
            //     return Column(
            //       children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [

            //           ],
            //         )
            //       ],
            //     );
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
