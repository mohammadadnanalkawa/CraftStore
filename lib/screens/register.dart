import 'package:crafts/core/color.dart';
import 'package:crafts/helpers/user.dart';
import 'package:crafts/screens/activate.dart';
import 'package:crafts/screens/terms.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:crafts/widgets/app_bar_two.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../core/color.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController name = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController cemail = new TextEditingController();

  TextEditingController password = new TextEditingController();
  TextEditingController cpassword = new TextEditingController();

  bool selected = false;
  final _formKey = GlobalKey<FormState>();
  String error = '';
  String isoCode = 'SA';
  bool load = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  addData(String id, String name, String phone, String email, String password,
      String image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ID', id);
    prefs.setString('Name', name);
    prefs.setString('Phone', phone);
    prefs.setString('Email', email);
    prefs.setString('Password', password);
    prefs.setString('Image', image);
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
                          ? 'Create your\naccount'
                          : 'أنشئ حسابك',
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
                            controller: name,
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
                                  color: Colors.black,
                                  fontSize: 26,
                                ),
                                labelText:
                                    globals.loc == 'en' ? 'Name' : 'الاسم',
                                isDense: true)),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          globals.loc == 'en' ? 'Mobile Number' : 'رقم الهاتف',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: IntlPhoneField(
                            autoValidate: false,
                            initialCountryCode: 'SA',
                            style: TextStyle(fontSize: 24),
                            controller: phone,
                            validator: (val) {
                              if (val.length == 0)
                                return globals.loc == 'en'
                                    ? 'Required'
                                    : 'مطلوب';
                              else
                                return null;
                            },
                            decoration: InputDecoration(
                                hintText: 'xxxxxxxxx',
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
                                isDense: true),
                            onCountryChanged: (phoneval) {
                              setState(() {
                                isoCode = phoneval.countryISOCode;
                              }); 
                            },
                            onChanged: (phoneval) {
                              setState(() {
                                isoCode = phoneval.countryISOCode;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                            style: TextStyle(fontSize: 24),
                            controller: email,
                            textAlign: TextAlign.left,
                            validator: (val) {
                              if (val.length == 0)
                                return globals.loc == 'en'
                                    ? 'Required'
                                    : 'مطلوب';
                              else
                                return null;
                            },
                            keyboardType: TextInputType.emailAddress,
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
                                    ? 'ٌEmail'
                                    : 'البريد الالكتروني',
                                isDense: true)),
                       SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                            style: TextStyle(fontSize: 24),
                            controller: cemail,
                            textAlign: TextAlign.left,

                            validator: (val) {
                               if (val != email.text)

                                return globals.loc == 'en'
                                    ? 'ُEmail not matches'
                                    : 'البريد الالكتروني غير متطابق';
                              else
                                return null;
                            },
                            
                            keyboardType: TextInputType.emailAddress,
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
                                   ? 'Re-Email'
                                    : 'إعادة البريد الالكتروني',
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
                    
                       SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                            style: TextStyle(fontSize: 24),
                            controller: cpassword,
                            textAlign: TextAlign.left,

                            validator: (val) {
                              if (val != password.text)
                                return globals.loc == 'en'
                                    ? 'Password not matches'
                                    : 'كلمة المرور غير مطابقة';
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
                                    ? 'Return Password'
                                    : 'إعادة كلمة المرور',
                                isDense: true)),
                    
                        SizedBox(height: 15),
                        Text(
                          '$error',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: InkWell(
                            onTap: () {
                              setState(() {
                                selected = !selected;
                              });
                            },
                            child: Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected ? yellow : Colors.transparent,
                                  border: Border.all(width: 1, color: yellow)),
                              child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: selected
                                      ? Icon(
                                          Icons.check,
                                          size: 14.0,
                                          color: Colors.white,
                                        )
                                      : Container()),
                            ),
                          ),
                          // RoundCheckBox(
                          //     size: 16,
                          //     isChecked: this.selected,
                          //     onTap: (val) => this.setState(() {
                          //           this.selected = !this.selected;
                          //         })),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                  globals.loc == 'en'
                                      ? 'I agree to the'
                                      : 'قرأت ووافقت',
                                  style: TextStyle(
                                    color: Colors.brown[900],
                                    fontSize: 20,
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color:
                                        Colors.brown[900], // Text colour here
                                    width: 1.0, // Underline width
                                  ))),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Terms(
                                                    sourcepage: '0',
                                                  )));
                                    },
                                    child: Text(
                                        globals.loc == 'en'
                                            ? 'Terms & Conditions'
                                            : 'الشروط والأحكام',
                                        style: TextStyle(
                                            color: Colors.brown[900],
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => this.setState(() {
                            this.selected = !this.selected;
                          }),
                        ),
                        SizedBox(height: 50),
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
                                              ? 'Sign Up'
                                              : 'تسجيل',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Colors.white),
                                        ),
                                        onPressed: !selected
                                            ? null
                                            : () async {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  setState(() {
                                                    load = true;
                                                  });
                                                  String soap =
                                                      '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <SignCustomer2 xmlns="http://Craft.WS/">
      <Name>${name.text}</Name>
      <Phone>${phone.text}</Phone>
      <Email>${email.text}</Email>
      <Password>${password.text}</Password>
      <CountryISOCode>$isoCode</CountryISOCode>
    </SignCustomer2>
  </soap:Body>
</soap:Envelope>''';
                                                  http.Response response =
                                                      await http
                                                          .post(
                                                              'https://craftapp.net/services/CraftWebService.asmx',
                                                              headers: {
                                                                "SOAPAction":
                                                                    "http://Craft.WS/SignCustomer2",
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

                                                  if (response.statusCode ==
                                                      200) {
                                                    print(response.body);
                                                    String json = parse(
                                                            response.body)
                                                        .getElementsByTagName(
                                                            'SignCustomer2Result')[0]
                                                        .text;
                                                    final decoded =
                                                        jsonDecode(json);
                                                    print(decoded);
                                                    if (decoded == '-1') {
                                                      setState(() {
                                                        error = globals.loc ==
                                                                'en'
                                                            ? 'Account already exists'
                                                            : 'الحساب موجود بالفعل';
                                                      });
                                                    } else {
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
                                                      http.Response
                                                          responseLogin =
                                                          await http
                                                              .post(
                                                                  'https://craftapp.net/services/CraftWebService.asmx',
                                                                  headers: {
                                                                    "SOAPAction":
                                                                        "http://Craft.WS/LoginCustomer2",
                                                                    "Content-Type":
                                                                        "text/xml;charset=UTF-8",
                                                                  },
                                                                  body: utf8.encode(
                                                                      soapLogin),
                                                                  encoding: Encoding
                                                                      .getByName(
                                                                          "UTF-8"))
                                                              .then((onValue) {
                                                        return onValue;
                                                      });
                                                      String json = parse(
                                                              responseLogin
                                                                  .body)
                                                          .getElementsByTagName(
                                                              'LoginCustomer2Result')[0]
                                                          .text;
                                                      final decodedLogin =
                                                          jsonDecode(json);
                                                    
                                
                                                      User user = User(
                                                          id: decodedLogin['ID']
                                                              .toString(),
                                                          name: decodedLogin[
                                                              'Name'],
                                                          phone: decodedLogin[
                                                              'Phone'],
                                                          email: decodedLogin[
                                                              'Email'],
                                                          password:
                                                              decodedLogin[
                                                                  'Password'],
                                                          image: decodedLogin[
                                                              'Photo'],
                                                          type: '0');
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Activate(
                                                                        user:
                                                                            user,
                                                                      )));
                                                    }
                                                  } else {
                                                    setState(() {
                                                      error =
                                                          globals.loc == 'en'
                                                              ? 'Unknown error'
                                                              : 'خطأ غير معروف';
                                                    });
                                                  }
                                                  setState(() {
                                                    load = false;
                                                  });
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
