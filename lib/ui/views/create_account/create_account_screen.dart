import 'dart:async';

import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CreateAccountScreen extends StatefulWidget {
  static const routeName = '/create-account';
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  TextEditingController _cashmenameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _pinController = new TextEditingController();
  TextEditingController _passwordConfirmController =
      new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

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

  showSuccessMessageDialog(message) {
    AwesomeDialog(
        context: context,
        animType: AnimType.BOTTOMSLIDE,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
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
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        animType: AnimType.BOTTOMSLIDE,
        showCloseIcon: true,
        customHeader: null,
        dialogType: DialogType.ERROR,
        dismissOnTouchOutside: false,
        body: Text(
          message,
          style: TextStyle(
              fontFamily: 'San Fransisco', fontSize: 14, color: Colors.red),
        )).show();
  }

  closeDialog() {
    AwesomeDialog(context: context).dissmiss();
  }

  void _createAccount() async {
    openLoadingDialog();
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .registerUser(
        password: _passwordController.text,
        email: _emailController.text,
        cashMeName: _cashmenameController.text,
        fullName: '',
        pin: _pinController.text,
      );
      closeDialog();
      showSuccessMessageDialog('Your account has been created successfully');
      Timer(Duration(seconds: 5), () {
        Navigator.of(context).pushNamed(LoginScreen.routeName);
      });
    } catch (e) {
      closeDialog();
      showErrorMessageDialog(e.message);
    }
  }

  validateForm(value, type) {
    if (value == null || value.isEmpty) {
      if (type == 'name') {
        return 'CashMe Name is required';
      }
      if (type == 'email') {
        return 'Email is required';
      }
      if (type == 'phone') {
        return 'Phone is required';
      }
      if (type == 'pin') {
        return 'Pin is required';
      }
      if (type == 'password') {
        return 'Password is required';
      }
      if (type == 'confirmPass') {
        return 'Confirm Password is required';
      }
      return 'This field is required';
    }

    if (type == 'phone') {
      String p = r'(^(?:[+234])?[0-9]{6,}$)';
      RegExp regExp = new RegExp(p);
      if (value.length < 6 || value.length > 15 || !regExp.hasMatch(value)) {
        return 'Enter a valid phone number';
      }
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

    if (type == 'confirmPass') {
      if (_passwordController.text != _passwordConfirmController.text) {
        return 'Passwords do not match';
      }
    }
    if (type == 'pin') {
      if (_pinController.text.length != 4) {
        return 'Pin must be 4 digits.';
      }
    }
    return null;
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
    // final firstNameField = new Theme(
    //   data: new ThemeData(primaryColor: Color(0xFF002147)),
    //   child: TextField(
    //     keyboardType: TextInputType.text,
    //     controller: _firstnameController,
    //     obscureText: false,
    //     style: style,
    //     decoration: InputDecoration(
    //       contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    //       suffixIcon: Icon(Icons.person),
    //       hintText: "First Name",
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.circular(32.0),
    //           borderSide: BorderSide(color: Color(0xff16c79a))),
    //     ),
    //   ),
    // );
    // final lastNameField = new Theme(
    //   data: new ThemeData(primaryColor: Color(0xff16c79a)),
    //   child: TextField(
    //     keyboardType: TextInputType.text,
    //     // isRequired: true,
    //     controller: _lastnameController,
    //     obscureText: false,
    //     style: style,
    //     decoration: InputDecoration(
    //       contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    //       suffixIcon: Icon(Icons.person),
    //       hintText: "Last Name",
    //       border: OutlineInputBorder(
    //           borderRadius: BorderRadius.circular(32.0),
    //           borderSide: BorderSide(color: Color(0xff16c79a))),
    //     ),
    //   ),
    // );
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
    final cashMeNameField = new Theme(
      data: new ThemeData(primaryColor: Color(0xFF002147)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'name'),
        keyboardType: TextInputType.text,
        controller: _cashmenameController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.person),
          hintText: "CashMe Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );

    final phoneField = new Theme(
      data: new ThemeData(primaryColor: Color(0xFF002147)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'phone'),
        keyboardType: TextInputType.number,
        controller: _phoneController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.person),
          hintText: "Phone Number",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final pinField = new Theme(
      data: new ThemeData(primaryColor: Color(0xFF002147)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'pin'),
        keyboardType: TextInputType.number,
        controller: _pinController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.lock),
          hintText: "Create pin",
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
    final confirmPasswordField = new Theme(
      data: new ThemeData(primaryColor: Color(0xFF002147)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'confirmPass'),
        keyboardType: TextInputType.text,
        controller: _passwordConfirmController,
        obscureText: true,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.lock),
          hintText: "Confirm Password",
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
            _createAccount();
          }
        },
        child: Text("Create Account",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
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
                              'Create Account',
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
                        // firstNameField,
                        // SizedBox(height: 15.0),
                        // lastNameField,
                        // SizedBox(height: 15.0),
                        emailField,
                        SizedBox(height: 15.0),
                        cashMeNameField,
                        SizedBox(height: 15.0),

                        passwordField,
                        SizedBox(height: 15.0),
                        confirmPasswordField,
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
                                      color: Color(0xFF002147),
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
      ),
    );
  }
}

class SpinKitFadingCircle {}
