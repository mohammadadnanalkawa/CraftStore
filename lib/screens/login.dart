import 'package:crafts/core/color.dart';
import 'package:crafts/helpers/wrapper.dart';
import 'package:crafts/screens/forgot_password.dart';
import 'package:crafts/screens/policy.dart';
import 'package:crafts/screens/terms.dart';
import 'package:crafts/widgets/app_bar_two.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String error = '';
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool load = false;
  final _formKey = GlobalKey<FormState>();
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

  removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("ID");
    prefs.remove("Name");
    prefs.remove("Phone");
    prefs.remove("Email");
    prefs.remove("Password");
    prefs.remove("Image");
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppBarTwo(
                      text: globals.loc == 'en'
                          ? 'Log into your account'
                          : 'تسجيل الدخول إلى حسابك',
                      press: () {
                        Navigator.pop(context);
                      }),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.left,
                            controller: email,
                            validator: (val) {
                              if (val.length == 0)
                                return globals.loc == 'en'
                                    ? 'Required'
                                    : 'مطلوب';
                              else
                                return null;
                            },
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    color: Colors.black, fontSize: 26),
                                labelText: globals.loc == 'en'
                                    ? 'Email ID/Mobile Number'
                                    : 'البريد الالكتروني/ رقم الهاتف',
                                isDense: true)),
                        SizedBox(
                          height: 20,
                        ),
                     
                           TextFormField(
                              style: TextStyle(fontSize: 24),
                              controller: password,
                              textAlign: TextAlign.left,

                              validator: (val) {
                                if (val.length == 0)
                                  return globals.loc == 'en'
                                      ? 'Required'
                                      : 'مطلوب';
                                else
                                  return null;
                              },
                              obscureText: true,
                              cursorColor: Colors.black,
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
                                      ? 'Password'
                                      : 'كلمة المرور',
                                  isDense: true)),
                        
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Text(
                              globals.loc == 'en'
                                  ? 'Forgot Password?'
                                  : 'هل نسيت كلمة السر؟',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '$error',
                          style: TextStyle(color: Colors.red, fontSize: 22),
                        ),
                        SizedBox(height: 20),
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
                                              ? 'Sign In'
                                              : 'تسجيل الدخول',
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
                                              String token;
                                                await _firebaseMessaging
                                                    .getToken()
                                                    .then((value) {
                                                  token = value;
                                                });
                                            String soapLogin =
                                                '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <LoginCustomer2 xmlns="http://Craft.WS/">
      <Username>${email.text}</Username>
      <Password>${password.text}</Password>
        <firebase_tokenkey>$token</firebase_tokenkey>
       <Language>${globals.loc == 'en' ? 0 : 1}</Language>
    </LoginCustomer2>
  </soap:Body>
</soap:Envelope>''';
                                            http.Response responseLogin =
                                                await http
                                                    .post(
                                                        'https://craftapp.net/services/CraftWebService.asmx',
                                                        headers: {
                                                          "SOAPAction":
                                                              "http://Craft.WS/LoginCustomer2",
                                                          "Content-Type":
                                                              "text/xml;charset=UTF-8",
                                                        },
                                                        body: utf8
                                                            .encode(soapLogin),
                                                        encoding:
                                                            Encoding.getByName(
                                                                "UTF-8"))
                                                    .then((onValue) {
                                              return onValue;
                                            });
                                            setState(() {
                                              load = false;
                                            });
                                            print(responseLogin.body);
                                            if (responseLogin.statusCode ==
                                                200) {
                                              String json = parse(
                                                      responseLogin.body)
                                                  .getElementsByTagName(
                                                      'LoginCustomer2Result')[0]
                                                  .text;
                                              final decodedLogin =
                                                  jsonDecode(json);
                                              if (decodedLogin ==
                                                      "البريد الالكتروني أو كلمة المرور خاطئة" ||
                                                  decodedLogin ==
                                                      "Username or Password incorrect") {
                                                setState(() {
                                                  error = globals.loc == 'en'
                                                      ? 'Incorrect Email/Password'
                                                      : 'البريد الالكتروني أو كلمة المرور خاطئة';
                                                });
                                              } else {
                                                await addData(
                                                    decodedLogin['ID']
                                                        .toString(),
                                                    decodedLogin['Name'],
                                                    decodedLogin['Phone'],
                                                    decodedLogin['Email'],
                                                    decodedLogin['Password'],
                                                    decodedLogin['Image'],
                                                    '0');

                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Wrapper(),
                                                    ));
                                              }
                                            } else {
                                              setState(() {
                                                error = globals.loc == 'en'
                                                    ? 'Unknown error'
                                                    : 'خطأ غير معروف';
                                              });
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
                                    color:
                                        Colors.brown[900], // Text colour here
                                    width: 1.0, // Underline width
                                  ))),
                                  child: Text(
                                      globals.loc == 'en'
                                          ? 'Terms & Conditions'
                                          : 'الشروط والأحكام',
                                      style: TextStyle(
                                          color: Colors.brown[900],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
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
                                    color:
                                        Colors.brown[900], // Text colour here
                                    width: 1.0, // Underline width
                                  ))),
                                  child: Text(
                                      globals.loc == 'en'
                                          ? 'User Policy'
                                          : 'سياسة المستخدم',
                                      style: TextStyle(
                                          color: Colors.brown[900],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
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
