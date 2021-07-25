import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cash_me/core/constants.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cash_me/core/models/account_charge.model.dart';
import 'package:cash_me/core/models/bank.model.dart';
import 'package:cash_me/core/models/bank_transfer_response.model.dart';
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
import 'package:cash_me/ui/shared/widgets/app_drawer.dart';
import 'package:cash_me/ui/views/cash_out/cash_out_screen.dart';
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
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  UserModel userPayload;
  WalletModel walletPayload;
  TransactionModel transactionPayload;
  BankModel banks;
  var selectedBank;
  bool isFirst;
  final _formKey = GlobalKey<FormState>();
  String selectedDate;

  @override
  void initState() {
    super.initState();
    // getBanks();
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
      accountbank: '',
      accountnumber: '',
      amount: '',
      bvn: '',
      country: '',
      currency: '',
      deviceFingerprint: '',
      email: '',
      fullname: '',
      ip: '',
      lastName: '',
      passcode: '',
      paymentType: '',
      phonenumber: '',
      redirectUrl: '',
      txRef: '',
    );

    accountName = await locator<WalletService>().verifyAccount(chargePayload);
    // firstName = accountName.split()[0];
    // lastName = accountName.split()[1];
  }

  void logout() async {
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _authProvider.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName, (Route<dynamic> route) => false);
  }

  Future<void> getBanks() async {
    await Provider.of<WalletProvider>(context, listen: false).setBanks();
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
    openLoadingDialog();

    try {
      var _user = Provider.of<UserProvider>(context, listen: false).currentUser;
      var _wallet =
          Provider.of<WalletProvider>(context, listen: false).userWallet;

      userPayload = UserModel(
          pin: _pinController.text,
          fullName: '',
          phoneNumber: _phoneController.text,
          modifiedOn: DateTime.now(),
          modifiedBy: _user.cashMeName,
          cashMeName: '',
          createdBy: '',
          createdOn: DateTime.now(),
          email: '',
          id: '',
          keyReference: '');

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
        id: '',
        transactionRef: '',
      );

      var newValue = _wallet.availableBalance + amount;

      walletPayload = WalletModel(
          legderBalance: 0,
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

      showSuccessMessageDialog(
          'You have successfully loaded your wallet with the sum of ₦${NumberFormat('#,##0.00').format(int.parse(_amountController.text))}');
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
        body: Container(
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
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

  final spinner = SpinKitRing(
    // type: SpinKitWaveType.end,
    color: Color(0xff16c79a),
    size: 50.0,
  );

  dispose() {
    super.dispose();
  }

  void showOtpForm(flwRef) {
    closeDialog();
    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);
    final otpField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextFormField(
        // validator: (value) => validateForm(value, 'pin'),
        keyboardType: TextInputType.number,
        controller: _otpController,
        obscureText: true,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.lock),
          hintText: "Enter OTP here",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );

    AwesomeDialog(
        context: context,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
        animType: AnimType.BOTTOMSLIDE,
        showCloseIcon: false,
        customHeader: null,
        dialogType: DialogType.NO_HEADER,
        dismissOnTouchOutside: false,
        body: Container(
          height: MediaQuery.of(context).size.height * 0.30,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Column(
            children: [
              Text(
                'Please enter the otp that was sent to you',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20.0,
                    color: Color(0xFF002147),
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 25.0,
              ),
              Form(
                child: otpField,
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
                        validateCharge(flwRef);
                      },
                      child: Text("SUBMIT",
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

  void showBankDetails(BankTransferResponse payload) {
    closeDialog();
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
          height: MediaQuery.of(context).size.height * 0.41,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Column(
            children: [
              Text(
                payload.meta.authorization.transferNote,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20.0,
                    color: Color(0xFF002147),
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 25.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bank Name: ${payload.meta.authorization.transferBank}',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.0,
                        color: Color(0xFF002147),
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    'Account Number: ${payload.meta.authorization.transferAccount}',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.0,
                        color: Color(0xFF002147),
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    'Amount: ${_amountController.text}',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.0,
                        color: Color(0xFF002147),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 15.0,
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
                        Navigator.of(context).pop();
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

  void initiatePayment() async {
    openLoadingDialog();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      closeDialog();
      showSuccessMessageDialog(
          'Sorry, you can not load your wallet at the moment because you may not be connected to the internet. Please connect and try again.');
      return;
    }
    final _user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final transactionRef = 'MC-' + DateTime.now().toIso8601String();

    final fullName = '${_firstNameController.text.trim()}'
        ' ${_lastNameController.text.trim()}';
    var payLoad = {
      "tx_ref": transactionRef,
      "amount": _amountController.text.trim(),
      // "account_bank": selectedBank.toString().trim(),
      // "account_number": _accountController.text.trim(),
      "email": _user.email.toString().trim(),
      // "phone_number": '07015902708',

      "currency": CURRENCY.toString().trim(),
      "duration": 2,
      "frequency": 5,
      "narration": "CashMe",
      "is_permanent": true,
      // "bvn": "2226187119"
      // "fullname": fullName,
      // "passcode": selectedDate,
      // "firstname": _firstNameController.text,
      // "lastname": _lastNameController.text,
    };

    try {
      await Provider.of<WalletProvider>(context, listen: false)
          .loadWallet(payLoad);

      final response = Provider.of<WalletProvider>(context, listen: false).res;

      if (response != null) {
        if (response.status == 'success') {
          // if (response.data.meta.authorization.mode == 'otp') {
          //   showOtpForm(response.data.flwRef);
          // } else {
          //   validateCharge(response.data.flwRef);
          // }

          if (response.meta.authorization.mode == 'banktransfer') {
            transactionPayload = TransactionModel(
                userId: _user.id,
                type: CREDIT,
                status: 'Pending',
                value: _amountController.text,
                senderName: _user.cashMeName,
                transactionMode: WALLET_LOAD,
                modifiedOn: DateTime.now(),
                createdOn: DateTime.now(),
                id: '',
                transactionRef: transactionRef);

            final jobPayload = {"id": _user.id};

            await Provider.of<TransactionProvider>(context, listen: false)
                .addTransaction(transactionPayload);
            // await Provider.of<WalletProvider>(context, listen: false)
            //     .startJob(jobPayload);
            showBankDetails(response);
          }
        } else {
          closeDialog();
          showErrorMessageDialog(response.message);
        }
      } else {
        closeDialog();
        showErrorMessageDialog(
            'An error occured, please try again in a few minutes or contact support for further help.');
      }
    } catch (e) {
      closeDialog();
      print(e);
      // showSuccessMessageDialog(e);
    }
  }

  void verifyCharge(int id) async {
    try {
      await Provider.of<WalletProvider>(context, listen: false)
          .verifyCharge(id);

      final res = Provider.of<WalletProvider>(context, listen: false).verifyRes;

      if (res.data.status == 'successful' &&
          res.data.amount >= int.parse(_amountController.text)) {
        print('success');
        // postPaymentAction(res.data.amount);
      } else {
        closeDialog();
        showErrorMessageDialog(res.message);
      }
    } catch (e) {
      closeDialog();
      print(e);
    }
  }

  void validateCharge(flwRef) async {
    openLoadingDialog();
    final payload = {
      "otp": _otpController.text,
      "flw_ref": flwRef.trim(),
      "type": 'account'
    };
    try {
      await Provider.of<WalletProvider>(context, listen: false)
          .validateCharge(payload);
      var response =
          Provider.of<WalletProvider>(context, listen: false).validateRes;
      if (response != null) {
        if (response.data.status == 'successful' &&
            response.data.amount >= int.parse(_amountController.text)) {
          // verifyCharge(response.data.id);
          postPaymentAction(response.data.amount);
        }
      } else {
        showErrorMessageDialog('An error occured please try again');
      }
    } catch (e) {
      closeDialog();
      showErrorMessageDialog(e.message);
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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

  String formatDate(DateTime date) {
    var year = date.year;
    var month = date.month;
    var day = date.day;
    return '$day$month$year';
  }

  @override
  Widget build(BuildContext context) {
    final _wallet = Provider.of<WalletProvider>(context).userWallet;

    setState(() => this.bcontext = context);

    TextStyle style = TextStyle(fontFamily: 'San Francisco', fontSize: 16.0);

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
    final firstNameField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.name,
        controller: _firstNameController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.person),
          hintText: "Your first name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );
    final lastNameField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextField(
        keyboardType: TextInputType.name,
        controller: _lastNameController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.person),
          hintText: "Your last name",
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

    final dobField = new Theme(
      data: new ThemeData(primaryColor: Color(0xFF002147)),
      child: TextFormField(
        readOnly: true,
        onTap: () {
          DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: DateTime(1920, 1, 1),
              maxTime: DateTime.now(), onConfirm: (date) {
            _dobController.text = DateFormat("yyyy-MM-dd").format(date);
            setState(() {
              selectedDate = formatDate(date);
            });
          }, currentTime: DateTime.now(), locale: LocaleType.en);
        },
        keyboardType: TextInputType.text,
        controller: _dobController,
        obscureText: false,
        style: style,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          suffixIcon: Icon(Icons.person),
          hintText: "Date of Birth",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(color: Color(0xff16c79a))),
        ),
      ),
    );

    final bvnField = new Theme(
      data: new ThemeData(primaryColor: Color(0xff16c79a)),
      child: TextFormField(
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
      child: TextFormField(
        validator: (value) => validateForm(value, 'amount'),
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
          if (_formKey.currentState.validate()) {
            // initiatePayment();
            postPaymentAction(int.parse(_amountController.text));
          }
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
                            // SizedBox(height: 15.0),
                            // bankField,
                            // SizedBox(height: 15.0),
                            // accNumberField,
                            // SizedBox(height: 15.0),
                            // firstNameField,
                            // SizedBox(height: 15.0),
                            // lastNameField,
                            // SizedBox(height: 15.0),
                            // selectedBank == '057' ? dobField : Container(),
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
