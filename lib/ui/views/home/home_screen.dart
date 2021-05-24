import 'package:cash_me/core/constants.dart';
import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/transaction_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/ui/shared/utils/date_format.dart';
import 'package:cash_me/ui/views/cash_out/cash_out_screen.dart';
import 'package:cash_me/ui/views/load_wallet/load_wallet.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:cash_me/ui/views/scan_screen/scan_screen.dart';
import 'package:cash_me/ui/views/transfer_screen/transfer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BuildContext bcontext;

  Future<void> _getUserInfo() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<WalletProvider>(context, listen: false)
          .setUserWallet(_user.id);
      await Provider.of<TransactionProvider>(context, listen: false)
          .setUserTransactions(_user.id);
    } catch (e) {
      print(e);
    }
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await getBanks();
        setState(() => _isInit = false);
      });
    }
    super.didChangeDependencies();
  }

  Future<void> getBanks() async {
    await Provider.of<WalletProvider>(context, listen: false).setBanks();
  }

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void logout() async {
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _authProvider.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName, (Route<dynamic> route) => false);
  }

  var transactionData;

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<UserProvider>(context).currentUser;
    final _wallet = Provider.of<WalletProvider>(context).userWallet;
    var _transactions =
        Provider.of<TransactionProvider>(context).userTransactions;

    if (_transactions == null) {
      _transactions = [];
    }
    setState(() => this.bcontext = context);

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
                onTap: () {
                  Navigator.of(context).pushNamed(CashoutScreen.routeName);
                },
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
        height: double.infinity,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.23,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(30)),
                        color: Color(0xff16c79a)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          // Padding(
                          //   padding: EdgeInsets.only(top: 0.0, left: 20.0),
                          //   child: Column(
                          //     children: [
                          //       Container(
                          //         height: 50.0,
                          //         width: 50.0,
                          //         decoration: BoxDecoration(
                          //             image: DecorationImage(
                          //               image: AssetImage(
                          //                   'assets/images/profile.jpg'),
                          //               fit: BoxFit.fill,
                          //             ),
                          //             shape: BoxShape.rectangle,
                          //             borderRadius: BorderRadius.all(
                          //                 Radius.circular(20))),
                          //       )
                          //     ],
                          //   ),
                          // ),

                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.05,
                                left: 15.0,
                                right: 10.0),
                            child: Column(
                              children: [
                                Container(
                                  width: 220.0,
                                  child:
                                      Text('${_user.cashMeName.toUpperCase()}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'San Francisco',
                                          )),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ))),
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.15,
                      left: MediaQuery.of(context).size.width * 0.015,
                    ),
                    child: Material(
                      elevation: 15.0,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Color(0xFFf4f9f9),
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.20,
                          width: MediaQuery.of(context).size.width * 0.89,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.07,
                                      // bottom: 5.0,
                                      left: 30.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Available Balance:",
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontFamily: 'San Francisco',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      // GestureDetector(
                                      //   onTap: toggleLedger(),
                                      //   child: Padding(
                                      //     padding: EdgeInsets.only(left: 150),
                                      //     child: Text(
                                      //       '...',
                                      //       style: TextStyle(
                                      //         fontSize: 20,
                                      //         color: Colors.black,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontFamily: 'San Francisco',
                                      //       ),
                                      //     ),
                                      //   ),
                                      // )
                                    ],
                                  )),
                              Container(
                                padding: EdgeInsets.only(
                                    top: 5.0,
                                    // bottom: 20.0,
                                    left: 30.0,
                                    right: 40.0),
                                child: Text(
                                  '₦${_wallet.availableBalance > 0 ? NumberFormat('#,###,##0').format(_wallet.availableBalance) : _wallet.availableBalance}',
                                  style: TextStyle(
                                    color: Color(0xFF002147),
                                    fontFamily: 'San Francisco',
                                    fontSize: 35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.09,
                    top: MediaQuery.of(context).size.height * 0.045,
                    bottom: 30.0),
                child: SizedBox(
                  child: Text(
                    'Transactions',
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
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.45,
                      left: MediaQuery.of(context).size.width * 0.036),
                  child: Row(
                    children: [
                      _transactions.length == 0
                          ? Container(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.15,
                                  top: 40),
                              child: Text(
                                'There are no transactions yet.',
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 16,
                                    fontFamily: 'San Francisco',
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          : Expanded(
                              child: Container(
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(8),
                                  shrinkWrap: true,
                                  itemCount: _transactions.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var _timeago = DateFormatter(
                                            _transactions[index].createdOn)
                                        .format();
                                    return Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            title: Text(
                                              _transactions[index]
                                                  .transactionMode,
                                              style: TextStyle(
                                                color: Color(0xFF002147),
                                                fontFamily: 'San Francisco',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              _transactions[index].type,
                                              style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontFamily: 'San Francisco',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            trailing: Column(
                                              children: [
                                                _transactions[index].type ==
                                                        DEBIT
                                                    ? Text(
                                                        '-${_transactions[index].value}',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontFamily:
                                                              'San Francisco',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      )
                                                    : Text(
                                                        '+${_transactions[index].value}',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff16c79a),
                                                          fontFamily:
                                                              'San Francisco',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                SizedBox(height: 10),
                                                Text(
                                                  '${DateFormat.yMMMd().format(_transactions[index].createdOn)} at ${DateFormat.jm().format(_transactions[index].createdOn)}',
                                                  style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontFamily: 'San Francisco',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(),
                                ),
                              ),
                            ),
                    ],
                  ),
                )),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child:
            // )
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .pushReplacementNamed(LoadWalletScreen.routeName);
        },
        tooltip: 'Load Wallet',
        backgroundColor: Color(0xFF002147),
        child: new Icon(
          Icons.add,
        ),
      ),
    );
  }
}
