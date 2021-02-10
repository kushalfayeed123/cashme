import 'dart:async';

import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class CreateAccountScreen extends StatefulWidget {
  static const routeName = '/create-account';
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  TextEditingController _firstnameController = new TextEditingController();
  TextEditingController _lastnameController = new TextEditingController();
  TextEditingController _cashmenameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _pinController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  OverlayEntry _overlayEntry;

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  openLoadingDialog() {
    AwesomeDialog(
            context: context,
            animType: AnimType.SCALE,
            customHeader: null,
            dialogType: DialogType.NO_HEADER,
            dismissOnTouchOutside: false,
            body: spinner)
        .show();
  }

  showSuccessMessageDialog(message) {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        showCloseIcon: true,
        customHeader: null,
        dialogType: DialogType.SUCCES,
        dismissOnTouchOutside: false,
        body: Text(
          message,
          style: TextStyle(fontFamily: 'San Fransisco', fontSize: 14),
        )).show();
  }

  showErrorMessageDialog(message) {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        showCloseIcon: true,
        customHeader: null,
        dialogType: DialogType.ERROR,
        dismissOnTouchOutside: false,
        body: Text(
          message,
          style: TextStyle(
              fontFamily: 'San Fransisco',
              fontSize: 14,
              color: Color(0xFF002147)),
        )).show();
  }

  closeDialog() {
    AwesomeDialog(context: context).dissmiss();
  }

  void _createAccount() async {
    // spinkit();
    // setState(() => _autoValidate = true);
    // if (!_formKey.currentState.validate()) return null;
    // _formKey.currentState.save();
    openLoadingDialog();
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .registerUser(
              password: _passwordController.text,
              email: _emailController.text,
              firstName: _firstnameController.text,
              lastName: _lastnameController.text,
              cashMeName: _cashmenameController.text,
              pin: _pinController.text);
      closeDialog();
      showSuccessMessageDialog('Your account has been created successfully');
      Timer(Duration(seconds: 5), () {
        Navigator.of(context).pushNamed(LoginScreen.routeName);
      });
    } catch (e) {
      closeDialog();
      showErrorMessageDialog(e);
    }
  }

  final spinner = SpinKitRing(
    // type: SpinKitWaveType.end,
    color: Color(0xff16c79a),
    size: 50.0,
  );

  Widget build(BuildContext context) {
    //   final spinner = SpinKitRing(
    //   // type: SpinKitWaveType.end,
    //   color: Color(0xff16c79a),
    //   size: 50.0,
    // );

    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);
    final firstNameField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: _firstnameController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.person),
          hintText: "First Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final lastNameField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.text,
        // isRequired: true,
        controller: _lastnameController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.person),
          hintText: "Last Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
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
    final cashMeNameField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: _cashmenameController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.person),
          hintText: "Cashme Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final pinField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _pinController,
        obscureText: true,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.lock),
          hintText: "Pin",
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
          _createAccount();
        },
        child: Text("Create Account",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFe8eae6),
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
                            'Create Account',
                            style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'San Francisco',
                                color: Color(0xff16c79a)),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 10.0),
                      ),
                      SizedBox(height: 15.0),
                      firstNameField,
                      SizedBox(height: 15.0),
                      lastNameField,
                      SizedBox(height: 15.0),
                      emailField,
                      SizedBox(height: 15.0),
                      cashMeNameField,
                      SizedBox(height: 15.0),
                      passwordField,
                      SizedBox(height: 15.0),
                      pinField,
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
                            child: Text("Already have an account? Login",
                                style: TextStyle(
                                    color: Color(0xff16c79a),
                                    fontSize: 14.0,
                                    fontFamily: 'San Francisco')),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(LoginScreen.routeName);
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

class SpinKitFadingCircle {}
