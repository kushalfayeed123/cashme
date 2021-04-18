import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cash_me/core/constants.dart';
import 'package:cash_me/core/models/transaction.model.dart';
import 'package:cash_me/core/models/transfer.model.dart';
import 'package:cash_me/core/models/user.model.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/core/providers/transaction_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/load_wallet/load_wallet.dart';
import 'package:cash_me/ui/views/transfer_screen/transfer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:connectivity/connectivity.dart';

class ScanScreen extends StatefulWidget {
  static const routeName = 'Scan';
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  BuildContext bcontext;

  UserModel userPayload;
  WalletModel walletPayload;
  TransactionModel transactionPayload;
  TransferModel qrPayload;

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      getInitValues();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void getInitValues() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<WalletProvider>(context, listen: false)
          .setUserWallet(_user.id);
      // await Provider.of<UserProvider>(context, listen: false)
      //     .setAllUsers(_user.id);
    } catch (e) {
      print(e);
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
                        // closeDialog();
                        await updateSenderWalllet();
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

  updateSenderWalllet() async {
    try {
      await Provider.of<WalletProvider>(context, listen: false)
          .getSenderWallet(qrPayload.senderId);

      var senderWallet =
          Provider.of<WalletProvider>(context, listen: false).senderWallet;
      var newBalance =
          senderWallet.legderBalance - int.parse(qrPayload.transferValue);
      // var sender = Provider.of<UserProvider>(context, listen: false).sender;

      WalletModel walletPayload = WalletModel(
          userId: qrPayload.receiverId,
          availableBalance: newBalance,
          legderBalance: newBalance,
          bvn: senderWallet.bvn,
          accountNumber: senderWallet.accountNumber,
          accountbank: senderWallet.accountbank);

      // transactionPayload = TransactionModel(
      //     type: 'debit',
      //     value: qrPayload.transferValue.toString(),
      //     senderName: sender.cashMeName,
      //     createdOn: DateTime.now(),
      //     modifiedOn: DateTime.now(),
      //     status: 'Pending',
      //     userId: sender.id);

      await Provider.of<WalletProvider>(context, listen: false)
          .updateWallet(senderWallet.id, walletPayload);
    } catch (e) {
      // closeDialog();
      throw Exception(e);
    }
  }

  void prePaymentAction() async {
    openLoadingDialog();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      closeDialog();
      showSuccessMessageDialog(
          'Your account has been credited with the sum of ₦${NumberFormat('#,###,000').format(int.parse(qrPayload.transferValue))}.');
    }
    try {
      var _user = Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<UserProvider>(context, listen: false)
          .setUser(qrPayload.email);
      var sender = Provider.of<UserProvider>(context, listen: false).sender;

      var _wallet =
          Provider.of<WalletProvider>(context, listen: false).userWallet;

      var newValue = _wallet.legderBalance + int.parse(qrPayload.transferValue);
      transactionPayload = TransactionModel(
          type: CREDIT,
          value: qrPayload.transferValue.toString(),
          senderName: sender.cashMeName,
          transactionMode: QR_TRANSFER,
          createdOn: DateTime.now(),
          modifiedOn: DateTime.now(),
          status: 'Pending',
          userId: _user.id);

      walletPayload =
          WalletModel(legderBalance: newValue, availableBalance: newValue);
      await Provider.of<WalletProvider>(context, listen: false)
          .updateWallet(_wallet.id, walletPayload);
      await Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transactionPayload);
      // closeDialog();

      await showSuccessMessageDialog(
          'Your account has been credited with the sum of ₦${NumberFormat('#,###,000').format(int.parse(qrPayload.transferValue))}.');
    } catch (e) {
      closeDialog();
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _wallet = Provider.of<WalletProvider>(context).userWallet;
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);
    Map<String, dynamic> qrCodeResult;
    setState(() => this.bcontext = context);

    final scanButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xFF002147),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          var codeScanner = await BarcodeScanner.scan();
          qrCodeResult = jsonDecode(codeScanner);
          setState(() {
            qrPayload = TransferModel.fromJson(qrCodeResult);
          });
          prePaymentAction();
        },
        child: Text(
          "Scan QR Code",
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
                    // logout();
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
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
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
                                padding: const EdgeInsets.only(
                                    left: 35.0, top: 20.0),
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
                                  '₦${_wallet.availableBalance > 0 ? NumberFormat('#,###,000').format(_wallet?.availableBalance) : _wallet?.availableBalance}',
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
                          '₦${_wallet.legderBalance > 0 ? NumberFormat('#,###,000').format(_wallet?.legderBalance) : _wallet?.legderBalance}',
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
                      'Scan QR code to receive money',
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
                        scanButton,
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
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 1.0,
          unselectedFontSize: 1.0,
          iconSize: 30.0,
          backgroundColor: Color(0xFFf4f9f9),
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.of(context).pushNamed(HomeScreen.routeName);
                break;
              case 1:
                Navigator.of(context).pushNamed(TransferScreen.routeName);

                break;
              // case 2:
              //   Navigator.of(context).pushNamed(TransferScreen.routeName);
              //   break;
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Color(0xFF002147),
              ),
              label: 'Send',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.add_circle_rounded,
            //     color: Color(0xff16c79a),
            //   ),
            //   label: 'Generate QR',
            // ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.send_to_mobile,
                  color: Color(0xFF002147),
                ),
                label: 'Scan QR'),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        ));
  }
}
