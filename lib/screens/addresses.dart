import 'package:crafts/core/color.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/new_address.dart';
import 'package:crafts/screens/update_address.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';


class Addresses extends StatefulWidget {
  @override
  _AddressesState createState() => _AddressesState();
}

class _AddressesState extends State<Addresses> {
  List<AddressWidget> addresses = <AddressWidget>[];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    await getLocations();
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

  Future<void> getLocations() async {
    addresses = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetMyLocations xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetMyLocations>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetMyLocations",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetMyLocationsResult')[0]
        .text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      addresses.add(AddressWidget(
        id: decoded[i]['ID'],
        title: decoded[i]['Title'],
        phone: decoded[i]['Phone'],
        address: decoded[i]['Address'],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
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
                    child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBarOne(
                        implyLeading: true,
                        text: globals.loc == 'en' ? 'Locations' : 'العناوين',
                        press: () {
                          Navigator.pop(context);
                        },
                        textColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => addresses[index],
                          itemCount: addresses.length,
                          separatorBuilder: (context, index) => Divider(
                            thickness: 1.0,
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1.0,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewAddress(
                                        from: "0",
                                        name: '',
                                        email: '',
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                globals.loc == 'en'
                                    ? 'Add new address'
                                    : 'اضافة عنوان جديد',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 1.0,
                      )
                    ],
                  ),
                ))
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

class AddressWidget extends StatefulWidget {
  final String id;
  final String title;
  final String phone;
  final String address;
  AddressWidget(
      {@required this.id,
      @required this.title,
      @required this.phone,
      @required this.address});
  @override
  _AddressWidgetState createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  bool load = false;
  @override
  Widget build(BuildContext context) {
    return load
        ? Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(yellow),
            ),
          )
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(
                        height: 7.5,
                      ),
                      Text(widget.phone, style: TextStyle(fontSize: 18)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(widget.address, style: TextStyle(fontSize: 18))
                    ],
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UpdateAddress(id: widget.id)));
                  },
                  child: Container(
                      decoration: BoxDecoration(), child: Icon(Icons.edit)),
                ),
                SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      load = true;
                    });
                    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <DeleteLocation xmlns="http://Craft.WS/">
      <LocationID>${widget.id}</LocationID>
    </DeleteLocation>
  </soap:Body>
</soap:Envelope>''';
                    http.Response responseUpdate = await http
                        .post(
                            'https://craftapp.net/services/CraftWebService.asmx',
                            headers: {
                              "SOAPAction": "http://Craft.WS/DeleteLocation",
                              "Content-Type": "text/xml;charset=UTF-8",
                            },
                            body: utf8.encode(soap),
                            encoding: Encoding.getByName("UTF-8"))
                        .then((onValue) {
                      return onValue;
                    });
                    setState(() {
                      load = false;
                    });
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Addresses()));
                  },
                  child: Container(
                      decoration: BoxDecoration(),
                      child: Icon(CupertinoIcons.trash)),
                )
              ],
            ),
          );
  }
}
