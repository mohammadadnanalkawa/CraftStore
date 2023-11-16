import 'dart:async';

import 'package:crafts/core/color.dart';
import 'package:crafts/helpers/wrapper.dart';
import 'package:crafts/screens/checkout_error.dart';
import 'package:crafts/screens/contact_us.dart';
import 'package:crafts/screens/landing_page.dart';
import 'package:crafts/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:crafts/core/globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool result = await hasLanguage();
  if (result == false) {
    await addStringToSF();
    globals.loc = 'ar';
  } else {
    globals.loc = await getStringValuesSF();
  }
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}

Future<String> getStringValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String stringValue = prefs.getString('Language');
  return stringValue;
}

Future<void> addStringToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('Language', "ar");
}

Future<bool> hasLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool checkValue = prefs.containsKey('Language');
  return checkValue;
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crafts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'MainFont',
        primarySwatch: themeYellow,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
      ),
      home: Wrapper(),
    );
  }
}
