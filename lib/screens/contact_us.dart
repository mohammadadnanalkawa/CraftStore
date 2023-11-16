import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';
import 'home.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String sms = "";

  TextEditingController name = TextEditingController(
      text: globals.user != null ? globals.user.name : '');
  TextEditingController email = TextEditingController(
      text: globals.user != null ? globals.user.email : '');
  TextEditingController phone = TextEditingController(
      text: globals.user != null ? globals.user.phone : '');

  TextEditingController body = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool load = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
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
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      width: MediaQuery.of(context).size.width,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppBarOne(
                              implyLeading: true,
                              text: globals.loc == 'en'
                                  ? 'Contact Us'
                                  : 'اتصل بنا',
                              press: () {
                                Navigator.pop(context);
                              },
                              textColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                            SizedBox(height: 15),
                            TextFormField(
                                style: TextStyle(fontSize: 20),
                                controller: name,
                                validator: (val) {
                                  if (val.length == 0)
                                    return 'مطلوب';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                    prefixIcon: Icon(
                                        CupertinoIcons.person_alt_circle,
                                        size: 22),
                                    hintText:
                                        globals.loc == "en" ? "Name" : "الاسم",
                                    hintStyle: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    isDense: true)),
                            SizedBox(height: 20),
                            TextFormField(
                                style: TextStyle(fontSize: 20),
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val.length == 0)
                                    return 'مطلوب';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.mail_outline, size: 22),
                                    hintText: globals.loc == "en"
                                        ? "Email Address"
                                        : "بريدك الإلكتروني",
                                    hintStyle: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    isDense: true)),
                            SizedBox(height: 20),
                            TextFormField(
                                style: TextStyle(fontSize: 20),
                                controller: phone,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(
                                        Icons.mobile_friendly_outlined,
                                        size: 22),
                                    hintText: globals.loc == "en"
                                        ? "Mobile (optional)"
                                        : "رقم جوالك (اخياري)",
                                    hintStyle: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    isDense: true)),
                            SizedBox(height: 20),
                            TextFormField(
                                style: TextStyle(fontSize: 20),
                                keyboardType: TextInputType.multiline,
                                minLines:
                                    3, //Normal textInputField will be displayed
                                maxLines:
                                    5, // when user presses enter it will adapt to it

                                controller: body,
                                validator: (val) {
                                  if (val.length == 0)
                                    return 'مطلوب';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                    hintText: globals.loc == "en"
                                        ? "Message"
                                        : "رسالتك",
                                    hintStyle: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    isDense: true)),
                            SizedBox(height: 15),
                            Text(globals.loc == 'en'
                                ? '• Your complaint will be answered within 24 working hours.'
                                : '• سيتم الرد على الشكوى خلال 24 ساعة عمل.',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                            SizedBox(
                              height: 10,
                            ),
                            Text(globals.loc == 'en'
                                ? '• The complaint will be solve within 7 working days in official working hours.'
                                : '• سيتم معالجة الشكوى خلال 7 أيام عمل في أوقات الدوام الرسمية.',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                         SizedBox(height: 10,),
                         sms == '' ?Container():   Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                sms,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 22),
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
                                            shape: RoundedRectangleBorder(),
                                            color: yellow,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 15),
                                            child: Text(
                                              globals.loc == "en"
                                                  ? 'Send'
                                                  : 'ارسال',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                setState(() {
                                                  load = true;
                                                });
                                                String sendval = "";
                                                if (globals.user != null)
                                                  sendval = globals.user.id;
                                                else
                                                  sendval = '0';
                                                String soap =
                                                    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ContactUs xmlns="http://Craft.WS/">
      <UserID>$sendval</UserID>
      <UserType>0</UserType>
      <Email>${email.text}</Email>
      <Name>${name.text}</Name>
      <Phone>${phone.text}</Phone>
      <Body>${body.text}</Body>
    </ContactUs>
  </soap:Body>
</soap:Envelope>''';

                                                http.Response responseUpdate =
                                                    await http
                                                        .post(
                                                            'https://craftapp.net/services/CraftWebService.asmx',
                                                            headers: {
                                                              "SOAPAction":
                                                                  "http://Craft.WS/ContactUs",
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
                                                        responseUpdate.body)
                                                    .getElementsByTagName(
                                                        'ContactUsResult')[0]
                                                    .text;
                                                final decoded =
                                                    jsonDecode(json);
                                                print(responseUpdate.body);
                                                setState(() {
                                                  load = false;
                                                });
                                                if (decoded == '-1') {
                                                  sms = 'خطأ غير معروف';
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              WillPopScope(
                                                                onWillPop:
                                                                    () async =>
                                                                        false,
                                                                child: Home(
                                                                    index: 0),
                                                              )));
                                                }
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
                                             SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    var url = 'https://twitter.com/craftapp_';

                                    launch(
                                      url,
                                      universalLinksOnly: true,
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    'assets/twitter.svg',
                                    fit: BoxFit.fill,
                                    height: 29,
                                    width: 29,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    var url = 'https://instagram.com/craft.app';

                                    launch(
                                      url,
                                      universalLinksOnly: true,
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    'assets/insta.svg',
                                    height: 29,
                                    width: 29,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    var url =
                                        'https://www.snapchat.com/add/craftapp';

                                    launch(
                                      url,
                                      universalLinksOnly: true,
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    'assets/snap.svg',
                                    height: 29,
                                    width: 29,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      
                                      await launch(
                                          'https://wa.me/message/XSGVBIBD35GPO1', forceWebView: true , universalLinksOnly: true);
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                          msg: globals.loc == 'en'
                                              ? 'Failed to open whatsapp'
                                              : 'فشل في فتح واتساب',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey[800],
                                          textColor: Colors.white,
                                          fontSize: 14.0);
                                    }
                                  },
                                  child: SvgPicture.asset(
                                    'assets/whatsappsvg.svg',
                                    height: 29,
                                    width: 29,
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                                             SizedBox(height: 20),
                
                          ],
                        ),
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

class Complain {
  final String id;
  final String name;
  Complain({this.id, this.name});
}
