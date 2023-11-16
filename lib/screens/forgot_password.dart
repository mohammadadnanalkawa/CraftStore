import 'package:crafts/core/color.dart';
import 'package:crafts/screens/forgetpasscode.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/widgets/app_bar_two.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController credentials = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String sms = "";
  addData(String id, String name, String phone, String email, String password,
      String image, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ID', id);
    prefs.setString('Name', name);
    prefs.setString('Phone', phone);
    prefs.setString('Email', email);
    prefs.setString('Password', password);
    prefs.setString('Image', image);
    prefs.setString('Type', '0');
  }

  bool load = false;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppBarTwo(
                    text: globals.loc == 'en'
                        ? 'Forgot Password?'
                        : 'هل نسيت كلمة السر؟',
                    press: () {
                      Navigator.pop(context);
                    },
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),
                        Text(
                            globals.loc == 'en'
                                ? 'Please enter your email address'
                                : 'الرجاء إدخال عنوان بريدك الإلكتروني   ',
                            style: TextStyle(fontSize: 25)),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                            globals.loc == 'en'
                                ? 'We will send your password by email immediately'
                                : 'سنرسل كلمة المرور الخاصة بك عن طريق البريد الإلكتروني على الفور',
                            style: TextStyle(fontSize: 23)),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                            controller: credentials,
                            textAlign: TextAlign.left,

                            validator: (val) {
                              if (val.length == 0)
                                return globals.loc == 'en'
                                    ? 'Required'
                                    : 'مطلوب';
                              else
                                return null;
                            },
                            cursorColor: Colors.black,
                            style: TextStyle(fontSize: 24),
                            decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelStyle: TextStyle(
                                    color: Colors.black, fontSize: 26),
                                labelText: globals.loc == 'en'
                                    ? 'Email ID'
                                    : 'البريد الالكتروني',
                                isDense: true)),
                        SizedBox(height: 40),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            sms,
                            style: TextStyle(color: Colors.red, fontSize: 22),
                          ),
                        ),
                        load
                            ? Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      new AlwaysStoppedAnimation<Color>(yellow),
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
                                            vertical: 20, horizontal: 15),
                                        child: Text(
                                          globals.loc == 'en'
                                              ? 'Send'
                                              : 'ارسال',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 22),
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            setState(() {
                                              load = true;
                                            });
                                            String soap =
                                                '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ForgetPassword2 xmlns="http://Craft.WS/">
      <UserName>${credentials.text}</UserName>
      <Lang>${globals.loc}</Lang>
    </ForgetPassword2>
  </soap:Body>
</soap:Envelope>''';
                                            http.Response response = await http
                                                .post(
                                                    'https://craftapp.net/services/CraftWebService.asmx',
                                                    headers: {
                                                      "SOAPAction":
                                                          "http://Craft.WS/ForgetPassword2",
                                                      "Content-Type":
                                                          "text/xml;charset=UTF-8",
                                                    },
                                                    body: utf8.encode(soap),
                                                    encoding:
                                                        Encoding.getByName(
                                                            "UTF-8"))
                                                .then((onValue) {
                                              return onValue;
                                            });
                                            String json = parse(response.body)
                                                .getElementsByTagName(
                                                    'ForgetPassword2Result')[0]
                                                .text;
                                            final decoded = jsonDecode(json);
                                            setState(() {
                                              load = false;
                                            });

                                            if (decoded['ID'] != 0) {
                                              await addData(
                                                  decoded['ID'].toString(),
                                                  decoded['Name'],
                                                  decoded['Phone'],
                                                  decoded['Email'],
                                                  decoded['Password'],
                                                  decoded['Image'],
                                                  '0');

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ForgetPassCode(
                                                            userid:  decoded['ID'].toString(),
                                                          )));
                                            } else {
                                              setState(() {
                                                sms = decoded['Name'];
                                              });
                                            }
                                          }
                                        }),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
