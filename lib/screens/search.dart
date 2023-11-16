import 'package:crafts/core/color.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/search_result.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';


class Search extends StatefulWidget {
  final String subID;

  Search({@required this.subID});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool loading = false;
  TextEditingController search = new TextEditingController();
  List<RecentWidget> recents = <RecentWidget>[];
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    await getRecents();
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

  Future<void> getRecents() async {
    recents = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetRecentSearch xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetRecentSearch>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetRecentSearch",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetRecentSearchResult')[0]
        .text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      recents.add(RecentWidget(
        id: decoded[i]['ID'],
        title: decoded[i]['Title'],
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
          body: Container(
            child: Column(children: [
             SizedBox(
                                         height: MediaQuery.of(context).padding.top + 10,

                ),
                Header(),
                  Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 15),
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
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 20),
                                    controller: search,
                                    textInputAction: TextInputAction.search,
                                    onFieldSubmitted: (value) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SearchResult(
                                                  query: value,
                                                  subID: widget.subID)));
                                    },
                                    decoration: InputDecoration(
                                      icon: Icon(CupertinoIcons.search),
                                      errorStyle: TextStyle(color: Colors.red),
                                      contentPadding: const EdgeInsets.all(0),
                                      hintText:
                                          globals.loc == 'en' ? 'Search' : 'بحث',
                                      hintStyle: TextStyle(fontSize: 22),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          borderSide: BorderSide.none),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  globals.loc == 'en'
                                      ? 'Recent Searches'
                                      : 'عمليات البحث الأخيرة',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 22)),
                              SizedBox(height: 15),
                              loading
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                yellow),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) =>
                                          recents[index],
                                      itemCount: recents.length,
                                    )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
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

class RecentWidget extends StatefulWidget {
  final String id;
  final String title;
  RecentWidget({@required this.id, @required this.title});
  @override
  _RecentWidgetState createState() => _RecentWidgetState();
}

class _RecentWidgetState extends State<RecentWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SearchResult(query: widget.title, subID: '0')));
      },
      child: Container(
        decoration: BoxDecoration(),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(Icons.history),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(widget.title, style: TextStyle(fontSize: 20),),
            )
          ],
        ),
      ),
    );
  }
}
