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
import 'package:cash_me/ui/shared/widgets/app_drawer.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/load_wallet/load_wallet.dart';
import 'package:cash_me/ui/views/transfer_screen/transfer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  TransferModel senderPayload;
  TransferModel transferPayload;
  bool valueGenerated;
  bool showButton = false;

  TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

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
                        closeDialog();
                        // await updateSenderWalllet();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            HomeScreen.routeName,
                            (Route<dynamic> route) => false);
                      },
                      child: Text("OK",
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

  showErrorMessageDialog(message) {
    AwesomeDialog(
        context: context,
        animType: AnimType.BOTTOMSLIDE,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        showCloseIcon: true,
        customHeader: null,
        dialogType: DialogType.NO_HEADER,
        dismissOnTouchOutside: false,
        body: Container(
          padding: EdgeInsets.all(20),
          child: Text(
            message,
            style: TextStyle(
                fontFamily: 'San Fransisco', fontSize: 14, color: Colors.red),
          ),
        )).show();
  }

  senderPayment() async {
    openLoadingDialog();
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .setUser(qrPayload.email);
      final currentUser =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      final _wallet =
          Provider.of<WalletProvider>(context, listen: false).userWallet;
      final receiverName = Provider.of<UserProvider>(context, listen: false)
          .selectedUser
          .cashMeName;

      setState(() {
        senderPayload = TransferModel(
            walletId: _wallet.id,
            senderId: currentUser.id,
            receiverId: qrPayload.receiverId,
            email: qrPayload.email,
            transferValue: qrPayload.transferValue,
            id: '',
            senderAvailableBalance: '',
            type: '');
      });

      transferPayload = TransferModel(
          type: QR_TRANSFER,
          senderId: currentUser.id,
          receiverId: senderPayload.receiverId,
          email: currentUser.email,
          transferValue: senderPayload.transferValue,
          walletId: _wallet.id,
          id: '',
          senderAvailableBalance: '');

      if (int.parse(transferPayload.transferValue) > _wallet.availableBalance) {
        closeDialog();
        showErrorMessageDialog(
            'You do not have sufficient balance to complete this transaction.');
      } else {
        var newValue =
            _wallet.availableBalance - int.parse(transferPayload.transferValue);

        transactionPayload = TransactionModel(
            type: DEBIT,
            value: transferPayload.transferValue.toString(),
            senderName: currentUser.cashMeName,
            transactionMode: QR_TRANSFER,
            createdOn: DateTime.now(),
            modifiedOn: DateTime.now(),
            status: 'Completed',
            userId: currentUser.id,
            receiverName: receiverName,
            id: '');

        walletPayload = WalletModel(
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
      }
    } catch (e) {
      closeDialog();
      throw Exception(e);
    }
  }

  openBottomSheet() async {
    senderPayment();

    await Provider.of<UserProvider>(context, listen: false)
        .setUser(qrPayload.email);
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;

    final _wallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;
    final receiverName =
        Provider.of<UserProvider>(context, listen: false).selectedUser;
    setState(() {
      senderPayload = TransferModel(
          walletId: _wallet.id,
          senderId: currentUser.id,
          receiverId: qrPayload.receiverId,
          email: qrPayload.email,
          transferValue: qrPayload.transferValue,
          id: '',
          senderAvailableBalance: '',
          type: '');
    });

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
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
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 20,
                          ),
                          child: Text(
                            'Generate QR to Send Money.',
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
                        height: MediaQuery.of(context).size.height * 0.12,
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.08),
                          child: Container(
                            decoration: BoxDecoration(
                              // border: Border.all(color: Color(0xff16c79a), width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: MediaQuery.of(context).size.width * 0.68,
                            child: QrImage(
                              data: jsonEncode(senderPayload),
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
                              top: MediaQuery.of(context).size.height * 0.055),
                          width: MediaQuery.of(context).size.width * 0.96,
                          height: MediaQuery.of(context).size.height * 0.30,
                          decoration: BoxDecoration(
                              color: Color(0xFFe8eae6),
                              borderRadius: BorderRadius.circular(10)),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: RichText(
                                    text: TextSpan(
                                        text: 'You are transfering the sum of',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 18.0,
                                            color: Color(0xFF002147),
                                            fontWeight: FontWeight.w600),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  ' ₦${NumberFormat('#,###,##0').format(int.parse(qrPayload.transferValue))}',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 18.0,
                                                  color: Color(0xff16c79a),
                                                  fontWeight: FontWeight.w600)),
                                          TextSpan(
                                              text:
                                                  ' to ${receiverName.cashMeName}. ${receiverName.cashMeName} must scan this QR code to complete this transcation. ',
                                              style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 18.0,
                                                  color: Color(0xFF002147),
                                                  fontWeight: FontWeight.w600))
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                if (showButton)
                                  Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: Color(0xFF002147),
                                    child: MaterialButton(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.fromLTRB(
                                          20.0, 10.0, 20.0, 15.0),
                                      onPressed: () async {
                                        mystate(() {
                                          senderPayload = TransferModel(
                                              walletId: _wallet.id,
                                              senderId: currentUser.id,
                                              receiverId:
                                                  senderPayload.receiverId,
                                              email: currentUser.email,
                                              transferValue:
                                                  senderPayload.transferValue,
                                              id: '',
                                              senderAvailableBalance: '',
                                              type: '');
                                        });
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                HomeScreen.routeName,
                                                (Route<dynamic> route) =>
                                                    false);
                                      },
                                      child: Text("DONE",
                                          textAlign: TextAlign.center,
                                          style: style.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                else
                                  Container(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ],
                  // ),
                ),
              ),
            );
          });
        });
  }

  void prePaymentAction() async {
    // openLoadingDialog();

    var _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    var _wallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;
    setState(() {
      senderPayload = TransferModel(
          senderId: _user.id,
          receiverId: qrPayload.receiverId,
          transferValue: qrPayload.transferValue,
          email: '',
          id: '',
          senderAvailableBalance: '',
          type: '',
          walletId: '');
    });

    if (qrPayload.senderId == '') {
      openBottomSheet();
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
    setState(() {
      this.bcontext = context;
      Future.delayed(Duration(seconds: 10), () {
        showButton = true;
      });
    });

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
        drawer: AppDrawer(),
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
                  onPressed: () => Scaffold.of(context).openDrawer(),
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
                                  '₦${_wallet.availableBalance > 0 ? NumberFormat('#,###,##0').format(_wallet.availableBalance) : _wallet.availableBalance}',
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
                          'Legder Balance:',
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
                          '₦${_wallet.legderBalance > 0 ? NumberFormat('#,###,##0').format(_wallet.legderBalance) : _wallet.legderBalance}',
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
                      'Scan QR code to transfer money',
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
                      top: MediaQuery.of(context).size.height * 0.35,
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

              // case 2:
              //   Navigator.of(context).pushNamed(ScanScreen.routeName);
              //   break;
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Color(0xFF002147),
              ),
              label: 'Home',
            ),
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
        ));
  }
}
