import 'dart:io';

import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/ui/shared/utils/settings.dart';
import 'package:cash_me/ui/views/create_account/create_account_screen.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _autoValidate = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _login() async {
    setState(() => _autoValidate = true);
    // if (!_formKey.currentState.validate()) return;
    // _formKey.currentState.save();
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false).signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await Provider.of<UserProvider>(context, listen: false)
          .setCurrentUser(false);
      // Settings.userKeyRefernce =
      //     Provider.of<UserProvider>(context, listen: false)
      //         .currentUser
      //         .keyReference;
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } on HttpException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

    final emailField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.email),
          hintText: "Email",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );

    final passwordField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: _passwordController,
        obscureText: true,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.lock),
          hintText: "Password",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff16c79a),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          _login();
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
      backgroundColor: Color(0xFFf4f9f9),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Container(
            child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width * 0.4,
                          child: Image.asset(
                            "assets/images/logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Padding(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                color: Color(0xff16c79a)),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 10.0),
                      ),
                      SizedBox(height: 15.0),
                      emailField,
                      SizedBox(height: 15.0),
                      passwordField,
                      SizedBox(height: 15.0),
                      loginButon,
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 10.0,
                          ),
                          InkWell(
                            child: Text("Create an Account",
                                style: TextStyle(
                                    color: Color(0xff16c79a),
                                    fontSize: 14.0,
                                    fontFamily: 'Montserrat')),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(CreateAccountScreen.routeName);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
