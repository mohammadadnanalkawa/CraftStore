import 'package:crafts/core/color.dart';
import 'package:crafts/screens/category_item_list.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/item_list_one.dart';
import 'package:crafts/screens/vendor_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/helpers/catdata.dart';

class filterpage extends StatefulWidget {
  final String type;
  final String byID;
  final String byName;
  final String mainID;
  final String type2;

  filterpage(
      {@required this.type,
      @required this.type2,
      @required this.byID,
      @required this.byName,
      @required this.mainID});
  @override
  _filterpage createState() => _filterpage();
}

class _filterpage extends State<filterpage>
    with SingleTickerProviderStateMixin {
  List<Category> main = <Category>[];
  List<Category> level1 = <Category>[];
  List<Category> level2 = <Category>[];
  List<Category> by = <Category>[];
  List<Category> tag = <Category>[];
  BuildContext parentContext;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String counter = '';
  String subID;
  String sort;
  Category mainCat, sub1, sub2, bylist, tagList;
  TextEditingController from = new TextEditingController();
  TextEditingController to = new TextEditingController();
  String sortSelected = '';
  bool loadFilter = false;
  bool loadMain = true;
  bool loadSub1 = false;
  bool loadSub2 = false;
  bool loadBy = false;
  bool loadTag = false;

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

  Future<void> getMainCat() async {
    main = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetMainCategoryddl xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetMainCategoryddl>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetMainCategoryddl",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetMainCategoryddlResult')[0]
        .text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      main.add(Category(id: decoded[i]['ID'], name: decoded[i]['Title']));
    }
    if (main.isNotEmpty) {
      mainCat = main[0];
    } else {
      mainCat = null;
    }
  }

  Future<void> getSub1(String id) async {
    level1 = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetSubCategoryLevel1ddl xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <ParentID>$id</ParentID>
    </GetSubCategoryLevel1ddl>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetSubCategoryLevel1ddl",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetSubCategoryLevel1ddlResult')[0]
        .text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      level1.add(Category(id: decoded[i]['ID'], name: decoded[i]['Title']));
    }
    if (level1.isNotEmpty) {
      sub1 = level1[0];
    } else {
      sub1 = null;
    }
  }

  Future<void> getSub2(String id) async {
    level2 = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetSubCategoryLevel2ddl xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <ParentID>$id</ParentID>
    </GetSubCategoryLevel2ddl>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetSubCategoryLevel2ddl",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetSubCategoryLevel2ddlResult')[0]
        .text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      level2.add(Category(id: decoded[i]['ID'], name: decoded[i]['Title']));
    }
    if (level2.isNotEmpty) {
      sub2 = level2[0];
    } else {
      sub2 = null;
    }
  }

  Future<void> getBy(String mainid, String subid1, String subid2) async {
    by = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetSubByddl xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <MainCat>$mainid</MainCat>
      <SubCat1>$subid1</SubCat1>
      <SubCat2>$subid2</SubCat2>
    </GetSubByddl>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetSubByddl",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetSubByddlResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      by.add(Category(id: decoded[i]['ID'], name: decoded[i]['Title']));
    }
    if (by.isNotEmpty) {
      bylist = by[0];
    } else {
      bylist = null;
    }
  }

  Future<void> getTag() async {
    tag = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetTags xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetTags>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetTags",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetTagsResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      tag.add(Category(id: decoded[i]['ID'], name: decoded[i]['Title']));
    }
    if (tag.isNotEmpty) {
      tagList = tag[0];
    } else {
      tagList = null;
    }
  }

  void loadFilterData() async {
    await getMainCat();
    await getTag();
    if (main.isNotEmpty) {
      await getSub1(main[0].id);
    }
    if (level1.isNotEmpty) {
      await getSub2(level1[0].id);
    }
    if (main.isNotEmpty && level1.isNotEmpty && level2.isNotEmpty) {
      if (level2[0].id != "0")
        await getBy('0', '0', level2[0].id);
      else if (level1[0].id != "0")
        await getBy('0', level1[0].id, '0');
      else
        await getBy(main[0].id, '0', '0');
    }

    setState(() {
      loadMain = false;
    });

    setState(() {
      loadMain = false;
    });
  }

  @override
  void initState() {
    super.initState();

    loadData();
    loadFilterData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadData() async {
    setState(() {
      loadMain = true;
    });
  }

  void filterProduct() async {
    if (widget.type2 == '0') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryItemList(
                    byID: widget.byID,
                    byName: '',
                    mainID: widget.mainID,
                    type: widget.type,
                    filter: '1',
                    bylist: bylist,
                    from: from.text,
                    to: to.text,
                    sortSelected: sortSelected,
                    sub1: sub1,
                    sub2: sub2,
                    tagList: tagList,
                    mainCat: mainCat,
                    may: '0',
                  )));
    }
    else  if (widget.type2 == '1') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VendorList(
                    byID: widget.byID,
                    byName:'',
                   
                    filter: '1',
                    bylist: bylist,
                    from: from.text,
                    to: to.text,
                    sortSelected: sortSelected,
                    sub1: sub1,
                    sub2: sub2,
                    tagList: tagList,
                    mainCat: mainCat,
                  )));
   
    }

  

    else  if (widget.type2 == '2') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ItemListOne(
                    byID: widget.byID,
                    byName: '',
                   type: widget.type,
                    filter: '1',
                    bylist: bylist,
                    from: from.text,
                    to: to.text,
                    sortSelected: sortSelected,
                    sub1: sub1,
                    sub2: sub2,
                    tagList: tagList,
                    mainCat: mainCat,
                  )));
   
    }
    
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          body: loadMain
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
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
                  height: MediaQuery.of(context).size.height,
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.4)),
                  padding: EdgeInsets.only(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      top: MediaQuery.of(parentContext).padding.top + 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: globals.loc == 'en'
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(),
                              child: Icon(
                                CupertinoIcons.multiply,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          globals.loc == 'en' ? 'Category' : 'القسم',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (mainCat != null) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Directionality(
                                          textDirection: globals.loc == 'en'
                                              ? TextDirection.ltr
                                              : TextDirection.rtl,
                                          child: Dialog(
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              itemCount: main.length,
                                              separatorBuilder:
                                                  (context, index) => Divider(),
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  onTap: () async {
                                                    Navigator.pop(context);

                                                    setState(() {
                                                      loadSub1 = true;
                                                      loadSub2 = true;
                                                      loadBy = true;
                                                      mainCat = main[index];
                                                    });

                                                    await getSub1(
                                                        main[index].id);
                                                    await getBy(
                                                        mainCat == null
                                                            ? '0'
                                                            : mainCat.id,
                                                        sub1 == null
                                                            ? '0'
                                                            : sub1.id,
                                                        sub2 == null
                                                            ? '0'
                                                            : sub2.id);

                                                    setState(() {
                                                      loadBy = false;
                                                      loadSub1 = false;
                                                      loadSub2 = false;
                                                    });
                                                  },
                                                  title: Text(
                                                    main[index].name,
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      mainCat == null ? '' : mainCat.name,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Icon(
                              globals.loc == 'en'
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              size: 18,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        loadSub1
                            ? Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      new AlwaysStoppedAnimation<Color>(yellow),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (sub1 != null) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Directionality(
                                                textDirection:
                                                    globals.loc == 'en'
                                                        ? TextDirection.ltr
                                                        : TextDirection.rtl,
                                                child: Dialog(
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount: level1.length,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);

                                                          setState(() {
                                                            loadSub2 = true;
                                                            loadBy = true;
                                                            sub1 =
                                                                level1[index];
                                                          });

                                                          await getSub2(
                                                              level1[index].id);
                                                          await getBy(
                                                              mainCat == null
                                                                  ? '0'
                                                                  : mainCat.id,
                                                              sub1 == null
                                                                  ? '0'
                                                                  : sub1.id,
                                                              sub2 == null
                                                                  ? '0'
                                                                  : sub2.id);
                                                          setState(() {
                                                            loadBy = false;
                                                            loadSub2 = false;
                                                          });
                                                        },
                                                        title: Text(
                                                            level1[index].name,
                                                            style: TextStyle(
                                                                fontSize: 16)),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            sub1 == null ? '' : sub1.name,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    globals.loc == 'en'
                                        ? Icons.chevron_left
                                        : Icons.chevron_right,
                                    size: 18,
                                  )
                                ],
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        loadSub2
                            ? Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      new AlwaysStoppedAnimation<Color>(yellow),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (sub2 != null) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Directionality(
                                                textDirection:
                                                    globals.loc == 'en'
                                                        ? TextDirection.ltr
                                                        : TextDirection.rtl,
                                                child: Dialog(
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount: level2.length,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            loadBy = true;
                                                            sub2 =
                                                                level2[index];
                                                          });

                                                          await getBy(
                                                              mainCat == null
                                                                  ? '0'
                                                                  : mainCat.id,
                                                              sub1 == null
                                                                  ? '0'
                                                                  : sub1.id,
                                                              sub2 == null
                                                                  ? '0'
                                                                  : sub2.id);
                                                          setState(() {
                                                            loadBy = false;
                                                          });
                                                        },
                                                        title: Text(
                                                            level2[index].name,
                                                            style: TextStyle(
                                                                fontSize: 16)),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            sub2 == null ? '' : sub2.name,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    globals.loc == 'en'
                                        ? Icons.chevron_left
                                        : Icons.chevron_right,
                                    size: 18,
                                  )
                                ],
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        loadBy
                            ? Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      new AlwaysStoppedAnimation<Color>(yellow),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (bylist != null) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Directionality(
                                                textDirection:
                                                    globals.loc == 'en'
                                                        ? TextDirection.ltr
                                                        : TextDirection.rtl,
                                                child: Dialog(
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount: by.length,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);

                                                          setState(() {
                                                            bylist = by[index];
                                                          });
                                                        },
                                                        title: Text(
                                                            by[index].name,
                                                            style: TextStyle(
                                                                fontSize: 16)),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            bylist == null ? '' : bylist.name,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    globals.loc == 'en'
                                        ? Icons.chevron_left
                                        : Icons.chevron_right,
                                    size: 18,
                                  )
                                ],
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        loadTag
                            ? Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      new AlwaysStoppedAnimation<Color>(yellow),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (tagList != null) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Directionality(
                                                textDirection:
                                                    globals.loc == 'en'
                                                        ? TextDirection.ltr
                                                        : TextDirection.rtl,
                                                child: Dialog(
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount: tag.length,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);

                                                          setState(() {
                                                            tagList =
                                                                tag[index];
                                                          });
                                                        },
                                                        title: Text(
                                                            tag[index].name,
                                                            style: TextStyle(
                                                                fontSize: 16)),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            tagList == null ? '' : tagList.name,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    globals.loc == 'en'
                                        ? Icons.chevron_left
                                        : Icons.chevron_right,
                                    size: 18,
                                  )
                                ],
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          globals.loc == 'en' ? 'Price' : 'السعر',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                  controller: from,
                                      keyboardType: TextInputType.number,

                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      hintStyle: TextStyle(fontSize: 13),
                                      hintText: globals.loc == 'en'
                                          ? 'From'
                                          : 'الأدنى',
                                      isDense: true)),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.remove, size: 18),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextFormField(
                                  controller: to,
                                      keyboardType: TextInputType.number,

                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      hintStyle: TextStyle(fontSize: 13),
                                      hintText:
                                          globals.loc == 'en' ? 'To' : 'الأعلى',
                                      isDense: true)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          globals.loc == 'en' ? 'Sort By' : 'الترتيب حسب',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: 35,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    sortSelected = '1';
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.5, horizontal: 7.5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: sortSelected == '1'
                                              ? Colors.transparent
                                              : Colors.black),
                                      color: sortSelected == '1'
                                          ? Color(0xFFE7BB1F)
                                          : Colors.transparent),
                                  child: Text(
                                      globals.loc == 'en'
                                          ? 'Most Requested'
                                          : 'الأكثر مبيعا',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: sortSelected == '1'
                                              ? Colors.white
                                              : Colors.black)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    sortSelected = '2';
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.5, horizontal: 7.5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: sortSelected == '2'
                                              ? Colors.transparent
                                              : Colors.black),
                                      color: sortSelected == '2'
                                          ? Color(0xFFE7BB1F)
                                          : Colors.transparent),
                                  child: Text(
                                      globals.loc == 'en' ? 'Newest' : 'الأحدث',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: sortSelected == '2'
                                              ? Colors.white
                                              : Colors.black)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    sortSelected = '3';
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.5, horizontal: 7.5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: sortSelected == '3'
                                              ? Colors.transparent
                                              : Colors.black),
                                      color: sortSelected == '3'
                                          ? Color(0xFFE7BB1F)
                                          : Colors.transparent),
                                  child: Text(
                                      globals.loc == 'en'
                                          ? 'Price: Lowest First'
                                          : 'السعر: الأدنى أولاً',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: sortSelected == '3'
                                              ? Colors.white
                                              : Colors.black)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    sortSelected = '4';
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.5, horizontal: 7.5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: sortSelected == '4'
                                              ? Colors.transparent
                                              : Colors.black),
                                      color: sortSelected == '4'
                                          ? Color(0xFFE7BB1F)
                                          : Colors.transparent),
                                  child: Text(
                                      globals.loc == 'en'
                                          ? 'Price: Highest First'
                                          : 'السعر: الأعلى أولاً',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: sortSelected == '4'
                                              ? Colors.white
                                              : Colors.black)),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: loadFilter
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
                                          color: Colors.grey[800],
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 15),
                                          child: Text(
                                            globals.loc == 'en'
                                                ? 'Filter'
                                                : ' فلترة',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            filterProduct();
                                          }),
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: loadFilter
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
                                          color: yellow,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 15),
                                          child: Text(
                                            globals.loc == 'en'
                                                ? 'Reset all Result'
                                                : ' تفريغ الحقول',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            from.text = "";
                                            to.text = "";
                                          }),
                                    ),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
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
          )),
    );
  }
}

class By {
  final String id;
  final String name;
  By({@required this.id, @required this.name});
}
