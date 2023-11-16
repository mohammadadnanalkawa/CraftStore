import 'package:crafts/widgets/header.dart';
import 'package:intl/intl.dart' as intl;
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';
import 'home.dart';

class JoinUs extends StatefulWidget {
  @override
  _JoinUsState createState() => _JoinUsState();
}

class _JoinUsState extends State<JoinUs> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController name = TextEditingController(
      text: globals.user != null ? globals.user.name : '');
  TextEditingController email = TextEditingController(
      text: globals.user != null ? globals.user.email : '');
  TextEditingController phone = TextEditingController(
      text: globals.user != null ? globals.user.phone : '');
  TextEditingController brand = TextEditingController(text: '');
  TextEditingController city = TextEditingController(text: '');
  TextEditingController address = TextEditingController(text: '');
  TextEditingController notes = TextEditingController(text: '');

  final _formKey = GlobalKey<FormState>();
  String group = '';
  String groupcat = '';
  String sms= "";

  bool selected = false;
  DateTime current = DateTime.now();

  bool loading = false;
  bool load = false;
  List<Complain> complains = [];
  Complain _complain;
  @override
  void initState() {
    getProblem();

    super.initState();
  }

  void getProblem() async {
    setState(() {
      loading = true;
    });
    String soapCategory = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetJoinCat xmlns="http://Craft.WS/" >
      <CustomerID>${globals.user.id}</CustomerID>
</GetJoinCat>
  </soap:Body>
</soap:Envelope>''';
    http.Response responseCategory = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetJoinCat",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soapCategory),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    if (responseCategory.statusCode == 200) {
      print(responseCategory.body);
      String json = parse(responseCategory.body)
          .getElementsByTagName('GetJoinCatResult')[0]
          .text;
      final decoded = jsonDecode(json);
      for (int i = 0; i < decoded.length; i++) {
        complains.add(Complain(id: decoded[i]['ID'], name: decoded[i]['Name'], ischeck: false));
      }
      _complain = complains[complains.length - 1];
    }
    setState(() {
      loading = false;
    });
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
                          top: 15, bottom: 15, left: 20, right: 20),
                      width: MediaQuery.of(context).size.width,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppBarOne(
                              implyLeading: true,
                              text: globals.loc == 'en'
                                  ? 'Join Us'
                                  : 'انضم الينا',
                              press: () {
                                Navigator.pop(context);
                              },
                              textColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Text(
                                  globals.loc == 'en' ? 'Date' : 'التاريخ',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Card(
                                    color: Colors.grey[200],
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              current = current
                                                  .subtract(Duration(days: 1));
                                              print(current);
                                              setState(() {});
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(),
                                              child: Icon(Icons.arrow_back_ios,
                                                  size: 20,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              final DateTime picked =
                                                  await showDatePicker(
                                                      context: context,
                                                      initialDate: current,
                                                      firstDate: DateTime(1900),
                                                      lastDate:  DateTime(3000));
                                              if (picked != null &&
                                                  picked != current)
                                                setState(() {
                                                  current = picked;
                                                });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(),
                                              child: Text(
                                                  intl.DateFormat('dd-MM-yyyy')
                                                      .format(current),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20)),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              current = current
                                                  .add(Duration(days: 1));
                                              print(current);
                                              setState(() {});
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(),
                                              child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 20,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 30),
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
                                    prefixIcon: Icon(Icons.person, size: 22),
                                    hintText: globals.loc == "en"
                                        ? "Client Name"
                                        : "اسم العميل",
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
                                controller: brand,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.branding_watermark,
                                        size: 22),
                                    hintText: globals.loc == "en"
                                        ? "Brand Name"
                                        : "اسم العلامة التجارية",
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
                                controller: city,
                                decoration: InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.location_city, size: 22),
                                    hintText: globals.loc == "en"
                                        ? "City"
                                        : "المدينة",
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
                                controller: address,
                                decoration: InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.map_outlined, size: 22),
                                    hintText: globals.loc == "en"
                                        ? "Address"
                                        : "العنوان",
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
                                decoration: InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.email_outlined, size: 22),
                                    hintText: globals.loc == "en"
                                        ? "Email Address"
                                        : "البريد الالكتروني",
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
                                    prefixIcon:
                                        Icon(Icons.phone_android, size: 22),
                                    hintText: globals.loc == "en"
                                        ? "Phone No."
                                        : "رقم التواصل",
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
                            Text(
                                globals.loc == "en"
                                    ? "Type of Business"
                                    : "نوع العميل",
                                style: TextStyle(fontSize: 20)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: globals.loc == 'en'
                                            ? 'Boutique'
                                            : 'بوتيك',
                                        groupValue: group,
                                        onChanged: (value) {
                                          setState(() {
                                            group = value;
                                          });
                                        }),
                                    Text(
                                        globals.loc == 'en'
                                            ? 'Boutique'
                                            : 'بوتيك',
                                        style: TextStyle(fontSize: 20))
                                  ],
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: globals.loc == 'en'
                                            ? 'Designer'
                                            : 'مصمم',
                                        groupValue: group,
                                        onChanged: (value) {
                                          setState(() {
                                            group = value;
                                          });
                                        }),
                                    Text(
                                        globals.loc == 'en'
                                            ? 'Designer'
                                            : 'مصمم',
                                        style: TextStyle(fontSize: 20))
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                                globals.loc == "en"
                                    ? "Categories of your business"
                                    : "مجال العمل",
                                style: TextStyle(fontSize: 20)),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: complains.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value:complains[index].ischeck ,
                                        
                                        onChanged: (value) {
                                          setState(() {
                                            groupcat += complains[index].id.toString();
                                            complains[index].ischeck = value;
                                          });
                                        }),
                                    Text(complains[index].name,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ))
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                                style: TextStyle(fontSize: 20),
                                controller: notes,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.note, size: 22),
                                    hintText: globals.loc == "en"
                                        ? "Notes"
                                        : "الملاحظات",
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
                            Text(globals.loc == 'en'
                                ? 'Craft Team will contact you after filling out the form to complete the registration procedures'
                                : 'فريق كرافت سوف يقوم بتواصل معكم بعد تعبئة النموذج لأكمال اجراءات التسجيل '),
                            SizedBox(height: 10),
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
                                            shape: RoundedRectangleBorder(),
                                            color: yellow,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 15),
                                            child: Text(
                                              globals.loc == "en"
                                                  ? 'Join us'
                                                  : 'انضم الينا',
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

String cat = "0";
for(int i=0 ; i <complains.length ; i++){
  if(complains[i].ischeck == true)
     cat += "," + complains[i].id.toString();
}


                                                String soap =
                                                    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <JoinUs xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
     
      <Email>${email.text}</Email>
      <Name>${name.text}</Name>
      <Phone>${phone.text}</Phone>
      <City>${city.text}</City>
      <Address>${address.text}</Address>
      <Brand>${brand.text}</Brand>
      <Date>${intl.DateFormat('MM-dd-yyyy').format(current).toString()}</Date>

      <BissType>$group</BissType>
      <Category>$cat</Category>
      <Notes>${notes.text}</Notes>

    </JoinUs>
  </soap:Body>
</soap:Envelope>''';

                                                http.Response responseUpdate =
                                                    await http
                                                        .post(
                                                            'https://craftapp.net/services/CraftWebService.asmx',
                                                            headers: {
                                                              "SOAPAction":
                                                                  "http://Craft.WS/JoinUs",
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
                                                String json =
                                                    parse(responseUpdate.body)
                                                        .getElementsByTagName(
                                                            'JoinUsResult')[0]
                                                        .text;
                                                final decoded =
                                                    jsonDecode(json);
                                                print(responseUpdate.body);
                                                setState(() {
                                                  load = false;
                                                });
                                                if (decoded == '-1') {
                                                 sms='خطأ غير معروف';
                                                } else {
                                                    Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => WillPopScope(
                                                                                        onWillPop: () async => false,
                                                                                        child: Home(index: 0),
                                                                                      )));
                                                }
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
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
  final int id;
  final String name;
   bool ischeck;

  Complain({this.id, this.name, this.ischeck});
}
