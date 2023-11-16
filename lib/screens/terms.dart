import 'package:crafts/core/color.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:flutter/cupertino.dart';

class Terms extends StatefulWidget {
  final String sourcepage;
  Terms({@required this.sourcepage});
  @override
  _TermsState createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  bool loading = false;
  String data = '';
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
    await getTerms();
    setState(() {
      loading = false;
    });
  }

  Future<void> getTerms() async {
    String sendval = "";
    if (globals.user != null)
      sendval = globals.user.id;
    else
      sendval = globals.loc;

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetTerms xmlns="http://Craft.WS/">
      <CustomerID>$sendval</CustomerID>
    </GetTerms>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetTerms",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetTermsResult')[0].text;
    final decoded = json;
    data = decoded;
  }

  @override
  Widget build(BuildContext context) {
    return widget.sourcepage == '1'
        ? Directionality(
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
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(yellow),
                          )
                        ],
                      ),
                    )
                  :
                   Column(children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top + 10,
                      ),
                      Header(),
                      Divider(),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Form(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 15),
                                AppBarOne(
                                  implyLeading: true,
                                  text: globals.loc == 'en'
                                      ? 'Terms & Conditions'
                                      : 'البنود والشروط',
                                  press: () {
                                    Navigator.pop(context);
                                  },
                                  textColor: Colors.black,
                                  backgroundColor: Colors.white,
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                              .padding
                                              .top,
                                          bottom: 10,
                                          right: 10,
                                          left: 10),
                                      child: Html(data: """$data"""),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
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
          )
        :  Directionality(
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
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              AppBarOne(
                                implyLeading: true,
                                text: globals.loc == 'en'
                                    ? 'Terms & Conditions'
                                    : 'البنود والشروط',
                                press: () {
                                  Navigator.pop(context);
                                },
                                textColor: Colors.black,
                                backgroundColor: Colors.white,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: MediaQuery.of(context).padding.top,
                                        bottom: 10,
                                        right: 10,
                                        left: 10),
                                    child: Html(data: """$data"""),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
          ));
  }
}
