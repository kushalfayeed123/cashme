import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/ui/views/cash_out/cash_out_screen.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  void logout() async {
    print('got here');
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _authProvider.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(color: Color(0xff16c79a)),
        padding: EdgeInsets.only(left: 40.0, top: 100.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(CashoutScreen.routeName);
              },
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: Color(0xFF002147)),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Cash Out',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'San Francisco',
                        color: Color(0xFF002147)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Icon(Icons.settings, color: Color(0xFF002147)),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'San Francisco',
                        color: Color(0xFF002147)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                logout();
              },
              child: Row(
                children: [
                  Icon(Icons.logout, color: Color(0xFF002147)),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Logout',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'San Francisco',
                        color: Color(0xFF002147)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
