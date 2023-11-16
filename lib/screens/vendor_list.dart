import 'package:auto_size_text/auto_size_text.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/screens/favproduct.dart';
import 'package:crafts/screens/filterpage.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/item_list_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/helpers/catdata.dart';

class VendorList extends StatefulWidget {
  final String byName;
  final String byID;
  final String filter;
  final String from, to, sortSelected;
  final Category mainCat, sub1, sub2, tagList, bylist;

  VendorList(
      {@required this.byID,
      @required this.byName,
      @required this.filter,
      @required this.sub1,
      @required this.sub2,
      @required this.from,
      @required this.to,
      @required this.sortSelected,
      @required this.tagList,
      @required this.bylist,
      @required this.mainCat});
  @override
  _VendorListState createState() => _VendorListState();
}

class _VendorListState extends State<VendorList>
    with SingleTickerProviderStateMixin {
  BuildContext parentContext;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  List<By> _tabs = <By>[];
  bool loading = false;
  bool load = false;
  String counter = '';
  List<Product> products = [];
  String subID;
  String sort;
  TextEditingController from = new TextEditingController();
  TextEditingController to = new TextEditingController();
  String sortSelected = '';
  bool loadFilter = false;
  bool loadMain = true;
  bool loadSub1 = false;
  bool loadSub2 = false;
  bool loadBy = false;
  bool loadTag = false;
  String clear = "0";

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
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });

    _tabs.add(By(id: "0", name: globals.loc == 'en' ? 'All' : 'الجميع'));

    _tabController =
        new TabController(length: _tabs.length, vsync: this, initialIndex: 0);

    await getProductSub(widget.byID);

    if (widget.filter == '0')
      await getProductSub(widget.byID);
    else if (widget.filter == '1') await filterProduct();

    setState(() {
      loading = false;
    });
  }

  Future<void> filterProduct() async {
    setState(() {
      loading = true;
    });

    products = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <FilterProduct xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <MainCatID>${widget.mainCat != null ? widget.mainCat.id : ''}</MainCatID>
      <SubCatID>${widget.sub1 != null ? widget.sub1.id : ''}</SubCatID>
      <SubCatID2>${widget.sub2 != null ? widget.sub2.id : ''}</SubCatID2>
      <MinPrice>${widget.from}</MinPrice>
      <HighPrice>${widget.to}</HighPrice>
      <SortID>${widget.sortSelected}</SortID>
      <TagID>${widget.tagList != null ? widget.tagList.id : ''}</TagID>
      <ByID>${widget.bylist != null ? widget.bylist.id : ''}</ByID>
      <Vendor>0</Vendor>

    </FilterProduct>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/FilterProduct",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('FilterProductResult')[0]
        .text;
    final decoded = jsonDecode(json);
    //counter = decoded['Counter'];
    // for (int i = 0; i < decoded['ProductList'].length; i++) {
    //   products.add(Product(
    //       id: decoded['ProductList'][i]['ID'],
    //       brand: decoded['ProductList'][i]['Brand'],
    //       tag: decoded['ProductList'][i]['Tag'],
    //       tagColor: decoded['ProductList'][i]['TagColor'],
    //       title: decoded['ProductList'][i]['Title'],
    //       by: decoded['ProductList'][i]['By'],
    //       price: decoded['ProductList'][i]['Price'],
    //       photo: decoded['ProductList'][i]['Photo'],
    //       favflag: decoded['ProductList'][i]['favflag']));
    // }
    counter = decoded['Counter'];
    for (int i = 0; i < decoded['SubByProd'].length; i++) {
      products.add(Product(
        id: decoded['SubByProd'][i]['ID'],
        title: decoded['SubByProd'][i]['Title'],
        by: decoded['SubByProd'][i]['By'],
        photo: decoded['SubByProd'][i]['Photo'],
      ));
    }

    setState(() {
      loading = false;
    });
  }

  void sortProduct(String id) async {
    setState(() {
      loading = true;
    });

    products = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <SortProduct xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <SubID>$subID</SubID>
      <SortID>$id</SortID>
    </SortProduct>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/SortProduct",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('SortProductResult')[0].text;
    final decoded = jsonDecode(json);
    //counter = decoded['Counter'];
    // for (int i = 0; i < decoded['ProductList'].length; i++) {
    //   products.add(Product(
    //       id: decoded['ProductList'][i]['ID'],
    //       brand: decoded['ProductList'][i]['Brand'],
    //       tag: decoded['ProductList'][i]['Tag'],
    //       tagColor: decoded['ProductList'][i]['TagColor'],
    //       title: decoded['ProductList'][i]['Title'],
    //       by: decoded['ProductList'][i]['By'],
    //       price: decoded['ProductList'][i]['Price'],
    //       photo: decoded['ProductList'][i]['Photo'],
    //       favflag: decoded['ProductList'][i]['favflag']));
    // }
    counter = decoded['Counter'];
    for (int i = 0; i < decoded['SubByProd'].length; i++) {
      products.add(Product(
        id: decoded['SubByProd'][i]['ID'],
        title: decoded['SubByProd'][i]['Title'],
        by: decoded['SubByProd'][i]['By'],
        photo: decoded['SubByProd'][i]['Photo'],
      ));
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> getProductSub(String id) async {
    products = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetSupplier xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <SubByID>$id</SubByID>
    </GetSupplier>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetSupplier",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetSupplierResult')[0].text;
    final decoded = jsonDecode(json);

    counter = decoded['Counter'];
    for (int i = 0; i < decoded['SubByProd'].length; i++) {
      products.add(Product(
        id: decoded['SubByProd'][i]['ID'],
        title: decoded['SubByProd'][i]['Title'],
        by: decoded['SubByProd'][i]['By'],
        photo: decoded['SubByProd'][i]['Photo'],
      ));
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
          body: loading
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top + 10,
                      ),
                      Header(),
                   
                      SizedBox(
                        height: 20,
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
                                widget.byName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => filterpage(
                                                byID: widget.byID,
                                                byName: widget.byName,
                                                mainID: '',
                                                type: '',
                                                type2: '1',
                                              )));
                                },
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.slider_horizontal_3),
                                      SizedBox(width: 10),
                                      Text(
                                        globals.loc == 'en'
                                            ? 'FILTER'
                                            : 'فلترة',
                                        style: TextStyle(fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => Directionality(
                                            textDirection: globals.loc == 'en'
                                                ? TextDirection.ltr
                                                : TextDirection.rtl,
                                            child: Dialog(
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: 10,
                                                            horizontal: 10,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      200]),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                    globals.loc ==
                                                                            'en'
                                                                        ? 'SORT'
                                                                        : 'ترتيب',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              sort = '1';
                                                            });

                                                            if (_tabs
                                                                .isNotEmpty) {
                                                              Navigator.pop(
                                                                  context);
                                                              sortProduct(sort);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Row(
                                                              children: [
                                                                Radio(
                                                                  materialTapTargetSize:
                                                                      MaterialTapTargetSize
                                                                          .shrinkWrap,
                                                                  value: '1',
                                                                  groupValue:
                                                                      sort,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      sort =
                                                                          value;
                                                                    });

                                                                    if (_tabs
                                                                        .isNotEmpty) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      sortProduct(
                                                                          sort);
                                                                    }
                                                                  },
                                                                ),
                                                                Text(
                                                                  globals.loc ==
                                                                          'en'
                                                                      ? 'Most Requested'
                                                                      : 'الأكثر مبيعا',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              sort = '2';
                                                            });

                                                            if (_tabs
                                                                .isNotEmpty) {
                                                              Navigator.pop(
                                                                  context);
                                                              sortProduct(sort);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Row(
                                                              children: [
                                                                Radio(
                                                                  materialTapTargetSize:
                                                                      MaterialTapTargetSize
                                                                          .shrinkWrap,
                                                                  value: '2',
                                                                  groupValue:
                                                                      sort,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      sort =
                                                                          value;
                                                                    });

                                                                    if (_tabs
                                                                        .isNotEmpty) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      sortProduct(
                                                                          sort);
                                                                    }
                                                                  },
                                                                ),
                                                                Text(
                                                                    globals.loc ==
                                                                            'en'
                                                                        ? 'Newest'
                                                                        : 'الأحدث',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              sort = '3';
                                                            });

                                                            if (_tabs
                                                                .isNotEmpty) {
                                                              Navigator.pop(
                                                                  context);
                                                              sortProduct(sort);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Row(
                                                              children: [
                                                                Radio(
                                                                  materialTapTargetSize:
                                                                      MaterialTapTargetSize
                                                                          .shrinkWrap,
                                                                  value: '3',
                                                                  groupValue:
                                                                      sort,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      sort =
                                                                          value;
                                                                    });

                                                                    if (_tabs
                                                                        .isNotEmpty) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      sortProduct(
                                                                          sort);
                                                                    }
                                                                  },
                                                                ),
                                                                Text(
                                                                    globals.loc ==
                                                                            'en'
                                                                        ? 'Price: Lowest First'
                                                                        : 'السعر: الأدنى أولاً',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              sort = '4';
                                                            });

                                                            if (_tabs
                                                                .isNotEmpty) {
                                                              Navigator.pop(
                                                                  context);
                                                              sortProduct(sort);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Row(
                                                              children: [
                                                                Radio(
                                                                  materialTapTargetSize:
                                                                      MaterialTapTargetSize
                                                                          .shrinkWrap,
                                                                  value: '4',
                                                                  groupValue:
                                                                      sort,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      sort =
                                                                          value;
                                                                    });

                                                                    if (_tabs
                                                                        .isNotEmpty) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      sortProduct(
                                                                          sort);
                                                                    }
                                                                  },
                                                                ),
                                                                Text(
                                                                  globals.loc ==
                                                                          'en'
                                                                      ? 'Price: Highest First'
                                                                      : 'السعر: الأعلى أولاً',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.sort_down),
                                      SizedBox(width: 10),
                                      Text(
                                        globals.loc == 'en' ? 'SORT' : 'ترتيب',
                                        style: TextStyle(fontSize: 20),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'MainFont'),
                          unselectedLabelStyle: TextStyle(
                              fontSize: 15,
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

                            subID = _tabs[i].id;
                            setState(() {
                              load = false;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      load
                          ? Container(height: 0, width: 0)
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                globals.loc == 'en'
                                    ? 'items found $counter '
                                    : 'تم العثور على $counter ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                      load
                          ? Container(height: 0, width: 0)
                          : SizedBox(height: 10),
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
                              child: sliverGridWidget(context),
                            )
                    ],
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

  Widget sliverGridWidget(BuildContext context) {
    return StaggeredGridView.count(
      padding: EdgeInsets.all(8.0),
      crossAxisCount: 2, //staticData.length,

      children: products.map((product) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ItemListOne(
                              byName: product.title,
                              byID: product.id,
                              type: '1',
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
              },
              child: Container(
                decoration: BoxDecoration(),
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox(
                          
                              child: Image.network(
                                product.photo,
    
                              /*   loadingBuilder: (BuildContext context,
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
                              */   fit: BoxFit.fill,
                              ),
                          
                          ),
                        ],
                      ),
                    ),
                    Text(product.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    AutoSizeText(
                      product.by,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: yellow,
                          fontSize: 15),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
      staggeredTiles: products.map((_) {
        return StaggeredTile.count(1, 1.65);
      }).toList(),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );
  }
}

class By {
  final String id;
  final String name;
  By({@required this.id, @required this.name});
}

class Product {
  final String id;
  final String title;
  final String by;
  final String photo;

  Product({this.id, this.title, this.by, this.photo});
}
