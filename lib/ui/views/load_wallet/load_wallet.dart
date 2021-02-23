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
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:tripledes/tripledes.dart';
import 'package:flutterwave/flutterwave.dart';

class LoadWalletScreen extends StatefulWidget {
  static const routeName = 'load_wallet';

  @override
  _LoadWalletScreenState createState() => _LoadWalletScreenState();
}

class _LoadWalletScreenState extends State<LoadWalletScreen>
    with SingleTickerProviderStateMixin {
  // BuildContext context;
  BuildContext bcontext;

  TextEditingController _accountController = new TextEditingController();
  TextEditingController _dobController = new TextEditingController();
  TextEditingController _bvnController = new TextEditingController();
  TextEditingController _amountController = new TextEditingController();
  TextEditingController _pinController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  UserModel userPayload;
  WalletModel walletPayload;
  TransactionModel transactionPayload;
  var banks = new List<BankModel>();
  var selectedBank;
  var _requeryUrl, _queryCount = 0, _reQueryTxCount = 0, _waitDuration = 0;
  bool isFirst;

  @override
  void initState() {
    super.initState();
    getBanks();
    var _transactions = Provider.of<TransactionProvider>(context, listen: false)
        .userTransactions;
    if (_transactions == null || _transactions.length < 1) {
      isFirst = true;
    } else {
      isFirst = false;
    }
  }

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

    print(accountName);
  }

  void _requeryTx(String flwRef) async {
    if (_reQueryTxCount < MAX_REQUERY_COUNT) {
      _reQueryTxCount++;
      final requeryRequestBody = {"PBFPubKey": PUBLIC_KEY, "flw_ref": flwRef};

      var response = await WalletService()
          .loadWallet(REQUERY_ENDPOINT, requeryRequestBody);
      //  await Provider.of<WalletProvider>(context, listen: false)
      //     .loadWallet(REQUERY_ENDPOINT, requeryRequestBody);

      if (response == null) {
        closeDialog();
        showErrorMessageDialog(
            'Payment processing failed. Please try again later.');
      } else {
        var requeryResponse = RequeryResponse.fromJson(response);
        if (requeryResponse.data == null) {
          print('Payment processing failed. Please try again later.');
        } else if (requeryResponse.data.chargeResponseCode == '02' &&
            requeryResponse.data.status != 'failed') {
          _onPollingComplete(flwRef);
        } else if (requeryResponse.data.chargeResponseCode == '00') {
          _onPaymentSuccessful();
        } else {
          showErrorMessageDialog('payment failed');
          closeDialog();

          print('payment failed');
          // _showToast(
          //     context, 'Payment processing failed. Please try again later.');
          // _dismissMobileMoneyDialog(false);
        }
      }
    } else if (_reQueryTxCount == MAX_REQUERY_COUNT) {
      showErrorMessageDialog('Request Timed out');
      print('timeout');
      // _showToast(
      //     context, 'Payment processing timeout. Please try again later.');
      // _dismissMobileMoneyDialog(false);
    }
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

  _continueProcessingAfterCharge(
      Map<String, dynamic> response, bool firstQuery) {
    print('charge continued');
    var chargeResponse = ChargeResponse.fromJson(response, firstQuery);
    if (chargeResponse.data != null && chargeResponse.data.flwRef != null) {
      _requeryTx(chargeResponse.data.flwRef);
    } else {
      if (chargeResponse.status == 'success' &&
          chargeResponse.data.pingUrl != null) {
        _waitDuration = chargeResponse.data.wait;
        _requeryUrl = '${chargeResponse.data.pingUrl}?use_polling=1';
        Timer(Duration(milliseconds: chargeResponse.data.wait), () {
          _chargeAgainAfterDuration(chargeResponse.data.pingUrl);
        });
      } else if (chargeResponse.status == 'success' &&
          chargeResponse.data.status == 'pending') {
        Timer(Duration(milliseconds: _waitDuration), () {
          _chargeAgainAfterDuration(_requeryUrl);
        });
      } else if (chargeResponse.status == 'success' &&
          chargeResponse.data.status == 'completed' &&
          chargeResponse.data.flwRef != null) {
        _requeryTx(chargeResponse.data.flwRef);
      } else {
        showErrorMessageDialog('Payment failed');
        closeDialog();
        print('payment failed');
        // _showToast(
        //     context, 'Payment processing failed. Please try again later.');
        // _dismissMobileMoneyDialog(false);
      }
    }
  }

  void _chargeAgainAfterDuration(String url) async {
    _queryCount++;
    print('Charging Again after $_queryCount Charge calls');
    var response = await WalletService().getResponseFromEndpoint(url);

    if (response == null) {
      // _showToast(
      //     context, 'Payment processing failed. Please try again later.');
      // _dismissMobileMoneyDialog(false);
    } else {
      _continueProcessingAfterCharge(response, false);
    }
  }

  void _onPollingComplete(String flwRef) {
    Timer(Duration(milliseconds: 5000), () {
      _requeryTx(flwRef);
    });
  }

  void _onPaymentSuccessful() async {
    postPaymentAction();
    showSuccessMessageDialog('Your wallet was loaded successful');
  }

  void postPaymentAction() async {
    try {
      var _user = Provider.of<UserProvider>(context, listen: false).currentUser;
      var _wallet =
          Provider.of<WalletProvider>(context, listen: false).userWallet;

      var newValue = _wallet.legderBalance + int.parse(_amountController.text);

      if (isFirst) {
        await Provider.of<UserProvider>(context, listen: false)
            .updateUserData(_user.id, userPayload);
        await Provider.of<WalletProvider>(context, listen: false)
            .initialUpdate(_wallet.id, walletPayload);
        await Provider.of<TransactionProvider>(context, listen: false)
            .addTransaction(transactionPayload);
        closeDialog();
      } else {
        walletPayload =
            WalletModel(legderBalance: newValue, availableBalance: newValue);
        await Provider.of<WalletProvider>(context, listen: false)
            .updateWallet(_wallet.id, walletPayload);
        await Provider.of<TransactionProvider>(context, listen: false)
            .addTransaction(transactionPayload);

        closeDialog();
      }
    } catch (e) {
      closeDialog();
      throw Exception(e);
    }
  }

  showSuccessMessageDialog(message) {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        showCloseIcon: true,
        customHeader: null,
        dialogType: DialogType.NO_HEADER,
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
        dialogType: DialogType.NO_HEADER,
        dismissOnTouchOutside: false,
        body: Container(
          padding: EdgeInsets.all(20),
          child: Text(
            message,
            style: TextStyle(
                fontFamily: 'San Fransisco',
                fontSize: 14,
                color: Color(0xFF002147)),
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
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    userPayload = UserModel(
        pin: _pinController.text,
        fullName: '',
        phoneNumber: _phoneController.text,
        modifiedOn: DateTime.now(),
        modifiedBy: _user.cashMeName);

    walletPayload = WalletModel(
        accountNumber: _accountController.text,
        accountbank: selectedBank,
        bvn: _bvnController.text,
        availableBalance: int.parse(_amountController.text),
        legderBalance: int.parse(_amountController.text));

    transactionPayload = TransactionModel(
      userId: _user.id,
      type: LOAD,
      status: 'Succesful',
      value: _amountController.text,
      senderName: _user.cashMeName,
      receiverName: _user.cashMeName,
      modifiedOn: DateTime.now(),
      createdOn: DateTime.now(),
    );

    var payLoad = {
      // "PBFPubKey": PUBLIC_KEY.toString().trim(),
      "account_bank": selectedBank.toString().trim(),
      "account_number": _accountController.text.toString().trim(),
      "amount": int.parse(_amountController.text),
      "email": _user.email.toString().trim(),
      "tx_ref": 'MC-' + DateTime.now().toIso8601String(),
      "firstname": 'Forest '.toString().trim(),
      "lastname": ' Green'.toString().trim(),
      // "phone_number": _phoneController.text.toString().trim(),

      "currency": CURRENCY.toString().trim(),
      // "payment_type": 'debit_ng_account'.toString().trim(),
      // "country": COUNTRY.toString().trim(),
      // "lastname": 'Green'.toString().trim(),
    };

    AccountCharge chargePayload = AccountCharge(
      // pbfPubKey: PUBLIC_KEY,
      accountbank: selectedBank,
      accountnumber: _accountController.text,
      currency: CURRENCY,
      // paymentType: PAYMENTTYPE,
      // country: COUNTRY,
      amount: int.parse(_amountController.text),
      email: _user.email,
      // passcode: _dobController.text,
      // bvn: _bvnController.text,
      phonenumber: _phoneController.text,
      fullname: 'Forest',
      // lastName: 'Green',
      // ip: '',
      txRef: "MC-" + DateTime.now().toString(),
      // deviceFingerprint: '',
    );
    try {
      postPaymentAction();
      // var requestBody = encryptJsonPayload(ENCRYPTION_KEY, PUBLIC_KEY, payLoad);
      // print(payLoad);

      // // await Provider.of<WalletProvider>(context, listen: false)
      // //     .loadWallet('$SANDBOX_CHARGE_ENDPOINT?use_polling=1', requestBody);

      // var response = await locator<WalletService>()
      //     .loadWallet('$SANDBOX_CHARGE_ENDPOINT', payLoad);

      // if (response == null) {
      //   closeDialog();

      //   showErrorMessageDialog(
      //       'Sorry, we could not load your wallet. Please try again later.');
      // } else {
      //   print(response);
      //   _continueProcessingAfterCharge(response, true);
      // }
    } catch (e) {
      closeDialog();
      print(e);
      // showErrorMessageDialog(e.message);
    }
  }

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

  // _handlePaymentInitialization() async {
  //   final flutterwave = Flutterwave.forUIPayment(
  //     amount: this.amountController.text.toString().trim(),
  //     currency: this.currencyController.text,
  //     context: this.context,
  //     publicKey: this.publicKeyController.text.trim(),
  //     encryptionKey: this.encryptionKeyController.text.trim(),
  //     email: this.emailController.text.trim(),
  //     fullName: "Test User",
  //     txRef: DateTime.now().toIso8601String(),
  //     narration: "Example Project",
  //     isDebugMode: this.isDebug,
  //     phoneNumber: this.phoneNumberController.text.trim(),
  //     acceptAccountPayment: true,
  //     acceptCardPayment: true,
  //     acceptUSSDPayment: true
  //   );
  //   final response = await flutterwave.initializeForUiPayments();
  //   if (response != null) {
  //     this.showLoading(response.data.status);
  //   } else {
  //     this.showLoading("No Response!");
  //   }
  // }

  int _selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  home() {
    Navigator.of(context).pushNamed(HomeScreen.routeName);
  }

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
          hintText: isFirst ? "Create your pin" : "Enter your pin",
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
                                  'Available Balance',
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
                      top: MediaQuery.of(context).size.height * 0.29,
                      bottom: 0),
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
                        top: MediaQuery.of(context).size.height * 0.33,
                        left: 30.0,
                        right: 30.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          isFirst ? SizedBox(height: 15.0) : Container(),
                          isFirst ? bankField : Container(),
                          isFirst ? SizedBox(height: 15.0) : Container(),
                          isFirst ? accNumberField : Container(),
                          isFirst ? SizedBox(height: 15.0) : Container(),
                          isFirst ? phoneField : Container(),
                          isFirst ? SizedBox(height: 15.0) : Container(),
                          isFirst ? bvnField : Container(),
                          isFirst ? SizedBox(height: 15.0) : Container(),
                          isFirst ? dobField : Container(),
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
        currentIndex: _selectedIndex,
        onTap: (index) {
          home();
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 1.0,
        unselectedFontSize: 1.0,
        iconSize: 30.0,
        backgroundColor: Color(0xFFf4f9f9),
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
