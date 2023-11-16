import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'home.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/bg.png'), fit: BoxFit.fill)),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/Asset 7.png',
                  fit: BoxFit.fill,
              
                ),
              ),
              SizedBox(height: 60),
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    globals.loc == 'en'
                        ? 'Thank You..'
                        : 'شكراً لك..',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold , color: Colors.grey[600],  fontFamily: 'MainFont'),
                  )),
                    Align(
                  alignment: Alignment.center,
                  child: Text(
                    globals.loc == 'en'
                        ? "You're A Crafter Now!"
                        : 'أنت الاَن كرافتر!',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold , color: Colors.grey[600],  fontFamily: 'MainFont'),
                  )),
         Spacer(),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/Asset 8.png',
                  fit: BoxFit.fill,
                 height: 150,
                 width: 170,
                ),
              ),
         Spacer(),
             
              Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                        ),
                        color: Colors.grey[600],
                        padding: EdgeInsets.symmetric(
                            vertical: 17.5, horizontal: 15),
                        child: Text(
                          globals.loc == 'en'
                              ? 'Home'
                              : 'الصفحة الرئيسية',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24,  fontFamily: 'MainFont'),
                        ),
                        onPressed: () async {
                          String soap =
                              '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <FirstTime xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </FirstTime>
  </soap:Body>
</soap:Envelope>''';
                          http.Response response = await http
                              .post(
                                  'https://craftapp.net/services/CraftWebService.asmx',
                                  headers: {
                                    "SOAPAction": "http://Craft.WS/FirstTime",
                                    "Content-Type": "text/xml;charset=UTF-8",
                                  },
                                  body: utf8.encode(soap),
                                  encoding: Encoding.getByName("UTF-8"))
                              .then((onValue) {
                            return onValue;
                          });

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WillPopScope(
                                      onWillPop: () async => false,
                                      child: Home(
                                        index: 0,
                                      ))));
                        }),
                  ),
                ],
              ),
          ],  
          ),
        ),
      ),
    );
  }
}
