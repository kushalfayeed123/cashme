import 'package:cash_me/core/providers/authentication_provider.dart';
import 'package:cash_me/core/providers/user_provider.dart';
import 'package:cash_me/core/providers/wallet_provider.dart';
import 'package:cash_me/ui/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BuildContext bcontext;

  void _getUserInfo() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await Provider.of<WalletProvider>(context, listen: false)
          .setUserWallet(_user.id);
    } catch (e) {
      print(e);
    }
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getUserInfo();

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final List entries = [
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
    {
      'firstname': 'Segun',
      'lastName': 'Ajanaku',
      'transactionType': 'Debit',
      'amount': '200'
    },
  ];

  logout() async {
    final _authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _authProvider.signOut();
    Navigator.of(context).pushNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<UserProvider>(context).currentUser;
    final _wallet = Provider.of<WalletProvider>(context).userWallet;
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
        height: double.infinity,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                    width: double.infinity,
                    height: 220,
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
                            padding: const EdgeInsets.only(
                                top: 70.0, left: 15.0, right: 10.0),
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
                        left: MediaQuery.of(context).size.width * 0.015),
                    child: Material(
                      elevation: 15.0,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Color(0xFFf4f9f9),
                      child: Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width * 0.89,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(
                                      top: 20.0, bottom: 5.0, left: 30.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Total Balance",
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
                                    bottom: 20.0,
                                    left: 30.0,
                                    right: 40.0),
                                child: Text(
                                  "₦${_wallet?.legderBalance ?? ""}",
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
                      top: MediaQuery.of(context).size.height * 0.009,
                      bottom: 20),
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
                )),
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.43,
                      left: MediaQuery.of(context).size.width * 0.036),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(
                                'Segun Ajanaku',
                                style: TextStyle(
                                  color: Color(0xFF002147),
                                  fontFamily: 'San Francisco',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Debit',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontFamily: 'San Francisco',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Text(
                                '-200000',
                                style: TextStyle(
                                  color: Color(0xFFf58634),
                                  fontFamily: 'San Francisco',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
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
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 1.0,
        unselectedFontSize: 1.0,
        iconSize: 30.0,
        backgroundColor: Color(0xFFf4f9f9),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.send_to_mobile,
              color: Color(0xff16c79a),
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
                Icons.qr_code_scanner_rounded,
                color: Color(0xff16c79a),
              ),
              label: 'Scan QR'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: new FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        backgroundColor: Color(0xff16c79a),
        child: new Icon(
          Icons.add,
        ),
      ),
    );
  }
}
