import 'dart:io';

import 'package:crafts/core/color.dart';
import 'package:crafts/helpers/wrapper.dart';
import 'package:crafts/screens/login.dart';
import 'package:crafts/screens/register.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:crafts/screens/terms.dart';
import 'package:crafts/screens/policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:crafts/helpers/user.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool loading = false;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  addData(String id, String name, String phone, String email, String password,
      String image, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ID', id);
    prefs.setString('Name', name);
    prefs.setString('Phone', phone);
    prefs.setString('Email', email);
    prefs.setString('Password', password);
    prefs.setString('Image', image);
    prefs.setString('Image', image);
    prefs.setString('Type', type);
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/landing.png'), fit: BoxFit.fill)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(),
                        color: Colors.grey[800],
                        padding: EdgeInsets.symmetric(
                            vertical: 17.5, horizontal: 15),
                        child: Text(
                          globals.loc == 'en' ? 'Sign In' : 'تسجيل دخول',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'MainFont'),
                        ),
                        onPressed: () async {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        }),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(),
                        color: Colors.grey[400],
                        padding: EdgeInsets.symmetric(
                            vertical: 17.5, horizontal: 15),
                        child: Text(
                          globals.loc == 'en' ? 'Sign Up' : 'تسجيل جديد',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'MainFont'),
                        ),
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()));
                        }),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              loading
                  ? Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(yellow),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: RaisedButton(
                              elevation: 0,
                              shape: RoundedRectangleBorder(),
                              color: Colors.grey[800],
                              padding: EdgeInsets.symmetric(
                                  vertical: 17.5, horizontal: 15),
                              child: Text(
                                globals.loc == 'en'
                                    ? 'Login as gust'
                                    : 'الدخول كزائر',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'MainFont'),
                              ),
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                String deviceId = await _getId();
                                  String token;
                                    await _firebaseMessaging
                                        .getToken()
                                        .then((value) {
                                      token = value;
                                    });
                                String soap =
                                    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Signgust2 xmlns="http://Craft.WS/">
      <UUID>$deviceId</UUID>
      <firebase_tokenkey>$token</firebase_tokenkey>
       <Language>${globals.loc == 'en' ? 0 : 1}</Language>
    </Signgust2>
  </soap:Body>
</soap:Envelope>''';
                                http.Response response = await http
                                    .post(
                                        'https://craftapp.net/services/CraftWebService.asmx',
                                        headers: {
                                          "SOAPAction":
                                              "http://Craft.WS/Signgust2",
                                          "Content-Type":
                                              "text/xml;charset=UTF-8",
                                        },
                                        body: utf8.encode(soap),
                                        encoding: Encoding.getByName("UTF-8"))
                                    .then((onValue) {
                                  return onValue;
                                });

                                if (response.statusCode == 200) {
                                  print(response.body);
                                  String json = parse(response.body)
                                      .getElementsByTagName('Signgust2Result')[0]
                                      .text;
                                  final decoded = jsonDecode(json);
                                  print(decoded);
                                  if (decoded['ID'] == '-1') {
                                    setState(() {});
                                  } else {
                                  
                                   
                                      await addData(
                                        decoded['ID'].toString(),
                                        decoded['Name'],
                                        decoded['Phone'],
                                        decoded['Email'],
                                        decoded['Password'],
                                        decoded['Image'],
                                        '1');
                                    setState(() {
                                      loading = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Wrapper(),
                                        ));
                                  }
                                }
                              }),
                        ),
                      ],
                    ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Terms(
                                      sourcepage: '0',
                                    )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Colors.brown[900], // Text colour here
                          width: 1.0, // Underline width
                        ))),
                        child: Text(
                            globals.loc == 'en'
                                ? 'Terms & Conditions'
                                : 'الشروط والأحكام',
                            style: TextStyle(
                                color: Colors.brown[900],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'MainFont')),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Policy(
                                      sourcepage: '0',
                                    )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Colors.brown[900], // Text colour here
                          width: 1.0, // Underline width
                        ))),
                        child: Text(
                            globals.loc == 'en'
                                ? 'User Policy'
                                : 'سياسة المستخدم',
                            style: TextStyle(
                                color: Colors.brown[900],
                                fontSize: 16,
                                fontFamily: 'MainFont',
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
