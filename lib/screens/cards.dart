import 'package:crafts/core/color.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';

import 'package:flutter/cupertino.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';

class Cards extends StatefulWidget {
  @override
  _CardsState createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  bool loading = false;
  List<CardWidget> cards = <CardWidget>[];
  @override
  void initState() {
    super.initState();
    loadData();
  }

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

  void loadData() async {
    setState(() {
      loading = true;
    });
    await getCards();
    setState(() {
      loading = false;
    });
  }

  Future<void> getCards() async {
    cards = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetMyCards xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetMyCards>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetMyCards",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetMyCardsResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      cards.add(CardWidget(
        id: decoded[i]['ID'],
        cardNo: decoded[i]['CardNumber'],
        holder: decoded[i]['HolderName'],
        cvv: decoded[i]['CVV'],
        expDate: decoded[i]['ExpiredDate'],
      ));
    }
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
                        text: globals.loc == 'en' ? 'My Cards' : 'بطاقاتي',
                        press: () {
                          Navigator.pop(context);
                        },
                        textColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => cards[index],
                          itemCount: cards.length,
                          separatorBuilder: (context, index) => Divider(
                            thickness: 1.0,
                          ),
                        ),
                      ),
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

class CardWidget extends StatefulWidget {
  final String id;
  final String cardNo;
  final String holder;
  final String cvv;
  final String expDate;
  CardWidget(
      {@required this.cardNo,
      @required this.id,
      @required this.holder,
      @required this.cvv,
      @required this.expDate});
  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( 'xxxx xxxx xxxx '+ widget.cardNo,
              style: TextStyle(color: Colors.grey, fontSize: 22)),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(globals.loc == 'en' ? 'Card Holder Name' : 'اسم حامل البطاقة',
                        style: TextStyle(fontSize: 19)),
                    SizedBox(
                      height: 5,
                    ),
                   /*  Text(globals.loc == 'en' ? 'CVV' : 'CVV',
                        style: TextStyle(fontSize: 19)),
                    SizedBox(
                      height: 5,
                    ), */
                    Text(
                        globals.loc == 'en'
                            ? 'Expiration Date'
                            : 'تاريخ الانتهاء',
                        style: TextStyle(fontSize: 19)),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.holder, style: TextStyle(fontSize: 19)),
                   /*  SizedBox(
                      height: 5,
                    ),
                    Text(widget.cvv, style: TextStyle(fontSize: 19)), */
                    SizedBox(
                      height: 5,
                    ),
                    Text(widget.expDate, style: TextStyle(fontSize: 19)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
