import 'dart:io';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:flutter/cupertino.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String image = '';
  bool loading = false;
  bool loadButton = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController name = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  String sms= "";
  

  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';
  bool upload = false;
  StorageUploadTask task;
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

  Future<void> _uploadFile(File file, String filename) async {
    setState(() {
      loading = true;
    });
    StorageReference storageReference;
    storageReference =
        FirebaseStorage.instance.ref().child("profiles/$filename");
    task = storageReference.putFile(file);
    var dowurl = await (await task.onComplete).ref.getDownloadURL();
    setState(() {
      image = dowurl.toString();
      loading = false;
    });
  }

  void loadData() async {
    setState(() {
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
    if (response.statusCode == 200) {
      print(response.body);
      String json =
          parse(response.body).getElementsByTagName('GetProfileResult')[0].text;
      final decoded = jsonDecode(json);
      setState(() {
        name.text = decoded['Name'];
        phone.text = decoded['Phone'];
        email.text = decoded['Email'];
        password.text = decoded['Password'];
        image = decoded['Photo'];
      });
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

  Future filePicker(BuildContext context) async {
    try {
      file = await FilePicker.getFile(type: FileType.image);
      if (file != null) {
        _uploadFile(file, fileName + DateTime.now().toIso8601String());
      }
    } on PlatformException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection:
            globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: Scaffold(
          key: _scaffoldKey,
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
              : Column(children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 10,
                  ),
                  Header(),
                  Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppBarOne(
                                implyLeading: true,
                                text: globals.loc == 'en'
                                    ? 'Edit Profile'
                                    : 'تعديل الحساب',
                                press: () {
                                  Navigator.pop(context);
                                },
                                textColor: Colors.black,
                                backgroundColor: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.center,
                                      child: image.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                filePicker(context);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(),
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  radius: 50,
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: Image.network(
                                                          image.replaceAll(
                                                              '?and?', '&'),
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.fill,
                                                          loadingBuilder: (BuildContext
                                                                  context,
                                                              Widget child,
                                                              ImageChunkEvent
                                                                  loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return Container(
                                                          height: 200,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      yellow),
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes
                                                                  : null,
                                                            ),
                                                          ),
                                                        );
                                                      })),
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                filePicker(context);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(),
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: AssetImage(
                                                      'assets/person.jpg'),
                                                  radius: 50,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Container(
                                                            height: 55,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[800]
                                                                    .withOpacity(
                                                                        0.8)),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .camera_alt_outlined,
                                                                  color: Colors
                                                                      .white),
                                                              Text(
                                                                  'تغيير الصورة',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14)),
                                                              SizedBox(
                                                                  height: 15)
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                    SizedBox(height: 30),
                                    TextFormField(
                                        style: TextStyle(fontSize: 22),
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
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 26),
                                            labelText: globals.loc == 'en'
                                                ? 'Name'
                                                : 'الاسم',
                                            isDense: true)),
                                    SizedBox(height: 15),
                                    TextFormField(
                                        style: TextStyle(fontSize: 22),
                                        controller: phone,
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
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 26),
                                            labelText: globals.loc == 'en'
                                                ? 'Mobile Number'
                                                : 'رقم الجوال',
                                            isDense: true)),
                                    SizedBox(height: 15),
                                    TextFormField(
                                        style: TextStyle(fontSize: 22),
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
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 26),
                                            labelText: globals.loc == 'en'
                                                ? 'Email'
                                                : 'البريد الالكتروني',
                                            isDense: true)),
                                    SizedBox(height: 15),
                                    TextFormField(
                                        controller: password,
                                        style: TextStyle(fontSize: 22),
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
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: TextStyle(
                                                color: Colors.black,
                                                fontSize: 26),
                                            labelText: globals.loc == 'en'
                                                ? 'Password'
                                                : 'كلمة المرور',
                                            isDense: true)),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        
                                        sms,
                                        style: TextStyle(color: Colors.red, fontSize: 22 ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      child: loadButton
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                        Color>(yellow),
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: RaisedButton(
                                                      elevation: 0,
                                                      shape:
                                                          RoundedRectangleBorder(),
                                                      color:
                                                          HexColor("#222222"),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 15,
                                                              horizontal: 15),
                                                      child: Text(
                                                        globals.loc == 'en'
                                                            ? 'Save'
                                                            : 'حفظ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 22),
                                                      ),
                                                      onPressed: () async {
                                                        if (_formKey
                                                            .currentState
                                                            .validate()) {
                                                          setState(() {
                                                            loadButton = true;
                                                          });
                                                          image =
                                                              image.replaceAll(
                                                                  '&', '?and?');
                                                          String soap =
                                                              '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <UpdateProfile xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <Photo>$image</Photo>
      <Name>${name.text}</Name>
      <Phone>${phone.text}</Phone>
      <Email>${email.text}</Email>
      <Password>${password.text}</Password>
    </UpdateProfile>
  </soap:Body>
</soap:Envelope>''';
                                                          http.Response
                                                              response =
                                                              await http
                                                                  .post(
                                                                      'https://craftapp.net/services/CraftWebService.asmx',
                                                                      headers: {
                                                                        "SOAPAction":
                                                                            "http://Craft.WS/UpdateProfile",
                                                                        "Content-Type":
                                                                            "text/xml;charset=UTF-8",
                                                                      },
                                                                      body: utf8
                                                                          .encode(
                                                                              soap),
                                                                      encoding:
                                                                          Encoding.getByName(
                                                                              "UTF-8"))
                                                                  .then(
                                                                      (onValue) {
                                                            return onValue;
                                                          });
                                                          String json = parse(
                                                                  response.body)
                                                              .getElementsByTagName(
                                                                  'UpdateProfileResult')[0]
                                                              .text;
                                                          final decoded =
                                                              jsonDecode(json);
                                                          setState(() {
                                                            loadButton = false;
                                                            if(decoded['Flag'] == '-1')
                                                            sms =  decoded["SMS"];
                                                            else
                                                            {
                                                                 Navigator.pop(
                                                                context);
                                                            Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Account()));
                                                         
                                                            }
                                                          });
                                                        /*   _scaffoldKey
                                                              .currentState
                                                              .showSnackBar(
                                                                  SnackBar(
                                                                      content:
                                                                          Text(
                                                                        decoded,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 15),
                                                                      ),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              4)))
                                                              .closed
                                                              .then((_) {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Account()));
                                                          }); */
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
        ));
  }
}
