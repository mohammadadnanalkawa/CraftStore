import 'package:crafts/core/color.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/order_details.dart';
import 'package:crafts/screens/return_details.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<NotifyWidget> notify = <NotifyWidget>[];
  bool active = false;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    loadData();
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

  void loadData() async {
    setState(() {
      loading = true;
    });
    await getActive();
    await getNotifications();
    setState(() {
      loading = false;
    });
  }

  Future<void> getActive() async {
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetNotificationStatus xmlns="http://Craft.WS/">
      <ClientID>${globals.user.id}</ClientID>
    </GetNotificationStatus>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetNotificationStatus",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetNotificationStatusResult')[0]
        .text;
    final decoded = jsonDecode(json);
    active = decoded == 1 ? true : false;
  }

  Future<void> getNotifications() async {
    notify = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetClientNotifications xmlns="http://Craft.WS/">
      <ClientID>${globals.user.id}</ClientID>
    </GetClientNotifications>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetClientNotifications",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetClientNotificationsResult')[0]
        .text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      notify.add(NotifyWidget(
        id: decoded[i]['ID'],
        title: decoded[i]['Title'],
        body: decoded[i]['Body'],
        type: decoded[i]['Type'],
        icon: decoded[i]['Icon'],
        date: decoded[i]['Date'],
        read: decoded[i]['readflag'],
        ref: decoded[i]['ReferanceID'],
      ));
    }
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
            : Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 10,
                ),
                Header(),
                Divider(),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: 26,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  globals.loc == 'en'
                                      ? 'Notifications'
                                      : 'التنبيهات',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              CupertinoSwitch(
                                  value: active,
                                  onChanged: (value) {
                                    setState(() {
                                      active = value;
                                    });
                                    String soapActive =
                                        '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <EnableNotifications xmlns="http://Craft.WS/">
      <ClientID>${globals.user.id}</ClientID>
      <Status>${active == false ? 0 : 1}</Status>
    </EnableNotifications>
  </soap:Body>
</soap:Envelope>''';
                                    http.post(
                                        'https://craftapp.net/services/CraftWebService.asmx',
                                        headers: {
                                          "SOAPAction":
                                              "http://Craft.WS/EnableNotifications",
                                          "Content-Type":
                                              "text/xml;charset=UTF-8",
                                        },
                                        body: utf8.encode(soapActive),
                                        encoding: Encoding.getByName("UTF-8"));
                                  })
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(),
                        Expanded(
                            child: ListView.separated(
                          itemBuilder: (context, index) => notify[index],
                          itemCount: notify.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 0,
                            thickness: 1.0,
                          ),
                        )),
                      ],
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

class NotifyWidget extends StatefulWidget {
  final String id;
  final String title;
  final String body;
  final String icon;
  final String type;
  final String date;
  final String read;
  final String ref;
  NotifyWidget(
      {@required this.title,
      @required this.date,
      @required this.read,
      @required this.ref,
      @required this.type,
      @required this.body,
      @required this.icon,
      @required this.id});
  @override
  _NotifyWidgetState createState() => _NotifyWidgetState();
}

class _NotifyWidgetState extends State<NotifyWidget> {
  String read;
  @override
  void initState() {
    read = widget.read;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (read == 'False') {
          setState(() {
            read = 'True';
          });
          String soapRead = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ReadNotification xmlns="http://Craft.WS/">
      <NotificationID>${widget.id}</NotificationID>
    </ReadNotification>
  </soap:Body>
</soap:Envelope>''';
          http.post('https://craftapp.net/services/CraftWebService.asmx',
              headers: {
                "SOAPAction": "http://Craft.WS/ReadNotification",
                "Content-Type": "text/xml;charset=UTF-8",
              },
              body: utf8.encode(soapRead),
              encoding: Encoding.getByName("UTF-8"));

         
        }
         if (widget.type == 'Return') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReturnDetails(id: widget.ref)));
          }
          else   if (widget.type == 'Order') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetails(id: widget.ref)));
          }
      },
      child: Container(
        decoration: BoxDecoration(
            color: read == 'False' ? Colors.grey[200] : Colors.transparent),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
        child: Row(
          children: [
            Image.asset(
              'assets/noti_${widget.icon}.png',
              height: 35,
              width: 35,
              fit: BoxFit.fill,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20),
                    Text(
                      widget.date,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(
                  height: 7.5,
                ),
                Text(widget.body, style: TextStyle(fontSize: 17))
              ],
            ))
          ],
        ),
      ),
    );
  }
}
