import 'dart:async';
import 'dart:convert';
import 'package:cash_me/core/constants.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cash_me/core/models/account_charge.model.dart';
import 'package:cash_me/core/models/bank.model.dart';
import 'package:cash_me/core/models/charge_response.model.dart';
import 'package:cash_me/core/models/requery_response.dart';
import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/core/services/wallet.service.dart';
import 'package:cash_me/ui/views/home/home_screen.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

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
  var banks = new List<BankModel>();
  var selectedBank;
  var _requeryUrl, _queryCount = 0, _reQueryTxCount = 0, _waitDuration = 0;

  @override
  void initState() {
    super.initState();
    getBanks();
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
      _isInit = false;
    }
    super.didChangeDependencies();
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
        print('Payment processing failed. Please try again later.');
        showErrorMessageDialog(
            'Payment processing failed. Please try again later.');
        closeDialog();
        // _showToast(
        //     context, 'Payment processing failed. Please try again later.');
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

  getBanks() {
    WalletService.getBanks().then((res) {
      setState(() {
        Iterable list = json.decode(res.body);
        banks = list.map((model) => BankModel.fromJson(model)).toList();
        banks.forEach((element) => {print(element.bankname)});
      });
    });
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
        _requeryUrl = chargeResponse.data.pingUrl;
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
    showSuccessMessageDialog('Payment successful');
    print('payment successful');
    // _showPaymentSuccessfulDialog();
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
    openLoadingDialog();
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;

    AccountCharge chargePayload = AccountCharge(
        accountbank: selectedBank,
        pbfPubKey: PUBLIC_KEY,
        currency: CURRENCY,
        paymentType: PAYMENTTYPE,
        country: COUNTRY,
        email: _user.email,
        firstName: 'Cash',
        lastName: 'Me',
        txRef: "CASHME-" + DateTime.now().toString(),
        passcode: _dobController.text,
        phonenumber: _phoneController.text,
        accountnumber: _accountController.text,
        amount: _amountController.text,
        bvn: _bvnController.text);
    try {
      var requestBody =
          chargePayload.encryptJsonPayload(ENCRYPTION_KEY, PUBLIC_KEY);

      // await Provider.of<WalletProvider>(context, listen: false)
      //     .loadWallet('$SANDBOX_CHARGE_ENDPOINT?use_polling=1', requestBody);

      var response = await WalletService()
          .loadWallet('$SANDBOX_CHARGE_ENDPOINT?use_polling=1', requestBody);

      print(response);

      if (response == null) {
        closeDialog();

        showErrorMessageDialog(
            'Sorry we could not load your wallet. Please try again later.');
        // _showToast(context, 'Payment processing failed. Please try again later.');
        // _dismissMobileMoneyDialog(false);
      } else {
        _continueProcessingAfterCharge(response, true);
      }
    } catch (e) {
      closeDialog();
      showErrorMessageDialog(e);
    }
  }

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
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
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
          hintText: "Create your pin",
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
        keyboardType: TextInputType.datetime,
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
      color: Color(0xff16c79a),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          initiatePayment();
        },
        child: Text("Load Wallet",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
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
                alignment: Alignment.topCenter,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      color: Color(0xff16c79a)),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 70.0, left: 15.0, right: 10.0),
                          child: Column(
                            children: [
                              Container(
                                width: 220.0,
                                child: Text('${_user.cashMeName.toUpperCase()}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'San Francisco',
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.09,
                      top: MediaQuery.of(context).size.height * 0.3,
                      bottom: 20),
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
                          SizedBox(height: 15.0),
                          bankField,
                          SizedBox(height: 15.0),
                          accNumberField,
                          SizedBox(height: 15.0),
                          phoneField,
                          SizedBox(height: 15.0),
                          bvnField,
                          SizedBox(height: 15.0),
                          dobField,
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
              color: Color(0xff16c79a),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xff16c79a),
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
