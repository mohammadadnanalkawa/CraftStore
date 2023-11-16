import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:crafts/core/color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';
import 'package:flutter/cupertino.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController code = new TextEditingController();
  final _codeKey = GlobalKey<FormState>();
  bool loadKey = false;
  bool loading = false;
  String total;
  void onTabTapped(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: Home(
                  index: index,
                ))));
  }

  List<WalletWidget> walletWid = <WalletWidget>[];

  Future<void> userWallet() async {
    String soapCategory = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetWallet xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetWallet>
  </soap:Body>
</soap:Envelope>''';
    http.Response responseCategory = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetWallet",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soapCategory),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    if (responseCategory.statusCode == 200) {
      print(responseCategory.body);
      String json = parse(responseCategory.body)
          .getElementsByTagName('GetWalletResult')[0]
          .text;
      final decoded = jsonDecode(json);

      total = decoded['Total'];

      for (int i = 0; i < decoded['AmountList'].length; i++) {
        walletWid.add(WalletWidget(
            title: decoded['AmountList'][i]['Title'],
            price: decoded['AmountList'][i]['Amount'],
            id: decoded['AmountList'][i]['ID'],
            index: i,
            date: decoded['AmountList'][i]['Date']));
      }
    }
  }

  void loadFunctions() async {
    setState(() {
      loading = true;
    });

    await userWallet();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    loadFunctions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: loading
            ? Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(yellow),
                    )
                  ],
                ),
              )
            : Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 10,
                ),
                Header(),
                Divider(),
                Expanded(
                    child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBarOne(
                        implyLeading: true,
                        text: globals.loc == 'en' ? 'Wallet' : 'المحفظة',
                        press: () {
                          Navigator.pop(context);
                        },
                        textColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: Text(total,
                            style: TextStyle(
                                color: Colors.brown[900],
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) => walletWid[index],
                          itemCount: walletWid.length,
                        ),
                      )
                    ],
                  ),
                ))
              ]),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          selectedItemColor: Colors.grey[400],
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.grey[100],
          showUnselectedLabels: true,
          iconSize: 30,
          onTap: onTabTapped, // new
          items: [
            new BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/craft.png',
                  scale: 2,
                ),
                label: globals.loc == 'en' ? "HOME" : 'الرئيسية'),
            new BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/cat.png',
                  scale: 2,
                ),
                label: globals.loc == 'en' ? "CATEGORIES" : 'التصنيفات'),
            new BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/byicon.png',
                  scale: 2,
                ),
                label: globals.loc == 'en' ? "BY" : 'بواسطة'),
            new BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/cart.png',
                  scale: 2,
                ),
                label: globals.loc == 'en' ? "BAG" : 'الحقيبة'),
          ],
        ),
      ),
    );
  }
}

class WalletWidget extends StatefulWidget {
  final String title;
  final String price;
  final String id;
  final int index;
  final String date;

  WalletWidget(
      {@required this.title,
      @required this.price,
      @required this.id,
      @required this.index,
      @required this.date});
  @override
  _WalletWidgetState createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection:
            globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color:
                  widget.index % 2 == 0 ? Colors.grey[200] : Colors.transparent,
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.title,
                    style: TextStyle(color: Colors.brown[900], fontSize: 19)),
              ),
              Expanded(
                child: Align(
                  alignment: globals.loc == 'en'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${widget.price} رس',
                          style: TextStyle(
                              color: Colors.brown[900], fontSize: 18)),
                      SizedBox(height: 2.5),
                      Text(widget.date,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: Colors.yellow[800], fontSize: 18))
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
