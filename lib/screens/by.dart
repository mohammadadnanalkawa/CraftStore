import 'package:crafts/core/color.dart';
import 'package:crafts/core/hex_color.dart';
import 'package:crafts/screens/favproduct.dart';
import 'package:crafts/screens/item_list_one.dart';
import 'package:crafts/screens/vendor_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/screens/search.dart';

class By extends StatefulWidget {
  @override
  _ByState createState() => _ByState();
}

class _ByState extends State<By> {
  List<ByWidget> byWid = <ByWidget>[];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    getByList();
  }

  void getByList() async {
    byWid = [];
    setState(() {
      loading = true;
    });
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetByList xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id != '0' ? globals.user.id : globals.loc}</CustomerID>
    </GetByList>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetByList",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetByListResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      byWid.add(ByWidget(
        id: decoded[i]['ID'],
        color: HexColor(decoded[i]['Color']),
        subTitle: decoded[i]['Brief'],
        title: decoded[i]['Name'],
        type: decoded[i]['Type'],
        image: decoded[i]['Image'],
        profile: decoded[i]['Profile'],
      ));
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: loading
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
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 30,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                globals.loc == 'en' ? 'BY' : 'بواسطة',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 7.5),
                              Image.asset(
                                'assets/by.png',
                                height: 25,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Search(
                                          subID: '0',
                                        )));
                          },
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Icon(
                              CupertinoIcons.search,
                              size: 26,
                            ),
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
                                    builder: (context) => FavProduct()));
                          },
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Icon(
                              CupertinoIcons.heart,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemBuilder: (context, index) => byWid[index],
                    itemCount: byWid.length,
                  )),
                ],
              ),
            ),
    );
  }
}

class ByWidget extends StatefulWidget {
  final String id;
  final String title;
  final String subTitle;
  final Color color;
  final String type;
  final String image;
  final String profile;

  ByWidget(
      {@required this.color,
      @required this.subTitle,
      @required this.title,
      @required this.id,
      @required this.type,
      @required this.image,
      @required this.profile});
  @override
  _ByWidgetState createState() => _ByWidgetState();
}

class _ByWidgetState extends State<ByWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () {
              if (widget.profile == '1') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VendorList(
                              byName: widget.title,
                              byID: widget.id,
                              filter: '0',
                              bylist: null,
                              from: '',
                              to: '',
                              sortSelected: '',
                              sub1: null,
                              sub2: null,
                              tagList: null,
                              mainCat: null,
                            )));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ItemListOne(
                              byName: widget.title,
                              byID: widget.id,
                              type: '0',
                              bylist: null,
                              filter: '0',
                              from: '',
                              to: '',
                              mainCat: null,
                              sortSelected: '',
                              sub1: null,
                              sub2: null,
                              tagList: null,
                            )));
              }
            },
            child: widget.type != 'True'
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                    decoration: BoxDecoration(color: widget.color),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 7.5),
                              Text(widget.subTitle,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Icon(
                          globals.loc == 'en'
                              ? CupertinoIcons.chevron_right
                              : CupertinoIcons.chevron_left,
                          size: 18,
                        )
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(),
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                /*  borderRadius: BorderRadius.circular(12), */
                                child: Image.network(
                                  widget.image,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                                  },
                                  fit: BoxFit.fill,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          )
        ]));
  }
}
