import 'dart:async';
import 'package:crafts/core/color.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:crafts/helpers/user.dart';
import 'package:crafts/helpers/wrapper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/widgets/app_bar_two.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Activate extends StatefulWidget {
  final User user;
  Activate({@required this.user});
  @override
  _ActivateState createState() => _ActivateState();
}

class _ActivateState extends State<Activate> {
  bool load = false;
  bool loading = true;
  String currentText = "";
  String sms= "";

  final formKey = GlobalKey<FormState>();
  StreamController<ErrorAnimationType> errorController;
  TextEditingController textEditingController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  addData(String id, String name, String phone, String email, String password,
      String image, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ID', id);
    prefs.setString('Name', name);
    prefs.setString('Phone', phone);
    prefs.setString('Email', email);
    prefs.setString('Password', password);
    prefs.setString('Image', image);
    prefs.setString('Type', type);

  }

  

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        body:/*  loading
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
            :  */SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      AppBarTwo(
                          text: globals.loc == 'en'
                              ? 'Activate your\account'
                              : 'فعل حسابك',
                          press: () {
                              Navigator.pop(context);
                          }),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              globals.loc == 'en' ? 'Enter Code' : 'ادخل الرمز',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(globals.loc == 'en'
                                ? 'Enter the code that you received on email'
                                : 'أدخل الرمز الذي تلقيته على البريد الإلكتروني',
                                 style: TextStyle(
                                  fontSize: 22,)),
                            SizedBox(
                              height: 30,
                            ),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Form(
                                key: formKey,
                                child: Container(
                                  //margin: EdgeInsets.symmetric(horizontal: 25),
                                  child: PinCodeTextField(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    appContext: context,
                                    pastedTextStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    length: 4,
                                    animationType: AnimationType.fade,
                                    validator: (v) {
                                      if (v.length < 4) {
                                        return "";
                                      } else {
                                        return null;
                                      }
                                    },
                                    pinTheme: PinTheme(
                                        selectedColor: Colors.black,
                                        activeColor: Colors.black,
                                        inactiveColor: Colors.black,
                                        shape: PinCodeFieldShape.box,
                                        borderWidth: 1,
                                        borderRadius: BorderRadius.circular(15),
                                        fieldHeight: 55,
                                        fieldWidth: 55),
                                    cursorColor: Colors.black,
                                    animationDuration:
                                        Duration(milliseconds: 300),
                                    textStyle: TextStyle(
                                        fontSize: 20,
                                        height: 1.6,
                                        fontWeight: FontWeight.w600),
                                    backgroundColor: Colors.transparent,
                                    enableActiveFill: false,
                                    errorAnimationController: errorController,
                                    controller: textEditingController,
                                    keyboardType: TextInputType.number,
                                    onCompleted: (v) {
                                      print("Completed");
                                    },
                                    // onTap: () {
                                    //   print("Pressed");
                                    // },
                                    onChanged: (value) {
                                      print(value);
                                      setState(() {
                                        currentText = value;
                                      });
                                    },
                                    beforeTextPaste: (text) {
                                      print("Allowing to paste $text");
                                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                      return true;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  String soap =
                                      '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ResendCode xmlns="http://Craft.WS/">
      <ClientID>${widget.user.id}</ClientID>
    </ResendCode>
  </soap:Body>
</soap:Envelope>''';
                                  http.Response response = await http
                                      .post(
                                          'https://craftapp.net/services/CraftWebService.asmx',
                                          headers: {
                                            "SOAPAction":
                                                "http://Craft.WS/ResendCode",
                                            "Content-Type":
                                                "text/xml;charset=UTF-8",
                                          },
                                          body: utf8.encode(soap),
                                          encoding: Encoding.getByName("UTF-8"))
                                      .then((onValue) {
                                    return onValue;
                                  });
                                  String json = parse(response.body)
                                      .getElementsByTagName(
                                          'ResendCodeResult')[0]
                                      .text;
                                  final decoded = jsonDecode(json);
                                  setState(() {
                                    loading = false;
                                  });
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                          content: Text(
                                            decoded,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                          duration: Duration(seconds: 4)));
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
                                          ? 'Resend Code'
                                          : 'أعد إرسال الرمز',
                                      style: TextStyle(
                                          color: Colors.brown[900],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                              Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        
                                        sms,
                                        style: TextStyle(color: Colors.red, fontSize: 22 ),
                                      ),
                                    ),
                            load
                                ? Align(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              yellow),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: RaisedButton(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                               ),
                                            color: Colors.grey[800],
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 15),
                                            child: Text(
                                              globals.loc == 'en'
                                                  ? 'Submit'
                                                  : 'إرسال',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white, fontSize: 22),
                                            ),
                                            onPressed: () async {
                                              if (formKey.currentState
                                                  .validate()) {
                                                setState(() {
                                                  load = true;
                                                });
                                                String soap =
                                                    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <CheckVerfiyCode xmlns="http://Craft.WS/">
      <ClientID>${widget.user.id}</ClientID>
      <Code>$currentText</Code>
    </CheckVerfiyCode>
  </soap:Body>
</soap:Envelope>''';
                                                http.Response response =
                                                    await http
                                                        .post(
                                                            'https://craftapp.net/services/CraftWebService.asmx',
                                                            headers: {
                                                              "SOAPAction":
                                                                  "http://Craft.WS/CheckVerfiyCode",
                                                              "Content-Type":
                                                                  "text/xml;charset=UTF-8",
                                                            },
                                                            body: utf8
                                                                .encode(soap),
                                                            encoding: Encoding
                                                                .getByName(
                                                                    "UTF-8"))
                                                        .then((onValue) {
                                                  return onValue;
                                                });
                                                String json = parse(
                                                        response.body)
                                                    .getElementsByTagName(
                                                        'CheckVerfiyCodeResult')[0]
                                                    .text;
                                                final decoded =
                                                    jsonDecode(json);
                                                if (decoded == "1") {
                                                  await addData(
                                                      widget.user.id,
                                                      widget.user.name,
                                                      widget.user.phone,
                                                      widget.user.email,
                                                      widget.user.password,
                                                      widget.user.image,
                                                      widget.user.type);
                                                  setState(() {
                                                    load = false;
                                                  });
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Wrapper(),
                                                      ));
                                                } else {
                                                  setState(() {
                                                    sms = decoded;
                                                    load = false;
                                                  });
                                                 /*  _scaffoldKey.currentState
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                            decoded,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15),
                                                          ),
                                                          duration: Duration(
                                                              seconds: 4))); */
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
    );
  }
}
