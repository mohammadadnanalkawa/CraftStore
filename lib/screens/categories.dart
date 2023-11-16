import 'package:crafts/core/color.dart';
import 'package:crafts/screens/favproduct.dart';
import 'package:crafts/screens/item_list_two.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/category_item_list.dart';

class Categories extends StatefulWidget {
  final String activeid;

  Categories({@required this.activeid});
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories>
    with SingleTickerProviderStateMixin {
  List<CategoryWidget> categoryWid = <CategoryWidget>[];
  List<Category> subby = <Category>[];

  TabController _tabController;
  List<Category> _tabs = <Category>[];
  bool loading = false;
  bool load = false;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    await getMain();
    if (_tabs.isNotEmpty) {
      if (widget.activeid == '0')
        await getSub(_tabs[0].id);
      else
        await getSub(widget.activeid);
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getMain() async {
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetMainCategory xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id != '0' ? globals.user.id : globals.loc}</CustomerID>
    </GetMainCategory>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetMainCategory",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetMainCategoryResult')[0]
        .text;
    final decoded = jsonDecode(json);
    var activeindex = 0;
    for (int i = 0; i < decoded.length; i++) {
      if (widget.activeid == decoded[i]['ID']) activeindex = i;

      _tabs.add(Category(
          id: decoded[i]['ID'],
          name: decoded[i]['Title'],
          photo: decoded[i]['Photo']));
    }
    if (widget.activeid == '0')
      _tabController =
          new TabController(length: _tabs.length, vsync: this, initialIndex: 0);
    else
      _tabController = new TabController(
          length: _tabs.length, vsync: this, initialIndex: activeindex);
  }

  Future<void> getSub(String id) async {
    categoryWid = [];

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetSubCategoryLevel1V2 xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id != '0' ? globals.user.id : globals.loc}</CustomerID>
      <ParentID>$id</ParentID>
    </GetSubCategoryLevel1V2>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetSubCategoryLevel1V2",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetSubCategoryLevel1V2Result')[0]
        .text;
    final decoded = jsonDecode(json);
    categoryWid = [];

    for (int i = 0; i < decoded.length; i++) {
      subby = [];

      for (int j = 0; j < decoded[i]["Sub"].length; j++) {
        subby.add(Category(
            id: decoded[i]["Sub"][j]['ID'],
            name: decoded[i]["Sub"][j]['Title'],
            photo: ''));
      }

      categoryWid.add(CategoryWidget(
        subby: subby,
        title: decoded[i]['Title'],
        subid1: decoded[i]['ID'],
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
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
                          child: Text(
                            globals.loc == 'en' ? 'Categories' : 'التصنيفات',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'MainFont'),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Search(subID: '0')));
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
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(),
                    child: TabBar(
                      isScrollable: true,
                      controller: _tabController,
                      // give the indicator a decoration (color and border radius)
                      indicator: BoxDecoration(
                        color: yellow,
                      ),
                      labelStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MainFont'),
                      unselectedLabelStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MainFont'),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey[600],
                      tabs: _tabs.map((tab) {
                        return Tab(
                          text: tab.name,
                        );
                      }).toList(),
                      onTap: (int i) async {
                        setState(() {
                          load = true;
                        });
                        await getSub(_tabs[i].id);
                        setState(() {
                          load = false;
                        });
                      },
                    ),
                  ),
                  load
                      ? Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  new AlwaysStoppedAnimation<Color>(yellow),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                          itemBuilder: (context, index) => categoryWid[index],
                          itemCount: categoryWid.length,
                        )),
                ],
              ),
            ),
    );
  }
}

class CategoryWidget extends StatefulWidget {
  final String subid1;
  List<Category> subby = <Category>[];
  final String title;
  CategoryWidget(
      {@required this.title, @required this.subby, @required this.subid1});
  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7.5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: isExpanded ? yellow : Colors.grey[200],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 22, fontFamily: 'MainFont'),
                  ),
                  Icon(
                    isExpanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    size: 18,
                  )
                ],
              ),
            ),
          ),
          isExpanded ? SizedBox(height: 10) : Container(height: 0, width: 0),
          isExpanded
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CategoryItemList(
                                byName: widget.title,
                                byID: '0',
                                mainID: widget.subid1,
                                type: '0',
                                filter: '0',
                                bylist: null,
                                from: '',
                                to: '',
                                sortSelected: '',
                                sub1: null,
                                sub2: null,
                                tagList: null,
                                mainCat: null,
                                 may: '0')));
                  },
                  child: Container(
                    decoration: BoxDecoration(),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          globals.loc == 'en' ? 'Show All' : 'عرض الكل',
                          style: TextStyle(
                              fontSize: 20,
                              color: yellow,
                              fontFamily: 'MainFont'),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: yellow,
                        )
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 0,
                  width: 0,
                ),
          isExpanded
              ? ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7.5),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoryItemList(
                                      byName: widget.title,
                                      byID: widget.subby[index].id,
                                      mainID: widget.subid1,
                                      type: '0',
                                      filter: '0',
                                      bylist: null,
                                      from: '',
                                      to: '',
                                      sortSelected: '',
                                      sub1: null,
                                      sub2: null,
                                      tagList: null,
                                      mainCat: null,
                                       may: '0')));
                        },
                        child: Text(
                          widget.subby[index].name,
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'MainFont'),
                        ),
                      ),
                    );
                  },
                  itemCount: widget.subby.length,
                )
              : Container(height: 0, width: 0)
        ],
      ),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String photo;
  Category({this.id, this.name, @required this.photo});
}
