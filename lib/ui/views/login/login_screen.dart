import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/ui/shared/utils/settings.dart';
import 'package:cash_me/ui/views/create_account/create_account_screen.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  openLoadingDialog() {
    AwesomeDialog(
            context: context,
            animType: AnimType.BOTTOMSLIDE,
            customHeader: null,
            dialogType: DialogType.NO_HEADER,
            dismissOnTouchOutside: false,
            body: spinner)
        .show();
  }

  closeDialog() {
    AwesomeDialog(context: context).dissmiss();
  }

  showErrorMessageDialog(message) {
    AwesomeDialog(
        context: context,
        animType: AnimType.BOTTOMSLIDE,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        showCloseIcon: true,
        customHeader: null,
        dialogType: DialogType.NO_HEADER,
        dismissOnTouchOutside: false,
        body: Text(
          message,
          style: TextStyle(
              fontFamily: 'San Fransisco', fontSize: 14, color: Colors.red),
        )).show();
  }

  final spinner = SpinKitRing(
    // type: SpinKitWaveType.end,
    color: Color(0xff16c79a),
    size: 50.0,
  );

  void _login() async {
    // if (!_formKey.currentState.validate()) return;
    // _formKey.currentState.save();
    openLoadingDialog();

    try {
      await Provider.of<AuthenticationProvider>(context, listen: false).signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await Provider.of<UserProvider>(context, listen: false)
          .setCurrentUser(false);
      Settings.userKeyRefernce =
          Provider.of<UserProvider>(context, listen: false)
              .currentUser
              .keyReference;
      closeDialog();
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } on HttpException catch (e) {
      closeDialog();
      showErrorMessageDialog(e.message);
    } catch (e) {
      closeDialog();
      showErrorMessageDialog(e);
    }
  }

  validateForm(value, type) {
    if (value == null || value.isEmpty) {
      if (type == 'email') {
        return 'Email is required';
      }

      if (type == 'password') {
        return 'Password is required';
      }

      return 'This field is required';
    }

    if (type == 'email') {
      String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
          "\\@" +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
          "(" +
          "\\." +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
          ")+";
      RegExp regExp = new RegExp(p);
      if (!regExp.hasMatch(value)) {
        return 'Enter a valid email address';
      }
    }
    if (type == 'password') {
      Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return 'Password must be at least 6 characters long and contain at least 1 lowercase, 1 uppercase, and 1 number.';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

    final emailField = new Theme(
      data: new ThemeData(primaryColor: Color(0xFF002147)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'email'),
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
      data: new ThemeData(primaryColor: Color(0xFF002147)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'password'),
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
      color: Color(0xFF002147),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _login();
          }
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
      backgroundColor: Color(0xff16c79a),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Form(
            key: _formKey,
            child: Container(
              child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 30.0, bottom: 20.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 0.2,
                            child: RichText(
                              text: TextSpan(
                                  text: 'CASH',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 40,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'ME',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 40,
                                            color: Color(0xFF002147),
                                            fontWeight: FontWeight.bold))
                                  ]),
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
                                  fontFamily: 'San Francisco',
                                  color: Color(0xFF002147)),
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
                                      color: Color(0xFF002147),
                                      fontSize: 14.0,
                                      fontFamily: 'San Francisco')),
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
      ),
    );
  }
}
