import 'dart:async';
import 'dart:io';
import 'package:crafts/helpers/linking.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loccheck;
import 'package:crafts/core/color.dart';
import 'package:crafts/helpers/user.dart';
import 'package:crafts/screens/activate.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/landing_page.dart';
import 'package:crafts/screens/login.dart';
import 'package:crafts/screens/notifications.dart';
import 'package:crafts/screens/order_details.dart';
import 'package:crafts/screens/return_details.dart';
import 'package:crafts/screens/splash_screen.dart';
import 'package:crafts/screens/welcome.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:location_permissions/location_permissions.dart';

User user;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
BuildContext notifyContext;
bool _isConfigured = false;
Future onSelectNotify(String payload) async {
  var data = json.decode(payload);
  // print('Click');
  print(data['notificationtype']);
  String idnot = data['ID'];
  if (data['notificationtype'] == 'Payment') {
    Navigator.push(notifyContext,
        MaterialPageRoute(builder: (context) => ReturnDetails(id: idnot)));
  } else if (data['notificationtype'] == 'Order') {
    Navigator.push(
        notifyContext,
        MaterialPageRoute(
            builder: (context) => OrderDetails(
                  id: idnot,
                )));
  } else {
    Navigator.push(notifyContext,
        MaterialPageRoute(builder: (context) => Notifications()));
  }
}

Future _showNotificationWithDefaultSound(String title, String data) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    '0', 'your channel name', 'your channel description',
    playSound: true,
    importance: Importance.max,
    priority: Priority.high,
    //sound: RawResourceAndroidNotificationSound('notify')
  );
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, 'Craft App', '$title', platformChannelSpecifics, payload: data);
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print('Notification is received in background');
  var initializationAndroid = new AndroidInitializationSettings('ic_notify');
  var initializationIos = new IOSInitializationSettings();
  var initialization = new InitializationSettings(
      android: initializationAndroid, iOS: initializationIos);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initialization,
      onSelectNotification: onSelectNotify);
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    _showNotificationWithDefaultSound(
        '${data['title']}', json.encode(message['data']));
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> with WidgetsBindingObserver {
  bool gettingData = false;
  String dataactive = '';
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();

  Timer _timerLink;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(
        const Duration(seconds: 2),
        () {
          _dynamicLinkService.retrieveDynamicLink(notifyContext);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink.cancel();
    }
    super.dispose();
  }

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('Email');
    print(stringValue);
    return stringValue;
  }

  Future<String> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('Password');
    return stringValue;
  }

  Future<String> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('Name');
    return stringValue;
  }

  Future<String> getID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('ID');
    return stringValue;
  }

  Future<String> getPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('Phone');
    return stringValue;
  }

  Future<String> getType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('Type');
    return stringValue;
  }

  Future<String> getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('Image');
    return stringValue;
  }

  void loadData() async {
    setState(() {
      gettingData = true;
    });
    user = User(
      name: await getName(),
      email: await getEmail(),
      password: await getPassword(),
      id: await getID(),
      image: await getImage(),
      phone: await getPhone(),
      type: await getType(),
    );
    if (user.id != null) {
      globals.user = user;
    }
    setState(() {
      checkactive();
      gettingData = false;
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _showVersionDialog(context) async {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "تحديث جديد";
        String message = "تم اصدار تحديث جديد للتطبيق، يرجى التحديث الان";
        String btnLabel = "حدث الان";

        if (globals.loc == 'en') {
          title = "New Update Available";
          message =
              "There is a newer version of app available please update it now.";
          btnLabel = "Update Now";
        }

        return new AlertDialog(
          title: Text(
            title,
            textDirection:
                globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
          ),
          content: Text(
            message,
            textDirection:
                globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel, textAlign: TextAlign.center),
              onPressed: () => _launchURL(Platform.isIOS
                  ? 'https://apps.apple.com/us/app/craftapp/id1585417957'
                  : 'https://play.google.com/store/apps/details?id=com.codino.crafts'),
            ),
          ],
        );
      },
    );
  }

  versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  Future<void> checkactive() async {
    String sendval = "";
    if (globals.user != null) {
      sendval = globals.user.id;

      if (globals.user.type == '0') {
        String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <checkactive xmlns="http://Craft.WS/">
      <CustomerID>$sendval</CustomerID>
    </checkactive>
  </soap:Body>
</soap:Envelope>''';
        http.Response response = await http
            .post('https://craftapp.net/services/CraftWebService.asmx',
                headers: {
                  "SOAPAction": "http://Craft.WS/checkactive",
                  "Content-Type": "text/xml;charset=UTF-8",
                },
                body: utf8.encode(soap),
                encoding: Encoding.getByName("UTF-8"))
            .then((onValue) {
          return onValue;
        });
        print(response.body);
        String json = parse(response.body)
            .getElementsByTagName('checkactiveResult')[0]
            .text;
        final decoded = jsonDecode(json);
        setState(() {
          dataactive = decoded["active"];
          if (decoded["lang"] == 'ar' || decoded["lang"] == 'en')
            globals.loc = decoded["lang"];
          load = false;
        });
      } else {
        setState(() {
          dataactive = '2';
          load = false;
        });
      }
    }
  }

  void _loadingInitialData() async {
    await Future.delayed(Duration(seconds: 6)).then((v) {
      setState(() {
        gettingData = false;
      });
    });
  }

  bool load = true;
  loccheck.Location locationenable =
      loccheck.Location(); //explicit reference to the Location class
  Future _checkGpsfun() async {
    if (!await locationenable.serviceEnabled()) {
      locationenable.requestService();
    }
  }

  void location_permission() async {
    final PermissionStatus permission = await _getLocationPermission();
    if (permission == PermissionStatus.granted) {
      final position = await Geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      // Use the position to do whatever...
    }
  }

  Future<PermissionStatus> _getLocationPermission() async {
    final PermissionStatus permission = await LocationPermissions()
        .checkPermissionStatus(level: LocationPermissionLevel.location);

    if (permission != PermissionStatus.granted) {
      final PermissionStatus permissionStatus = await LocationPermissions()
          .requestPermissions(
              permissionLevel: LocationPermissionLevel.location);

      return permissionStatus;
    } else {
      return permission;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timerLink = new Timer(
        const Duration(seconds: 2),
        () {
          _dynamicLinkService.retrieveDynamicLink(notifyContext);
        },
      );
    });

    if (Platform.isIOS) {
      location_permission();
    }
    _checkGpsfun();
    var initializationAndroid = new AndroidInitializationSettings('ic_notify');
    var initializationIos = new IOSInitializationSettings();
    var initialization = new InitializationSettings(
        android: initializationAndroid, iOS: initializationIos);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initialization,
        onSelectNotification: onSelectNotify);
    loadData();
    _loadingInitialData();
    if (!_isConfigured) {
      Future.delayed(Duration(seconds: 0), () {
        _firebaseMessaging.configure(
          onMessage: (message) async {
            print(message);
            Platform.isAndroid
                ? _showNotificationWithDefaultSound(
                    '${message['data']['title']}', json.encode(message['data']))
                : message.containsKey('notification')
                    ? _showNotificationWithDefaultSound(
                        '${message['notification']['body']}',
                        json.encode(message))
                    : _showNotificationWithDefaultSound(
                        '${message['aps']['alert']['body']}',
                        json.encode(message));
          },
          onResume: (message) async {
            print(message);
            if (Platform.isAndroid) {
              onSelectNotify(json.encode(message['data']));
            } else {
              onSelectNotify(json.encode(message));
            }
            // _showNotificationWithDefaultSound(
            //     '${message['data']['title']}', json.encode(message['data']));
          },
          onLaunch: (message) async {
            print(message);
            if (Platform.isAndroid) {
              onSelectNotify(json.encode(message['data']));
            } else {
              onSelectNotify(json.encode(message));
            }
            // _showNotificationWithDefaultSound(
            //     '${message['data']['title']}', json.encode(message['data']));
          },
          onBackgroundMessage:
              Platform.isAndroid ? myBackgroundMessageHandler : null,
        );
        _isConfigured = true;
      });
    }
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    notifyContext = context;
    if (gettingData) {
      return Scaffold(
        body: Container(
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
        ),
      );
    } else {
      if (user.id == null) {
        //return Home();
        return SplashScreen();
      } else {
        if (dataactive == '1')
          return WillPopScope(onWillPop: () async => false, child: Welcome());
        else if (dataactive == '0')
          return WillPopScope(
              onWillPop: () async => false,
              child: Activate(
                user: globals.user,
              ));
        else if (dataactive == '2') {
          return WillPopScope(
              onWillPop: () async => false,
              child: Home(
                index: 0,
              ));
        } else if (dataactive == '3') {
          return WillPopScope(onWillPop: () async => false, child: Login());
        } else {
          return Scaffold(
            body: Container(
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
            ),
          );
        }
      }
    }
  }
}
