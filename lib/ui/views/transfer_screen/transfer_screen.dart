import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:cash_me/core/constants.dart';
import 'package:cash_me/core/models/transaction.model.dart';
import 'package:cash_me/core/models/transfer.model.dart';
import 'package:cash_me/core/models/user.model.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/transaction_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/load_wallet/load_wallet.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:cash_me/ui/views/scan_screen/scan_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TransferScreen extends StatefulWidget {
  static const routeName = 'transfer';
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final qrdataFeed = TextEditingController();
  var selectedUser;

  String qrData = "value to be coded";
  TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);
  BuildContext bcontext;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool valueGenerated = false;
  UserModel userPayload;
  WalletModel walletPayload;
  TransactionModel transactionPayload;
  Map<String, dynamic> qrCodeResult;
  TransferModel qrPayload;

  // var newValue;

  bool _isInit = true;
  TransferModel transferPayload;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      getInitValues();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  final spinner = SpinKitRing(
    // type: SpinKitWaveType.end,
    color: Color(0xff16c79a),
    size: 50.0,
  );

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

  getInitValues() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<WalletProvider>(context, listen: false)
          .setUserWallet(_user.id);
      await Provider.of<UserProvider>(context, listen: false)
          .setAllUsers(_user.id);
    } catch (e) {
      print(e);
    }
  }

  showConfirmationDialog() {
    final _wallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;

    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;

    if (int.parse(qrdataFeed.text) > _wallet.availableBalance) {
      showErrorMessageDialog(
          'Sorry, this transcation can not be completed because you do not have sufficient funds.');
    } else {
      AwesomeDialog(
          context: context,
          animType: AnimType.BOTTOMSLIDE,
          customHeader: null,
          dialogType: DialogType.NO_HEADER,
          // padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
          dismissOnTouchOutside: false,
          body: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Column(
              children: [
                Text(
                  'You are about to transfer the sum of ₦${NumberFormat('#,###,#00').format(int.parse(qrdataFeed.text))}. Are you sure you want to continue?',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18.0,
                      color: Color(0xFF002147),
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Color(0xFF002147),
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width * 0.3,
                        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        onPressed: () {
                          if (qrdataFeed.text.isEmpty) {
                            setState(() {
                              qrData = "text";
                            });
                          } else {
                            setState(() {
                              transferPayload = TransferModel(
                                  createdOn: DateTime.now(),
                                  modifiedOn: DateTime.now(),
                                  type: QR_TRANSFER,
                                  senderId: currentUser.id,
                                  receiverId: '',
                                  email: currentUser.email,
                                  transferValue: qrdataFeed.text,
                                  walletId: _wallet.id,
                                  id: '',
                                  senderAvailableBalance: '');
                              qrData = qrdataFeed.text;
                              // valueGenerated = true;
                            });
                            prePaymentAction();
                          }
                        },
                        child: Text("Yes",
                            textAlign: TextAlign.center,
                            style: style.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Color(0xFF002147),
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width * 0.3,
                        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        onPressed: () async {
                          setState(() {
                            valueGenerated = false;
                          });
                          closeDialog();
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel",
                            textAlign: TextAlign.center,
                            style: style.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )).show();
    }
  }

  showSuccessMessageDialog(message) {
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

    AwesomeDialog(
        context: context,
        animType: AnimType.BOTTOMSLIDE,
        customHeader: null,
        dialogType: DialogType.NO_HEADER,
        // padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        dismissOnTouchOutside: false,
        body: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Column(
            children: [
              Text(
                message,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18.0,
                    color: Color(0xFF002147),
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Color(0xFF002147),
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width * 0.5,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () async {
                        closeDialog();
                        // await updateSenderWalllet();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            HomeScreen.routeName,
                            (Route<dynamic> route) => false);
                      },
                      child: Text("Ok",
                          textAlign: TextAlign.center,
                          style: style.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        )).show();
  }

  showErrorMessageDialog(message) {
    AwesomeDialog(
      context: context,
      animType: AnimType.BOTTOMSLIDE,
      showCloseIcon: true,
      customHeader: null,
      dialogType: DialogType.NO_HEADER,
      dismissOnTouchOutside: false,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
      body: Text(
        message,
        style: TextStyle(
            fontFamily: 'San Fransisco', fontSize: 17, color: Colors.red),
      ),
    ).show();
  }

  prePaymentAction() async {
    openLoadingDialog();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _wallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;
    final newValue = _wallet.legderBalance + int.parse(qrPayload.transferValue);
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      closeDialog();
      await showSuccessMessageDialog(
          'Your account has been credited with the sum of ₦${NumberFormat('#,###,#00').format(int.parse(qrPayload.transferValue))}.');
    }
    try {
      transactionPayload = TransactionModel(
          type: CREDIT,
          value: qrPayload.transferValue.toString(),
          senderName: _user.cashMeName,
          transactionMode: QR_TRANSFER,
          createdOn: DateTime.now(),
          modifiedOn: DateTime.now(),
          status: 'Completed',
          userId: _user.id,
          id: '');

      walletPayload = WalletModel(
          legderBalance: newValue,
          availableBalance: newValue,
          accountbank: '',
          accountNumber: '',
          bvn: '',
          id: '',
          userId: '');
      await Provider.of<WalletProvider>(context, listen: false)
          .updateWallet(_wallet.id, walletPayload);
      await Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transactionPayload);
      closeDialog();

      await showSuccessMessageDialog(
          'Your account has been credited with the sum of ₦${NumberFormat('#,###,#00').format(int.parse(qrPayload.transferValue))}.');
    } catch (e) {
      closeDialog();
      throw Exception(e);
    }
  }

  void logout() async {
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _authProvider.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName, (Route<dynamic> route) => false);
  }

  Future<void> openScanner() async {
    final codeScanner = await BarcodeScanner.scan();
    qrCodeResult = jsonDecode(codeScanner);
    setState(() {
      qrPayload = TransferModel.fromJson(qrCodeResult);
    });

    prePaymentAction();
  }

  void openBottomSheet(String type, String mode) {
    final users = Provider.of<UserProvider>(context, listen: false).allUsers;
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;

    final transferEditor = new Theme(
      data: new ThemeData(primaryColor: Color(0xFF002147)),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: qrdataFeed,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.money),
          hintText: "How much do you need?",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final usersField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFBDBDBD)),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: DropdownButtonHideUnderline(
          child: new DropdownButton<String>(
            hint: new Text('Select the user you want to transfer to'),
            value: selectedUser,
            isDense: false,
            onChanged: (value) {
              setState(() {
                selectedUser = value;
              });
            },
            items: users.map((UserModel map) {
              return new DropdownMenuItem<String>(
                value: map.id,
                child: new Text(map.cashMeName,
                    style: new TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
        ),
      ),
    );

    final _wallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,

        // bounce: true,
        // backgroundColor: Color(0xFFe8eae6),
        // expand: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                controller: ModalScrollController.of(context),
                child: Container(
                    // padding: EdgeInsets.symmetric(horizontal: 20.0),
                    height: MediaQuery.of(context).size.height,
                    child: type == 'receive'
                        ? Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                  ),
                                  child: Text(
                                    'Generate QR to Receive Money',
                                    style: TextStyle(
                                      color: Color(0xFF002147),
                                      fontFamily: 'San Francisco',
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // border: Border.all(color: Color(0xff16c79a), width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    width: MediaQuery.of(context).size.width *
                                        0.68,
                                    child: QrImage(
                                      data: jsonEncode(transferPayload),
                                      foregroundColor: Color(0xFF002147),
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   height: MediaQuery.of(context).size.height * 0.17,
                              // ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.075),
                                  width:
                                      MediaQuery.of(context).size.width * 0.96,
                                  height:
                                      MediaQuery.of(context).size.height * 0.30,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFe8eae6),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: valueGenerated
                                              ? RichText(
                                                  text: TextSpan(
                                                      text: 'QR for the sum of',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 18.0,
                                                          color:
                                                              Color(0xFF002147),
                                                          fontWeight:
                                                              FontWeight.w600),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                ' ₦${NumberFormat('#,###,#00').format(int.parse(qrdataFeed.text))}',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 18.0,
                                                                color: Color(
                                                                    0xff16c79a),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                        TextSpan(
                                                            text:
                                                                ' has been generated, please ensure the sender scans your qr code, then scan the sender\'s qr code to complete this transaction.',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize: 18.0,
                                                                color: Color(
                                                                    0xFF002147),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600))
                                                      ]),
                                                )
                                              : transferEditor,
                                        ),
                                        SizedBox(
                                          height: valueGenerated
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02
                                              : MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.07,
                                        ),
                                        Material(
                                          elevation: 5.0,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: Color(0xFF002147),
                                          child: MaterialButton(
                                            minWidth: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.fromLTRB(
                                                20.0, 15.0, 20.0, 15.0),
                                            onPressed: () async {
                                              valueGenerated
                                                  ? setState(() {
                                                      valueGenerated = false;
                                                      openScanner();
                                                    })
                                                  : mystate(() {
                                                      transferPayload =
                                                          TransferModel(
                                                              walletId:
                                                                  _wallet.id,
                                                              senderId: '',
                                                              receiverId:
                                                                  currentUser
                                                                      .id,
                                                              email: currentUser
                                                                  .email,
                                                              transferValue:
                                                                  qrdataFeed
                                                                      .text,
                                                              createdOn:
                                                                  DateTime
                                                                      .now(),
                                                              id: '',
                                                              modifiedOn:
                                                                  DateTime
                                                                      .now(),
                                                              senderAvailableBalance:
                                                                  '',
                                                              type: '');

                                                      // qrData = qrdataFeed.text;
                                                    });

                                              if (qrdataFeed.text.isEmpty) {
                                                setState(() {
                                                  qrData = "text";
                                                });
                                              } else {
                                                setState(() {
                                                  transferPayload =
                                                      TransferModel(
                                                          walletId: _wallet.id,
                                                          senderId: '',
                                                          receiverId:
                                                              currentUser.id,
                                                          email:
                                                              currentUser.email,
                                                          transferValue:
                                                              qrdataFeed.text,
                                                          createdOn:
                                                              DateTime.now(),
                                                          id: '',
                                                          modifiedOn:
                                                              DateTime.now(),
                                                          senderAvailableBalance:
                                                              '',
                                                          type: '');

                                                  qrData = qrdataFeed.text;
                                                });
                                                // prePaymentAction();
                                              }

                                              valueGenerated = true;
                                            },
                                            child: Text(
                                                valueGenerated
                                                    ? "Scan Sender's QR"
                                                    : "Generate",
                                                textAlign: TextAlign.center,
                                                style: style.copyWith(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                  ),
                                  child: Text(
                                    'Transfer via Cashme Name',
                                    style: TextStyle(
                                      color: Color(0xFF002147),
                                      fontFamily: 'San Francisco',
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      // border: Border.all(color: Color(0xff16c79a), width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    width: MediaQuery.of(context).size.width *
                                        0.68,
                                    child: Icon(
                                      Icons.send_to_mobile,
                                      size: 70,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.075),
                                  width:
                                      MediaQuery.of(context).size.width * 0.96,
                                  height:
                                      MediaQuery.of(context).size.height * 0.50,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFe8eae6),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: transferEditor,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.09,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: usersField,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.09,
                                        ),
                                        Material(
                                          elevation: 5.0,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: Color(0xFF002147),
                                          child: MaterialButton(
                                            minWidth: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.fromLTRB(
                                                20.0, 15.0, 20.0, 15.0),
                                            onPressed: () async {},
                                            child: Text("Transfer",
                                                textAlign: TextAlign.center,
                                                style: style.copyWith(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                    // ],
                    // ),
                    ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);

    // if (valueGenerated) {
    //   Navigator.of(context).pop();
    // }
    final _wallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

    final userButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xFF002147),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          // openBottomSheet('receive');
          // initiatePayment();
        },
        child: Text(
          "RECEIVE MONEY",
          textAlign: TextAlign.center,
          style:
              style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
    final qrButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xFF002147),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          openBottomSheet('receive', 'Generate');

          // initiatePayment();
        },
        child: Text(
          "TRANSFER MONEY",
          textAlign: TextAlign.center,
          style:
              style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xFFe8eae6),
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: Container(
          decoration: BoxDecoration(color: Color(0xff16c79a)),
          padding: EdgeInsets.only(left: 40.0, top: 100.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
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
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 20.0),
          child: RichText(
            text: TextSpan(
                text: 'CASH',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                      text: 'ME',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 30,
                          color: Color(0xFF002147),
                          fontWeight: FontWeight.bold))
                ]),
          ),
        ),
        elevation: 0.0,
        primary: false,
        backgroundColor: Color(0xff16c79a),
        actions: [
          Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.only(right: 20.0, top: 4.0),
              child: IconButton(
                icon: Text(
                  '...',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'San Francisco',
                  ),
                ),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.255,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)),
                    color: Color(0xff16c79a)),
                child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.046,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 35.0, top: 20.0),
                              child: Text(
                                'Available Balance:',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text(
                                '₦${_wallet.availableBalance > 0 ? NumberFormat('#,###,#00').format(_wallet.availableBalance) : _wallet.availableBalance}',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 33,
                                    color: Color(0xFF002147),
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(
                        //     height:
                        //         MediaQuery.of(context).size.height * 0.041),
                      ],
                    )),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.2),
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFF002147),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Total Balance:',
                        style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        '₦${_wallet.legderBalance > 0 ? NumberFormat('#,###,#00').format(_wallet.legderBalance) : _wallet.legderBalance}',
                        style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.normal),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.09,
                    top: MediaQuery.of(context).size.height * 0.33,
                    bottom: 0),
                child: SizedBox(
                  child: Text(
                    'Receive money by generating a QR code',
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16,
                        fontFamily: 'San Francisco',
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.25,
                    left: 30.0,
                    right: 30.0),
                child: Container(
                  child: Wrap(
                    children: [
                      // userButton,
                      // SizedBox(
                      //   height: 70,
                      // ),
                      qrButton
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF002147),
        unselectedItemColor: Color(0xFF002147),
        iconSize: 30.0,
        backgroundColor: Color(0xFFf4f9f9),
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushNamed(HomeScreen.routeName);

              // Navigator.push(context,
              //     CupertinoPageRoute(builder: (context) => TransferScreen()));
              break;
            case 1:
              Navigator.of(context).pushNamed(TransferScreen.routeName);
              break;

            case 2:
              Navigator.of(context).pushNamed(ScanScreen.routeName);
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Color(0xFF002147),
              ),
              label: 'Home',
              backgroundColor: Color(0xFF002147)),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.send_to_mobile,
              color: Color(0xFF002147),
            ),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF002147),
              ),
              label: 'Scan QR'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .pushReplacementNamed(LoadWalletScreen.routeName);
        },
        tooltip: 'Increment',
        backgroundColor: Color(0xFF002147),
        child: new Icon(
          Icons.add,
        ),
      ),
    );
  }
}
