import 'package:crafts/core/color.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/return_details.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:flutter_html/flutter_html.dart';


class Rules extends StatefulWidget {
  @override
  _RulesState createState() => _RulesState();
}

class _RulesState extends State<Rules> {
  String data = '';

  bool loading = false;
  String enable;
  List<String> policyList = <String>[];
  List<RuleWidget> rules = <RuleWidget>[];
  
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
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetRules xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetRules>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetRules",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    if (response.statusCode == 200) {
      print(response.body);
       String json =
        parse(response.body).getElementsByTagName('GetRulesResult')[0].text;
   
       final decoded = json;
       data = decoded;
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    loadData();
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
                                 text: globals.loc == 'en'   ? 'Exchange and Return Policy'
                                        : 'سياسة الاستبدال و الاسترجاع',
                     
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
    );
  }
}

class RuleWidget extends StatefulWidget {
  final String id;
  final String request;
  final String date;
  final String status;
  RuleWidget(
      {@required this.id,
      @required this.request,
      @required this.date,
      @required this.status});

  @override
  _RuleWidgetState createState() => _RuleWidgetState();
}

class _RuleWidgetState extends State<RuleWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReturnDetails(id: widget.id)));
      },
      child: Container(
        decoration: BoxDecoration(),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      globals.loc == 'en'
                          ? 'Request# ${widget.request}'
                          : 'طلب# ${widget.request}',
                      style: TextStyle(fontWeight: FontWeight.bold,  fontSize: 18)),
                  SizedBox(height: 10),
                  Text(
                      globals.loc == 'en'
                          ? 'Date: ${widget.date}'
                          : 'التاريخ: ${widget.date}',
                      style: TextStyle(fontSize: 16, color: Colors.grey )),
                 /*  SizedBox(height: 20),
                  Text(
                      globals.loc == 'en'
                          ? 'Items: ${widget.items}'
                          : 'العناصر: ${widget.items}',
                      style: TextStyle(fontSize: 13)) */
                ],
              ),
            ),
            SizedBox(width: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7.5),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.yellow[700])),
              child: Text(
                widget.status,
                style: TextStyle(color: Colors.yellow[700] ,  fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
