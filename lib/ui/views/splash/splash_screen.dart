import 'dart:async';

import 'package:cash_me/core/models/user.model.dart';
import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:provider/provider.dart';

class SplashScreenUi extends StatefulWidget {
  static const routeName = '/';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenUi>
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

  startTime() async {
    var duration = new Duration(seconds: 5);
    return new Timer(duration, () => route());
  }

  route() async {
    try {
      final isLoggedIn = await _authenticationProvider.isUserLoggedIn();

      if (isLoggedIn) {
        await Provider.of<UserProvider>(context, listen: false)
            .setCurrentUser(false);
        UserModel _user =
            Provider.of<UserProvider>(context, listen: false).currentUser;
        await Provider.of<WalletProvider>(context, listen: false)
            .setUserWallet(_user.id);

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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: initScreen(context),
    );
  }

  initScreen(BuildContext context) {
    return SplashScreen(
      seconds: 20,
      navigateAfterSeconds: route(),
      backgroundColor: Color(0xff16c79a),
      loadingText: Text('Loading'),
      loaderColor: Colors.white,
      title: Text(
        'CASHME',
        style: TextStyle(
            color: Color(0xFFffffff),
            fontSize: 40,
            fontWeight: FontWeight.bold),
      ),
    );

    // return Scaffold(
    //   // backgroundColor: Color(0xffccf2f4),
    //   body: Container(
    //     decoration: BoxDecoration(color: Color(0xff16c79a)),
    //     padding: EdgeInsets.symmetric(horizontal: 32),
    //     child: Column(
    //       children: [
    //         Expanded(
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               TweenAnimationBuilder(
    //                 curve: Curves.easeInOutQuad,
    //                 tween: Tween<double>(begin: 0.0, end: 100.0),
    //                 onEnd: () {
    //                   setState(() => targetValue = targetValue);
    //                 },
    //                 duration: Duration(seconds: 7),
    //                 builder: (BuildContext context, double size, Widget child) {
    //                   return Container(
    //                     height: size,
    //                     child: Center(
    //                         child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Text(
    //                           'CASH ',
    //                           style: TextStyle(
    //                               fontFamily: 'San Fransisco',
    //                               fontSize: 40,
    //                               color: Colors.white,
    //                               fontWeight: FontWeight.bold),
    //                         ),
    //                         Text(
    //                           'Me ',
    //                           style: TextStyle(
    //                               fontFamily: 'San Fransisco',
    //                               fontSize: 40,
    //                               color: Color(0xFF002147),
    //                               fontWeight: FontWeight.bold),
    //                         ),
    //                       ],
    //                     )),
    //                   );
    //                 },
    //               )
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
