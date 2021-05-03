import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cash_me/core/constants.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cash_me/core/models/account_charge.model.dart';
import 'package:cash_me/core/models/bank.model.dart';
import 'package:cash_me/core/models/charge_response.model.dart';
import 'package:cash_me/core/models/requery_response.dart';
import 'package:cash_me/core/models/transaction.model.dart';
import 'package:cash_me/core/models/user.model.dart';
import 'package:cash_me/core/models/wallet.model.dart';
import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/transaction_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/core/services/wallet.service.dart';
import 'package:cash_me/locator.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:cash_me/ui/views/scan_screen/scan_screen.dart';
import 'package:cash_me/ui/views/transfer_screen/transfer_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:tripledes/tripledes.dart';
// import 'package:flutterwave/flutterwave.dart';

class LoadWalletScreen extends StatefulWidget {
  static const routeName = 'load_wallet';

  @override
  _LoadWalletScreenState createState() => _LoadWalletScreenState();
}

class _LoadWalletScreenState extends State<LoadWalletScreen>
    with SingleTickerProviderStateMixin {
  // BuildContext context;
  BuildContext bcontext;
  bool showOtpField = false;
  String flwRef;
  TextEditingController _otpController = new TextEditingController();
  TextEditingController _accountController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _bvnController = new TextEditingController();
  TextEditingController _amountController = new TextEditingController();
  TextEditingController _pinController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  UserModel userPayload;
  WalletModel walletPayload;
  TransactionModel transactionPayload;
  var banks = <BankModel>[];
  var selectedBank;
  var _requeryUrl, _queryCount = 0, _reQueryTxCount = 0, _waitDuration = 0;
  bool isFirst;

  @override
  void initState() {
    super.initState();
    getBanks();
    final wallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;
    if (wallet.accountNumber.isEmpty || wallet.accountbank.isEmpty) {
      isFirst = true;
    } else {
      isFirst = false;
    }
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

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      getWallet();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  var accCode;
  var accountName;
  var firstName;
  var lastName;

  getSelectedBank(value) {
    accCode = value;
  }

  verifyAccountNumber() async {
    AccountCharge chargePayload = AccountCharge(
      destbankcode: selectedBank,
      pbfPubKey: PUBLIC_KEY.toString(),
      recipientaccount: _accountController.text,
    );

    accountName = await locator<WalletService>().verifyAccount(chargePayload);
    // firstName = accountName.split()[0];
    // lastName = accountName.split()[1];
  }

  logout() async {
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _authProvider.signOut();
    Navigator.of(context).pushNamed(LoginScreen.routeName);
  }

  getBanks() async {
    await WalletService.getBanks().then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        banks = list.map((model) => BankModel.fromJson(model)).toList();
      });
    });
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

  void postPaymentAction(int amount) async {
    // openLoadingDialog();

    try {
      var _user = Provider.of<UserProvider>(context, listen: false).currentUser;
      var _wallet =
          Provider.of<WalletProvider>(context, listen: false).userWallet;

      userPayload = UserModel(
          pin: _pinController.text,
          fullName: '',
          phoneNumber: _phoneController.text,
          modifiedOn: DateTime.now(),
          modifiedBy: _user.cashMeName);

      // walletPayload = WalletModel(
      //     accountNumber: _accountController.text,
      //     accountbank: selectedBank,
      //     bvn: _bvnController.text,
      //     availableBalance: int.parse(_amountController.text),
      //     legderBalance: int.parse(_amountController.text));

      transactionPayload = TransactionModel(
        userId: _user.id,
        type: CREDIT,
        status: 'Completed',
        value: _amountController.text,
        senderName: _user.cashMeName,
        transactionMode: WALLET_LOAD,
        modifiedOn: DateTime.now(),
        createdOn: DateTime.now(),
      );

      var newValue = _wallet.legderBalance + amount;

      walletPayload =
          WalletModel(legderBalance: newValue, availableBalance: newValue);
      await Provider.of<WalletProvider>(context, listen: false)
          .updateWallet(_wallet.id, walletPayload);
      await Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transactionPayload);
      closeDialog();

      showSuccessMessageDialog(
          'You have successfully loaded your wallet with the sum of ₦${NumberFormat('#,###,000').format(int.parse(_amountController.text))}');
      Future.delayed(Duration(microseconds: 300));
    } catch (e) {
      closeDialog();
      throw Exception(e);
    }
  }

  showSuccessMessageDialog(message) {
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

    AwesomeDialog(
        context: context,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        animType: AnimType.BOTTOMSLIDE,
        showCloseIcon: false,
        customHeader: null,
        dialogType: DialogType.NO_HEADER,
        dismissOnTouchOutside: false,
        body:

            // Text(
            //   message,
            //   style: TextStyle(fontFamily: 'San Fransisco', fontSize: 14),
            // )
            //
            Container(
          height: MediaQuery.of(context).size.height * 0.35,
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
                        closeDialog();
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

  final spinner = SpinKitRing(
    // type: SpinKitWaveType.end,
    color: Color(0xff16c79a),
    size: 50.0,
  );

  dispose() {
    super.dispose();
  }

  void initiatePayment() async {
    // verifyAccountNumber();
    openLoadingDialog();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      closeDialog();
      showSuccessMessageDialog(
          'Sorry, you can not load your wallet at the moment because you may not be connected to the internet. Please connect and try again.');
      return;
    }
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final _userWallet =
        Provider.of<WalletProvider>(context, listen: false).userWallet;

    var payLoad = {
      "account_bank": _userWallet.accountbank.isEmpty
          ? selectedBank.toString().trim()
          : _userWallet.accountbank.trim(),
      "account_number": _userWallet.accountNumber.isEmpty
          ? _accountController.text.trim()
          : _userWallet.accountNumber.trim(),
      "amount": _amountController.text.trim(),
      "email": _user.email.toString().trim(),
      // "email": 'segunajanaku617@gmail.com',
      "tx_ref": 'MC-' + DateTime.now().toIso8601String(),
      "currency": CURRENCY.toString().trim(),
      "fullname": 'Forest',
      "firstname": 'Forest',
      "lastname": 'Green',
      "phone_number": _user.phoneNumber.trim(),
    };

    try {
      await Provider.of<WalletProvider>(context, listen: false)
          .loadWallet('$SANDBOX_CHARGE_ENDPOINT', payLoad);

      final response = Provider.of<WalletProvider>(context, listen: false).res;

      if (response == null) {
        closeDialog();
        showErrorMessageDialog(
            'Sorry, we could not load your wallet. Please try again later.');
      } else {
        setState(() {
          showOtpField = true;
          flwRef = response.data.flwRef;
        });
        if (response.data.status == 'successful') {
          postPaymentAction(response.data.amount);
        } else {
          print(response.data.status);
        }
      }
    } catch (e) {
      closeDialog();
      showErrorMessageDialog(e.message);
    }
  }

  verifyCharge(String id) async {
    await Provider.of<WalletProvider>(context, listen: false).verifyCharge(id);
    var res = Provider.of<WalletProvider>(context, listen: false).validateRes;
    // print(res.data);
  }

  // validateCharge() async {
  //   final payload = {
  //     "otp": '12345',
  //     "flw_ref": flwRef.trim(),
  //     "type": 'account',
  //     "pubKey": PUBLIC_KEY.trim()
  //   };
  //   try {
  //     await Provider.of<WalletProvider>(context, listen: false)
  //         .validateCharge(payload);
  //     final validateRes =
  //         Provider.of<WalletProvider>(context, listen: false).validateRes;
  //     print(validateRes);
  //   } catch (e) {
  //     closeDialog();
  //     print(e);
  //   }
  // }

  encryptJsonPayload(String encryptionKey, String publicKey, payload) {
    String encoded = jsonEncode(payload);
    String encrypted = getEncryptedData(encoded, encryptionKey);

    final encryptedPayload = {
      "PBFPubKey": publicKey,
      "client": encrypted,
      "alg": "3DES-24"
    };

    return encryptedPayload;
  }

  String getEncryptedData(encoded, encryptionKey) {
    return encrypt(encryptionKey, encoded);
  }

  String encrypt(key, text) {
    var blockCipher = BlockCipher(TripleDESEngine(), key);
    var i = blockCipher.encodeB64(text);
    return i;
  }

  int _selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1908),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
    _dobController.text = selectedDate.toString();
  }

  @override
  Widget build(BuildContext context) {
    final _wallet = Provider.of<WalletProvider>(context).userWallet;

    setState(() => this.bcontext = context);

    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

    final bankField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: DropdownButtonHideUnderline(
          child: new DropdownButton<String>(
            hint: new Text('Select your bank'),
            value: selectedBank,
            isDense: false,
            onChanged: (String value) {
              getSelectedBank(value);
              setState(() {
                selectedBank = value;
              });
              print(selectedBank);
            },
            items: banks.map((BankModel map) {
              return new DropdownMenuItem<String>(
                value: map.bankcode,
                child: new Text(map.bankname,
                    style: new TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
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
          hintText: "Enter your pin",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );

    final phoneField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.phone,
        controller: _phoneController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.lock),
          hintText: "Your phone number",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );

    final accNumberField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
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

    final dobField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: GestureDetector(
        onTap: () {
          _selectDate(context);
        },
        child: TextField(
          enabled: false,
          keyboardType: TextInputType.number,
          controller: _dobController,
          obscureText: false,
          style: style,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            suffixIcon: Icon(Icons.date_range),
            hintText: "Your date of birth",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
                borderSide: BorderSide(color: Color(0xff16c79a))),
          ),
        ),
      ),
    );

    // new MaterialButton(
    //     color: Color(0xff16c79a),
    //     onPressed: () {
    //       _selectDate(context);
    //     },
    //     child: new Text("Pick date range"));
    final bvnField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _bvnController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.lock),
          hintText: "BVN",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final amountField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _amountController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.money),
          hintText: "How much do you want to load?",
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
          initiatePayment();
        },
        child: Text(
          "Load Wallet",
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: double.infinity,
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
                      bottom: 50),
                  child: SizedBox(
                    child: Text(
                      'Load Your Wallet',
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
                          // isFirst ? SizedBox(height: 15.0) : Container(),
                          // isFirst ? phoneField : Container(),
                          // isFirst ? SizedBox(height: 15.0) : Container(),
                          // isFirst ? bvnField : Container(),
                          // isFirst ? SizedBox(height: 15.0) : Container(),
                          // isFirst ? dobField : Container(),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: Colors.blueGrey),
        unselectedLabelStyle: TextStyle(color: Colors.blueGrey),
        selectedFontSize: 1.0,
        unselectedFontSize: 1.0,
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
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: new FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).pushNamed(LoadWalletScreen.routeName);
      //   },
      //   tooltip: 'Increment',
      //   backgroundColor: Color(0xff16c79a),
      //   child: new Icon(
      //     Icons.add,
      //   ),
      // ),
    );
  }
}
