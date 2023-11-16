import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/core/hex_color.dart';
import 'package:crafts/screens/product_details.dart';


class SearchResult extends StatefulWidget {
  final String subID;
  final String query;
  SearchResult({@required this.query, @required this.subID});
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  String counter = '';
  List<Product> products = [];
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
    await getProducts();
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
  
  Future<void> getProducts() async {
    products = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <SearchProduct xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <SubID>${widget.subID}</SubID>
      <SearchVal>${widget.query}</SearchVal>
    </SearchProduct>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/SearchProduct",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('SearchProductResult')[0]
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
          favflag: decoded['SubByProd'][i]['favflag']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: 
        loading
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
                 Divider(),
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
                              widget.query,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
                      child: Text(
                        globals.loc == 'en'
                            ? 'Showing $counter results'
                            : 'تظهر $counter نتيجة',
                        style: TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
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
          ),
        ),
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
            return
             GestureDetector(
               
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
               
                decoration: BoxDecoration(
                  
                ),
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox(
                          
                            child:
                             ClipRRect(
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
                              border:
                                  Border.all(color: HexColor(product.tagColor)),
                            ),
                            child: AutoSizeText(product.tag,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: HexColor(product.tagColor),
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
                      style: TextStyle(color: Colors.grey, fontSize: 15),
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

  Product(
      {this.id,
      this.brand,
      this.tag,
      this.tagColor,
      this.title,
      this.by,
      this.price,
      this.photo,
      this.favflag});
}
