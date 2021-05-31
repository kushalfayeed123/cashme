import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cash_me/core/constants.dart';
import 'package:cash_me/core/models/bank.model.dart';
import 'package:cash_me/core/models/transaction.model.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/core/providers/transaction_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/load_wallet/load_wallet.dart';
import 'package:cash_me/ui/views/scan_screen/scan_screen.dart';
import 'package:cash_me/ui/views/transfer_screen/transfer_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CashoutScreen extends StatefulWidget {
  static const routeName = 'cash_out';

  @override
  _CashoutScreenState createState() => _CashoutScreenState();
}

class _CashoutScreenState extends State<CashoutScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _amountController = new TextEditingController();
  TextEditingController _accountController = new TextEditingController();
  TextEditingController _pinController = new TextEditingController();
  BankModel banks;
  var selectedBank;
  bool _isInit = true;

  var accCode;
  var accountName;

  @override
  void initState() {
    getBanks();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      getWallet();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> getBanks() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return;
    } else {
      await Provider.of<WalletProvider>(context, listen: false).setBanks();
    }
  }

  void getWallet() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<WalletProvider>(context, listen: false)
          .setUserWallet(_user.id);
    } catch (e) {
      print(e);
    }
  }

  getSelectedBank(value) {
    accCode = value;
  }

  validateForm(value, type) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (value == null || value.isEmpty) {
      if (type == 'accNum') {
        return 'Account Number is required';
      }
      if (type == 'amount') {
        return 'Amount is required';
      }
      if (type == 'pin') {
        return 'pin is required';
      }

      return 'This field is required';
    }

    if (type == 'pin') {
      if (_pinController.text.length != 4) {
        return 'Pin must be 4 digits.';
      }
      if (user.pin != _pinController.text) {
        return 'Pin is incorrect';
      }
    }
    return null;
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

  final spinner = SpinKitRing(
    color: Color(0xff16c79a),
    size: 50.0,
  );

  closeDialog() {
    AwesomeDialog(context: context).dissmiss();
  }

  showErrorMessageDialog(message) {
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

    AwesomeDialog(
        context: context,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        animType: AnimType.BOTTOMSLIDE,
        showCloseIcon: false,
        customHeader: null,
        dialogType: DialogType.NO_HEADER,
        dismissOnTouchOutside: false,
        body: Container(
          // height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Column(
            children: [
              Text(
                '$message',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18.0,
                    color: Colors.redAccent,
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
                      onPressed: () async {
                        closeDialog();
                        // AwesomeDialog(context: context).dissmiss();
                      },
                      child: Text("CLOSE",
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

  showSuccessMessageDialog(message, bool inProgress) {
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

    AwesomeDialog(
        context: context,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        animType: AnimType.BOTTOMSLIDE,
        showCloseIcon: false,
        customHeader: null,
        dialogType: DialogType.NO_HEADER,
        dismissOnTouchOutside: false,
        body: Container(
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
                      minWidth: MediaQuery.of(context).size.width * 0.3,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () async {
                        inProgress
                            ? closeDialog()
                            : Navigator.of(context).pushNamedAndRemoveUntil(
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
              ),
            ],
          ),
        )).show();
  }

  final transactionRef = 'MC-' + DateTime.now().toIso8601String();

  initiateCashout() async {
    openLoadingDialog();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final wallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;

    final payload = {
      "account_bank": accCode,
      "account_number": _accountController.text.trim(),
      "amount": int.parse(_amountController.text),
      "narration": 'Cashout',
      "currency": CURRENCY,
      "tx_ref": transactionRef,
      "debit_currency": CURRENCY,
      "email": user.email,
      "callback_url": 'https://cashme-webhook.herokuapp.com/cashout'
      // 'https://webhook.site/62515594-c78a-4c9c-89c2-24863a47c13c'
    };

    try {
      if (wallet.availableBalance < int.parse(_amountController.text)) {
        closeDialog();
        showErrorMessageDialog(
            'You do not have sufficient funds to complete this transaction');
      } else {
        await Provider.of<WalletProvider>(context, listen: false)
            .cashOut(payload);
        final cashOutRes =
            Provider.of<WalletProvider>(context, listen: false).cashOutRes;
        final transactionPayload = TransactionModel(
            type: 'Debit',
            value: _amountController.text,
            senderName: user.cashMeName,
            transactionMode: 'Cashout',
            createdOn: DateTime.now(),
            modifiedOn: DateTime.now(),
            status: 'Pending',
            userId: user.id,
            transactionRef: cashOutRes.data.reference);
        await Provider.of<TransactionProvider>(context, listen: false)
            .addTransaction(transactionPayload);
        closeDialog();
        showSuccessMessageDialog(
            'Your cashout transaction is in progress. You will be notified once it is done.',
            true);
        if (cashOutRes.status == 'success') {
          await Provider.of<WalletProvider>(context, listen: false)
              .setTransfer(cashOutRes.data.id);
          final transferVerificationRes =
              Provider.of<WalletProvider>(context, listen: false).transfer;
          if (transferVerificationRes.data.status == 'FAILED') {
            closeDialog();
            showErrorMessageDialog(
                transferVerificationRes.data.completeMessage);
          }
        } else {
          closeDialog();
          showErrorMessageDialog(cashOutRes.message);
        }
      }
    } catch (e) {
      closeDialog();
      print(e);
      // showErrorMessageDialog(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _wallet = Provider.of<WalletProvider>(context).userWallet;
    final _banks = Provider.of<WalletProvider>(context, listen: false).banks;
    final bankData = _banks?.data ?? [];
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

    final bankField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFBDBDBD)),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: DropdownButtonHideUnderline(
          child: new DropdownButton<String>(
            isExpanded: true,
            hint: new Text('Select your bank'),
            value: selectedBank,
            isDense: false,
            onChanged: (value) {
              getSelectedBank(value);
              setState(() {
                selectedBank = value;
              });
            },
            items: bankData.map((e) {
              return new DropdownMenuItem<String>(
                value: e.code,
                child:
                    new Text(e.name, style: new TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
        ),
      ),
    );

    final pinField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'pin'),
        keyboardType: TextInputType.number,
        controller: _pinController,
        obscureText: true,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.lock),
          hintText: "Enter your pin",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final accNumberField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'accNum'),
        keyboardType: TextInputType.number,
        controller: _accountController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.account_box),
          hintText: "Your Account number ",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final amountField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextFormField(
        validator: (value) => validateForm(value, 'amount'),
        keyboardType: TextInputType.number,
        controller: _amountController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.money),
          hintText: "How much do you want to transfer?",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final payButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xFF002147),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          // if (_formKey.currentState.validate()) {
          //   initiatePayment();
          // }
          initiateCashout();
        },
        child: Text(
          "Cash Out",
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
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: double.infinity,
          child: Form(
            key: _formKey,
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
                            'Ledger Balance:',
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
                        bottom: 50),
                    child: SizedBox(
                      child: Text(
                        'CASH OUT',
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
                          top: MediaQuery.of(context).size.height * 0.36,
                          left: 30.0,
                          right: 30.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 15.0),
                            bankField,
                            SizedBox(height: 15.0),
                            accNumberField,
                            SizedBox(height: 15.0),
                            amountField,
                            SizedBox(height: 15.0),
                            pinField,
                            SizedBox(height: 15.0),
                            payButon,
                            SizedBox(height: 15.0),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ),
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
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.system_update_rounded,
              color: Color(0xFF002147),
            ),
            label: 'Receive Money',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF002147),
              ),
              label: 'Scan QR'),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: new FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context)
      //         .pushReplacementNamed(LoadWalletScreen.routeName);
      //   },
      //   tooltip: 'Load Wallet',
      //   backgroundColor: Color(0xFF002147),
      //   child: new Icon(
      //     Icons.add,
      //   ),
      // ),
    );
  }
}
