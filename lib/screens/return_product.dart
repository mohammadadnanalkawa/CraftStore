import 'package:auto_size_text/auto_size_text.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/screens/confirm_return.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';

class ReturnProduct extends StatefulWidget {
  @override
  _ReturnProductState createState() => _ReturnProductState();
}

class _ReturnProductState extends State<ReturnProduct> {
  double total = 0;
  bool loading = false;
  List<Product> selected = <Product>[];
  List<ItemWidget> items = <ItemWidget>[];
  void loadData() async {
    setState(() {
      loading = true;
    });
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetReturnProduct xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetReturnProduct>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetReturnProduct",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    if (response.statusCode == 200) {
      print(response.body);
      String json = parse(response.body)
          .getElementsByTagName('GetReturnProductResult')[0]
          .text;
      final decoded = jsonDecode(json);
      print(decoded);
      for (int i = 0; i < decoded.length; i++) {
        String type = decoded[i]['returnflag'];
        if (type == '1')
          type = '1';
        else
          type = '0';
        items.add(ItemWidget(
          brand: decoded[i]['Brand'],
          change: (item, check) {
            if (check) {
              for (int x = 0; x < selected.length; x++) {
                if (selected[x].id == item.id) {
                  selected.removeWhere((element) => element.id == item.id);
                  total -=  (double.parse(item.price) * item.quantity);
                }
              }
              selected.add(Product(
                  brand: item.brand,
                  by: item.by,
                  title: item.title,
                  id: item.id,
                  price: item.price,
                  image: item.image,
                  quantity: item.quantity,
                  returnflag: item.returnflag,
                  groupprod: item.groupprod));
               
              total += (double.parse(item.price) * item.quantity);
              print(total);
            } else {
              for (int x = 0; x < selected.length; x++) {
                if (selected[x].id == item.id) {
                  selected.removeWhere((element) => element.id == item.id);
                  total -=  (double.parse(item.price) * item.quantity);
                }
              }
            }
            setState(() {});
          },
          groupprod: type,
          returnflag: decoded[i]['returnflag'],
          by: decoded[i]['By'],
          title: decoded[i]['Title'],
          id: decoded[i]['ReturnID'],
          price: decoded[i]['Price'],
          image: decoded[i]['Photo'],
          quantity: int.parse(
            decoded[i]['quantity'],
          ),
        ));
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
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
                          text:
                              globals.loc == 'en' ? 'New Return' : 'ارجاع جديد',
                          press: () {
                            Navigator.pop(context);
                          },
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            shrinkWrap: true,
                            itemCount: items.length,
                            itemBuilder: (context, index) => items[index],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.black),
          padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 7.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                      globals.loc == 'en'
                          ? '${selected.length} Items Selected'
                          : '${selected.length} العناصر المحددة',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(
                      globals.loc == 'en'
                          ? 'Total: SAR ${total.toStringAsFixed(2)}'
                          : 'مجموع: SAR ${total.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white, fontSize: 18))
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                        elevation: 0,
                        shape: RoundedRectangleBorder(),
                        color: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        child: Text(
                          globals.loc == 'en'
                              ? 'Return Items'
                              : 'إرجاع العناصر',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18),
                        ),
                        onPressed: () async {
                          if (selected.length > 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ConfirmReturn(selected: selected)));
                          }
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef void VoidCallback(Product item, bool value);

class ItemWidget extends StatefulWidget {
  final String by;
  final String brand;
  final String title;
  final String id;
  final String price;
  final String image;
  int quantity;
  final String returnflag;
  String groupprod;

  final VoidCallback change;

  ItemWidget(
      {@required this.brand,
      @required this.by,
      @required this.change,
      @required this.title,
      @required this.id,
      @required this.price,
      @required this.image,
      @required this.quantity,
      @required this.returnflag,
      @required this.groupprod});

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  bool check = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
          widget.image == '' ?Container() :     ClipRRect(
                  child: Image.network(
                widget.image,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(yellow),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    ),
                  );
                },
                height: 120,
                width: 80,
                fit: BoxFit.fill,
              )),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      widget.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    AutoSizeText(
                      widget.by,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: yellow,
                          fontSize: 17),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    AutoSizeText(
                      '${widget.price} SAR',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                    Row(
                      children: [
                        Text(globals.loc == 'en' ? 'Quantity:' : 'الكمية:',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 18)),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                               /*  widget.quantity > 1
                                    ? 
                                    GestureDetector(
                                        onTap: widget.quantity <= 1
                                            ? null
                                            : () async {
                                                setState(() {
                                                  widget.change(
                                                      Product(
                                                          brand: widget.brand,
                                                          by: widget.by,
                                                          title: widget.title,
                                                          id: widget.id,
                                                          price: widget.price,
                                                          image: widget.image,
                                                          quantity:
                                                              widget.quantity--,
                                                          returnflag:
                                                              widget.returnflag,
                                                          groupprod: widget
                                                              .returnflag),
                                                      check);
                                                  widget.quantity--;
                                                });
                                              },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          child: Icon(
                                            Icons.remove_circle_outline,
                                            color: yellow,
                                            size: 28,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                widget.quantity > 1
                                    ? SizedBox(
                                        width: 15,
                                      )
                                    : SizedBox(
                                        width: 0,
                                      ), */
                                Text(
                                  widget.quantity.toString(),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.returnflag != '1'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      value: '1',
                                      groupValue: widget.groupprod,
                                      onChanged: (value) {
                                        setState(() {
                                          widget.groupprod = value;

                                          widget.change(
                                              Product(
                                                  brand: widget.brand,
                                                  by: widget.by,
                                                  title: widget.title,
                                                  id: widget.id,
                                                  price: widget.price,
                                                  image: widget.image,
                                                  quantity: widget.quantity,
                                                  returnflag: widget.returnflag,
                                                  groupprod: value),
                                              check);
                                        });
                                      }),
                                  Text(globals.loc == 'en' ? 'Return' : 'ارجاع',
                                      style: TextStyle(fontSize: 20))
                                ],
                              )
                            : Container(),
                        SizedBox(
                          width: 15,
                        ),
                        widget.returnflag != '2'
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      value: '2',
                                      groupValue: widget.groupprod,
                                      onChanged: (value) {
                                        setState(() {
                                          widget.groupprod = value;

                                          widget.change(
                                              Product(
                                                  brand: widget.brand,
                                                  by: widget.by,
                                                  title: widget.title,
                                                  id: widget.id,
                                                  price: widget.price,
                                                  image: widget.image,
                                                  quantity: widget.quantity,
                                                  returnflag: widget.returnflag,
                                                  groupprod: value),
                                              check);
                                        });
                                      }),
                                  Text(
                                      globals.loc == 'en'
                                          ? 'Replacement'
                                          : 'استبدال',
                                      style: TextStyle(fontSize: 20))
                                ],
                              )
                            : Container()
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: check,
                  onChanged: (value) {
                    setState(() {
                      check = value;
                      widget.change(
                          Product(
                              brand: widget.brand,
                              by: widget.by,
                              title: widget.title,
                              id: widget.id,
                              price: widget.price,
                              image: widget.image,
                              quantity: widget.quantity,
                              returnflag: widget.returnflag,
                              groupprod: widget.groupprod),
                          check);
                    });
                  })
            ],
          ),
        ],
      ),
    );
  }
}

class Product {
  final String by;
  final String brand;
  final String title;
  final String id;
  final String price;
  final String image;
  int quantity;
  final String returnflag;
  String groupprod;

  Product(
      {@required this.brand,
      @required this.by,
      @required this.title,
      @required this.id,
      @required this.price,
      @required this.image,
      @required this.quantity,
      @required this.returnflag,
      @required this.groupprod});
}
