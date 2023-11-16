import 'package:crafts/core/color.dart';
import 'package:crafts/screens/addresses.dart';
import 'package:crafts/screens/cards.dart';
import 'package:crafts/screens/contact_us.dart';
import 'package:crafts/screens/edit_profile.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/joinus.dart';
import 'package:crafts/screens/landing_page.dart';
import 'package:crafts/screens/orders.dart';
import 'package:crafts/screens/policy.dart';
import 'package:crafts/screens/rules.dart';
import 'package:crafts/screens/terms.dart';
import 'package:crafts/screens/wallet.dart';
import 'package:crafts/screens/welcome.dart';
import 'package:crafts/widgets/app_bar_two.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crafts/screens/notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool loading = false;
  String name;
  String email;
  String phone;
  bool langLoad = false;
  TextEditingController deletereason = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> addStringToSF(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Language', val);
  }

  removeValues() async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("ID");
    prefs.remove("Name");
    prefs.remove("Phone");
    prefs.remove("Email");
    prefs.remove("Password");
    prefs.remove("Image");
    setState(() {
      loading = false;
    });
  }

  void getProfile() async {
    setState(() {
      if (globals.user != null) {
        name = globals.user.name;
        phone = globals.user.phone;
        email = globals.user.email;
      } else
        loading = true;
    });

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetProfile xmlns="http://Craft.WS/">
      <ClientID>${globals.user.id}</ClientID>
    </GetProfile>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetProfile",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetProfileResult')[0].text;
    final decoded = jsonDecode(json);
    name = decoded['Name'];
    phone = decoded['Phone'];
    email = decoded['Email'];
    loading = false;

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
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
            : SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      AppBarTwo(
                        text: globals.loc == 'en' ? 'My Account' : 'حسابي',
                        press: () {
                          Navigator.pop(context);
                        },
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                globals.user.type == '0'
                                    ? globals.user.name
                                    : globals.loc == 'en'
                                        ? 'gust'
                                        : 'زائر',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            SizedBox(height: 3),
                            globals.user.type == '0'
                                ? Text(phone,
                                    style: TextStyle(
                                      fontSize: 22,
                                    ))
                                : Container(),
                            globals.user.type == '0'
                                ? SizedBox(height: 3)
                                : Container(),
                            globals.user.type == '0'
                                ? Text(email,
                                    style: TextStyle(
                                      fontSize: 22,
                                    ))
                                : Container(),
                            globals.user.type == '0'
                                ? SizedBox(height: 10)
                                : Container(),
                            globals.user.type == '0'
                                ? RaisedButton(
                                    elevation: 0,
                                    color: Colors.grey[800],
                                    child: Text(
                                      globals.loc == 'en'
                                          ? 'Edit Account'
                                          : 'تحرير الحساب',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18),
                                    ),
                                    onPressed: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfile()));
                                    })
                                : Container(),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Orders()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/orders.png',
                                          height: 25,
                                          width: 25,
                                          fit: BoxFit.fill,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          globals.loc == 'en'
                                              ? 'Orders'
                                              : 'الطلبات',
                                          style: TextStyle(fontSize: 22),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                    height: 30,
                                    child: VerticalDivider(
                                      thickness: 1.5,
                                    )),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Addresses()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/marker.png',
                                          height: 25,
                                          width: 20,
                                          fit: BoxFit.fill,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          globals.loc == 'en'
                                              ? 'Address'
                                              : 'العناوين',
                                          style: TextStyle(fontSize: 22),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            ListView(
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: [
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                /*  ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(globals.loc == 'en'
                                      ? 'My Orders'
                                      : 'طلباتي'),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ), */
                                ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Notifications()));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Notifications'
                                        : 'التنبيهات',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () {
                                    if (globals.user.type == '0') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Wallet()));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LandingPage()));
                                    }
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'My Wallet'
                                        : 'المحفظة',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () {
                                    if (globals.user.type == '0') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Cards()));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LandingPage()));
                                    }
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'My Cards, Payment'
                                        : 'بطاقات. الدفع',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ContactUs()));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Contact us'
                                        : 'اتصل بنا',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => JoinUs()));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Join us'
                                        : 'انضم الينا',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                /*    ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(globals.loc == 'en'
                                      ? 'Language'
                                      : 'اللغة'),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ), */
                                ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Rules()));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Exchange and Return Policy'
                                        : 'سياسة الاستبدال و الاسترجاع',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Policy(
                                                  sourcepage: '1',
                                                )));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Privacy & Policy'
                                        : 'سياسة الخصوصية والإستخدام',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Terms(
                                                  sourcepage: '1',
                                                )));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Terms & Conditions'
                                        : 'الأحكام والشروط',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _deleteDialog(),
                                    );
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Delete Account'
                                        : 'حذف الحساب',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 1,
                                ),
                                ListTile(
                                  onTap: () async {
                                    await removeValues();
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => WillPopScope(
                                                onWillPop: () async => false,
                                                child: LandingPage())));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Logout'
                                        : 'تسجيل خروج',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                globals.user.type == '0'
                                    ? Divider(
                                        height: 5,
                                        thickness: 1,
                                      )
                                    : Container()
                              ],
                            ),
                            SizedBox(height: 20),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: langLoad
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                yellow),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'English',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Switch(
                                            activeColor: yellow,
                                            inactiveThumbColor: yellow,
                                            inactiveTrackColor: yellow,
                                            activeTrackColor: yellow,
                                            value: globals.loc == 'en'
                                                ? false
                                                : true,
                                            onChanged: (value) async {
                                              setState(() {
                                                langLoad = true;
                                              });
                                              await addStringToSF(
                                                  globals.loc == 'en'
                                                      ? 'ar'
                                                      : 'en');

                                              if (globals.loc == 'en') {
                                                globals.loc = 'ar';
                                              } else {
                                                globals.loc = 'en';
                                              }

                                              String soap =
                                                  '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <UpdateCustomerLanguage xmlns="http://Craft.WS/">
      <ID>${globals.user.id}</ID>
      <Language>${globals.loc == 'en' ? '0' : '1'}</Language>
    </UpdateCustomerLanguage>
  </soap:Body>
</soap:Envelope>''';
                                              http.Response response =
                                                  await http
                                                      .post(
                                                          'https://craftapp.net/services/CraftWebService.asmx',
                                                          headers: {
                                                            "SOAPAction":
                                                                "http://Craft.WS/UpdateCustomerLanguage",
                                                            "Content-Type":
                                                                "text/xml;charset=UTF-8",
                                                          },
                                                          body:
                                                              utf8.encode(soap),
                                                          encoding: Encoding
                                                              .getByName(
                                                                  "UTF-8"))
                                                      .then((onValue) {
                                                return onValue;
                                              });
                                              setState(() {
                                                langLoad = false;
                                              });
                                              Navigator.pop(context);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WillPopScope(
                                                            onWillPop:
                                                                () async =>
                                                                    false,
                                                            child: Home(
                                                              index: 0,
                                                            ),
                                                          )));
                                            }),
                                        Text(
                                          'العربية',
                                          style: TextStyle(fontSize: 20),
                                        )
                                      ],
                                    ),
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

  Widget _deleteDialog() {
    return AlertDialog(
      content: Directionality(
        textDirection:
            globals.loc == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              /*            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                  ),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ),
    */
              SizedBox(height: 20),
              Text(globals.loc == 'en' ? 'Confirmation' : 'تأكيد',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  )),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          globals.loc == 'en'
                              ? 'If you are sure that you want to delete your CRAFTAPP account, you will not be able to create another CRAFTAPP account with your same Email. And you will lose access to any information and orders you have created in CRAFTAPP. '
                              : 'اذا كنت متأكدًا من رغبتك في حذف حسابك في تطبيق CRAFTAPP، فلن تتمكن من إنشاء حساب اخر في CRAFTAPP بنفس بريدك الإلكتروني المسجل به. وستفقد الوصول إلى أي معلومات والطلبات التي قمت بإنشائها في CRAFTAPP.',
                          style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      TextFormField(
                          controller: deletereason,
                          validator: (val) {
                            if (val.length == 0)
                              return globals.loc == 'en' ? 'Required' : 'مطلوب';
                            else
                              return null;
                          },
                          enabled: true,
                          cursorColor: Colors.black,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
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
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                              labelText:
                                  globals.loc == 'en' ? 'Reason' : 'السبب',
                              isDense: true)),
                      SizedBox(height: 20),
                      Text(
                          globals.loc == 'en'
                              ? 'You are about to delete your account, Continue ?'
                              : 'أنت على وشك حذف حسابك ، هل تريد المتابعة؟',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            child: RaisedButton(
                                elevation: 0,
                                color: yellow,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Text(
                                  globals.loc == 'en' ? 'Delete' : 'حذف',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    print(globals.user.id);
                                    String soapCategory =
                                        '''<?xml version="1.0" encoding="utf-8"?>
                                                               <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                                                                 <soap:Body>
                                      <RemoveAccount xmlns="http://Craft.WS/">
                                        <CustomerID>${globals.user.id}</CustomerID>
                                       <RemoveReason>${deletereason.text}</RemoveReason>
                                      </RemoveAccount>
                                                                 </soap:Body>
                                                               </soap:Envelope>''';
                                    http
                                        .post(
                                            'https://craftapp.net/services/CraftWebService.asmx',
                                            headers: {
                                              "SOAPAction":
                                                  "http://Craft.WS/RemoveAccount",
                                              "Content-Type":
                                                  "text/xml;charset=UTF-8",
                                            },
                                            body: utf8.encode(soapCategory),
                                            encoding:
                                                Encoding.getByName("UTF-8"))
                                        .then((onValue) {
                                      return onValue;
                                    });
                                    await removeValues();
                                    await Future.delayed(Duration(seconds: 2));
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => WillPopScope(
                                                onWillPop: () async => false,
                                                child: LandingPage())));
                                  }
                                }),
                          ),
                          Container(
                            child: RaisedButton(
                                elevation: 0,
                                color: Colors.grey,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Text(
                                  globals.loc == 'en' ? 'Cancel' : 'الغاء',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                }),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
