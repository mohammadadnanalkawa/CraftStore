import 'package:auto_size_text/auto_size_text.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/core/hex_color.dart';
import 'package:crafts/screens/favproduct.dart';
import 'package:crafts/screens/filterpage.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/product_details.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/helpers/catdata.dart';


class CategoryItemList extends StatefulWidget {
  final String byName;
  final String byID;

  final String mainID, filter, may;
  final String type, from, to, sortSelected;
  final Category mainCat, sub1, sub2, tagList, bylist;

  CategoryItemList(
      {@required this.byID,
      @required this.byName,
      @required this.mainID,
      @required this.type,
      @required this.mainCat,
      @required this.sub1,
      @required this.sub2,
      @required this.from,
      @required this.to,
      @required this.sortSelected,
      @required this.tagList,
      @required this.bylist, 
      @required this.filter,
      @required this.may});
  @override
  _CategoryItemList createState() => _CategoryItemList();
}

class _CategoryItemList extends State<CategoryItemList>
    with SingleTickerProviderStateMixin {
  BuildContext parentContext;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
  }

  void loadData() async {
    setState(() {
      loading = true;
    });

    subID = widget.mainID;
    if(widget.filter == '0')
    await getProductSub(widget.mainID, widget.byID, widget.type, '');
    else if(widget.filter == '1' && widget.may== '0')
      await filterProduct();
       else if(widget.filter == '1' && widget.may!= '1')
      await getmay(widget.may);

    setState(() {
      loading = false;
    });
  }

  Future<void> getmay(String mayid) async {
    setState(() {
      loading = true;
    });

    products = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetMoreMay xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <SubByID2>$mayid</SubByID2>
    </GetMoreMay>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetMoreMay",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetMoreMayResult')[0]
        .text;
    final decoded = jsonDecode(json);

    counter = decoded['Counter'];
    for (int i = 0; i < decoded['SubByProd'].length; i++) {
      products.add(Product(
          id: decoded['SubByProd'][i]['ID'],
          brand: decoded['SubByProd'][i]['Brand'],
          tag: decoded['SubByProd'][i]['Tag'],
          tagColor: decoded['SubByProd'][i]['TagColor'],
          title: decoded['SubByProd'][i]['Title'],
          by: decoded['SubByProd'][i]['By'],
          price: decoded['SubByProd'][i]['Price'],
          photo: decoded['SubByProd'][i]['Photo'],
          favflag: decoded['SubByProd'][i]['favflag'],
          fontcolor: decoded['SubByProd'][i]['FontColor']));
    }

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
      <Vendor>1</Vendor>
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
          brand: decoded['SubByProd'][i]['Brand'],
          tag: decoded['SubByProd'][i]['Tag'],
          tagColor: decoded['SubByProd'][i]['TagColor'],
          title: decoded['SubByProd'][i]['Title'],
          by: decoded['SubByProd'][i]['By'],
          price: decoded['SubByProd'][i]['Price'],
          photo: decoded['SubByProd'][i]['Photo'],
          favflag: decoded['SubByProd'][i]['favflag'],
          fontcolor: decoded['SubByProd'][i]['FontColor'],));
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> getProductSub(
      String id, String subid, String type, String sort) async {
    setState(() {
      loading = true;
    });

    products = [];
 
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetProdBySubCat xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <SubByID1>$id</SubByID1>
      <SubByID2>$subid</SubByID2>

      <Type>$type</Type>
      <Sort>$sort</Sort>

    </GetProdBySubCat>
  </soap:Body>
</soap:Envelope>''';
print(soap);
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetProdBySubCat",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    String json = parse(response.body)
        .getElementsByTagName('GetProdBySubCatResult')[0]
        .text;
    final decoded = jsonDecode(json);

    counter = decoded['Counter'];
    for (int i = 0; i < decoded['SubByProd'].length; i++) {
      products.add(Product(
          id: decoded['SubByProd'][i]['ID'],
          brand: decoded['SubByProd'][i]['Brand'],
          tag: decoded['SubByProd'][i]['Tag'],
          tagColor: decoded['SubByProd'][i]['TagColor'],
          title: decoded['SubByProd'][i]['Title'],
          by: decoded['SubByProd'][i]['By'],
          price: decoded['SubByProd'][i]['Price'],
          photo: decoded['SubByProd'][i]['Photo'],
          favflag: decoded['SubByProd'][i]['favflag'],
          fontcolor: decoded['SubByProd'][i]['FontColor']));
    }

    setState(() {
      loading = false;
    });
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
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
                        height: 5,
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
                                                mainID: widget.mainID,
                                                type: widget.type,
                                                type2: '0',
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

                                                            Navigator.pop(
                                                                context);
                                                            getProductSub(
                                                                widget.mainID,
                                                                widget.byID,
                                                                widget.type,
                                                                sort);
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

                                                                    Navigator.pop(
                                                                        context);
                                                                    getProductSub(
                                                                        widget
                                                                            .mainID,
                                                                        widget
                                                                            .byID,
                                                                        widget
                                                                            .type,
                                                                        sort);
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

                                                            Navigator.pop(
                                                                context);
                                                            getProductSub(
                                                                widget.mainID,
                                                                widget.byID,
                                                                widget.type,
                                                                sort);
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

                                                                    Navigator.pop(
                                                                        context);
                                                                    getProductSub(
                                                                        widget
                                                                            .mainID,
                                                                        widget
                                                                            .byID,
                                                                        widget
                                                                            .type,
                                                                        sort);
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

                                                            Navigator.pop(
                                                                context);
                                                            getProductSub(
                                                                widget.mainID,
                                                                widget.byID,
                                                                widget.type,
                                                                sort);
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

                                                                    Navigator.pop(
                                                                        context);
                                                                    getProductSub(
                                                                        widget
                                                                            .mainID,
                                                                        widget
                                                                            .byID,
                                                                        widget
                                                                            .type,
                                                                        sort);
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

                                                            Navigator.pop(
                                                                context);
                                                            getProductSub(
                                                                widget.mainID,
                                                                widget.byID,
                                                                widget.type,
                                                                sort);
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

                                                                    Navigator.pop(
                                                                        context);
                                                                    getProductSub(
                                                                        widget
                                                                            .mainID,
                                                                        widget
                                                                            .byID,
                                                                        widget
                                                                            .type,
                                                                        sort);
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
                  
                      SizedBox(height: 15),
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
                            ),
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
        String fav = product.favflag;
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductDetails(
                              favChange: (val) {
                                setState(() {
                                  fav = val;
                                });
                              },
                              favflag: fav,
                              productID: product.id,
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
                            child: ClipRRect(
                              child: Image.network(
                                product.photo,
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
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (fav == '0') {
                                    fav = '1';
                                  } else {
                                    fav = '0';
                                  }
                                });

                                String soapFav =
                                    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <AddFavProduct xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <Status>$fav</Status>
      <ProductID>${product.id}</ProductID>
    </AddFavProduct>
  </soap:Body>
</soap:Envelope>''';
                                http.post(
                                    'https://craftapp.net/services/CraftWebService.asmx',
                                    headers: {
                                      "SOAPAction":
                                          "http://Craft.WS/AddFavProduct",
                                      "Content-Type": "text/xml;charset=UTF-8",
                                    },
                                    body: utf8.encode(soapFav),
                                    encoding: Encoding.getByName("UTF-8"));
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 7.5, top: 7.5),
                                decoration: BoxDecoration(),
                                child: Icon(fav == '0'
                                    ? CupertinoIcons.heart
                                    : CupertinoIcons.heart_fill),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    product.tag == ''
                        ? Container()
                        : Container(
                        
                            padding: EdgeInsets.symmetric(
                                vertical: 7.5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: HexColor(product.tagColor) ,
                              border:
                              product.fontcolor == '#000000' ?    Border.all(color: HexColor(product.fontcolor)):
                              Border.all(color: HexColor(product.tagColor)),
                            ),
                            child: AutoSizeText(product.tag,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: HexColor(product.fontcolor), 
                               //    color:  Colors.white,
                                    fontSize: 12)),
                          ),
                    SizedBox(
                      height: 5,
                    ),
                    AutoSizeText(
                      product.brand,
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
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
                      height: 5,
                    ),
                    AutoSizeText(
                      '${product.price} SAR',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
      staggeredTiles: products.map((_) {
        return StaggeredTile.count(1, 2.1);
      }).toList(),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );
  }
}

class Product {
  final String id;
  final String brand;
  final String tag;
  final String tagColor;
  final String title;
  final String by;
  final String price;
  final String photo;
  final String favflag;
  final String fontcolor;


  Product(
      {this.id,
      this.brand,
      this.tag,
      this.tagColor,
      this.title,
      this.by,
      this.price,
      this.photo,
      this.favflag,
      this.fontcolor});
}


