import 'package:crafts/core/color.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/app_bar_order.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';

import 'package:flutter/cupertino.dart';

class OrderDetails extends StatefulWidget {
  final String id;
  OrderDetails({@required this.id});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String orderNo;
  String total;
  String method;
  String discount;
  String name;
  String phone;
  String address;
  String status;
  String date;
  String vat;
  String ship;
  String shipvat;
  String grand;
  String wallet;

  List<ItemWidget> items = <ItemWidget>[];
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
    await getOrderDetails();
    setState(() {
      loading = false;
    });
  }

  Future<void> getOrderDetails() async {
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <OrderData xmlns="http://Craft.WS/">
      <OrderID>${widget.id}</OrderID>
    </OrderData>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/OrderData",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('OrderDataResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      orderNo = decoded[i]['OrderID'];
      total = decoded[i]['OrderValue'];
      method = decoded[i]['PaymentMethod'];
      discount = decoded[i]['Discount'];
      name = decoded[i]['Name'];
      phone = decoded[i]['Phone'];
      address = decoded[i]['Address'];
      status = decoded[i]['Status'];
      date = decoded[i]['Placedon'];
      vat = decoded[i]['vat'];
      ship = decoded[i]['ship'];
      shipvat = decoded[i]['shipvat'];
      grand = decoded[i]['grand'];
      wallet = decoded[i]['wallet'];

      items = [];
      for (int j = 0; j < decoded[i]['ProductList'].length; j++) {
        items.add(ItemWidget(
          orderId: widget.id,
          brand: decoded[i]['ProductList'][j]['Category'],
          cancel: () {
            loadData();
          },
          title: decoded[i]['ProductList'][j]['Title'],
          id: decoded[i]['ProductList'][j]['ID'],
          price: decoded[i]['ProductList'][j]['Price'],
          image: decoded[i]['ProductList'][j]['Photo'],
          quantity: decoded[i]['ProductList'][j]['Quantity'],
          shipstatus: decoded[i]['ProductList'][j]['shipstatus'],
        ));
      }
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
                  child: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppBarOrder(
                            implyLeading: true,
                            text: globals.loc == 'en' ? 'My Orders' : 'طلباتي',
                            press: () {
                              Navigator.pop(context);
                            },
                            textColor: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.grey[100]),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    globals.loc == 'en'
                                        ? 'Order# ' + orderNo
                                        : ' رقم الطلب ' + orderNo,
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  Divider(),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Text(
                                              globals.loc == 'en'
                                                  ? 'Placed at ' + date
                                                  : ' انشئ في  ' + date,
                                              style: TextStyle(fontSize: 19)),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: globals.loc == 'en'
                                                ? Border(
                                                    left: BorderSide(
                                                      //                   <--- left side
                                                      color: Colors.grey[700],
                                                      width: 1.0,
                                                    ),
                                                  )
                                                : Border(
                                                    right: BorderSide(
                                                      //                   <--- left side
                                                      color: Colors.grey[700],
                                                      width: 1.0,
                                                    ),
                                                  )),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.31,
                                        child: Padding(
                                          child: Text(method,
                                              style: TextStyle(fontSize: 19)),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) => items[index],
                                  itemCount: items.length,
                                ),
                                Divider(
                                  thickness: 1.0,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  globals.loc == 'en'
                                      ? 'Order Status'
                                      : 'حالة الطلب',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SizedBox(height: 10),
                                Text(status, style: TextStyle(fontSize: 19)),
                                Divider(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      globals.loc == 'en'
                                          ? 'SUBTOTAL'
                                          : 'المجموع الفرعي',
                                      style: TextStyle(fontSize: 19),
                                    )),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(total,
                                          style: TextStyle(fontSize: 19)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                              discount != '' ?  Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(
                                            globals.loc == 'en'
                                                ? 'Discount'
                                                : 'الخصم',
                                            style: TextStyle(fontSize: 19))),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                          discount == '' ? '0' : discount,
                                          style: TextStyle(fontSize: 19)),
                                    )
                                  ],
                                ): Container(),
                               discount != '' ?   SizedBox(height: 10) :   SizedBox(height: 0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(
                                            globals.loc == 'en'
                                                ? 'Shipping Fee'
                                                : 'قيمة الشحن',
                                            style: TextStyle(fontSize: 19))),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(ship,
                                          style: TextStyle(fontSize: 19)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(
                                            globals.loc == 'en'
                                                ? 'Vat'
                                                : 'ضريبة القيمة المضافة',
                                            style: TextStyle(fontSize: 19))),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(vat,
                                          style: TextStyle(fontSize: 19)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(
                                            globals.loc == 'en'
                                                ? 'Shippment Vat'
                                                : 'ضريبة الشحن',
                                            style: TextStyle(fontSize: 19))),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(shipvat,
                                          style: TextStyle(fontSize: 19)),
                                    )
                                  ],
                                ),
                                 wallet == '' ?  SizedBox(height: 0) : SizedBox(height: 10),
                                wallet == '' ?  Row() :
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(
                                            globals.loc == 'en'
                                                ? 'Wallet Balance'
                                                : 'رصيد المحفظة',
                                            style: TextStyle(fontSize: 19))),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(wallet,
                                          style: TextStyle(fontSize: 19)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Divider(
                                  thickness: 1.0,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(
                                            globals.loc == 'en'
                                                ? 'GRAND TOTAL'
                                                : 'الإجمالي',
                                            style: TextStyle(
                                                fontSize: 19,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold))),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(grand,
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20),
                                Text(
                                  globals.loc == 'en'
                                      ? 'Shipping Address'
                                      : '  عنوان الشحن',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(name,
                                          style: TextStyle(fontSize: 17)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(phone,
                                          style: TextStyle(fontSize: 17)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(address,
                                          style: TextStyle(fontSize: 17)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Divider(
                                  thickness: 1.0,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  globals.loc == 'en'
                                      ? 'Billing Address'
                                      : '  عنوان الدفع',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(name,
                                          style: TextStyle(fontSize: 17)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(phone,
                                          style: TextStyle(fontSize: 17)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(address,
                                          style: TextStyle(fontSize: 17)),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
             
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

typedef void VoidCallback();

class ItemWidget extends StatefulWidget {
  final String orderId;
  final String brand;
  final String title;
  final String id;
  final String price;
  final String image;
  final String quantity;
  final String shipstatus;

  final VoidCallback cancel;

  ItemWidget(
      {@required this.brand,
      @required this.orderId,
      @required this.cancel,
      @required this.title,
      @required this.id,
      @required this.price,
      @required this.image,
      @required this.quantity,
      @required this.shipstatus});

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  bool load = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return load
        ? Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(yellow),
            ),
          )
        : Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
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
                          /*   Text(
                            widget.brand,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 18),
                          ),
                          SizedBox(
                            height: 7.5,
                          ), */
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '${widget.price} SAR',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(color: Colors.grey, fontSize: 17),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            widget.shipstatus,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(color: Colors.grey[700], fontSize: 18),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          globals.loc == 'en'
                              ? '${widget.quantity} Quantity'
                              : ' ${widget.quantity} الكمية ',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 17,
                              decoration: TextDecoration.underline),
                        )
                      ],
                    ),
                  ),
                )

                /*        GestureDetector(
                  onTap: () async {
                    setState(() {
                      load = true;
                    });
                    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <CancelItem xmlns="http://Craft.WS/">
      <OrderID>${widget.orderId}</OrderID>
      <ItemID>${widget.id}</ItemID>
    </CancelItem>
  </soap:Body>
</soap:Envelope>''';
                    http.Response response = await http
                        .post(
                            'https://craftapp.net/services/CraftWebService.asmx',
                            headers: {
                              "SOAPAction": "http://Craft.WS/CancelItem",
                              "Content-Type": "text/xml;charset=UTF-8",
                            },
                            body: utf8.encode(soap),
                            encoding: Encoding.getByName("UTF-8"))
                        .then((onValue) {
                      return onValue;
                    });
                    String json = parse(response.body)
                        .getElementsByTagName('CancelItemResult')[0]
                        .text;
                    final decoded = jsonDecode(json);
                    print(decoded);
                    setState(() {
                      load = false;
                    });
                    if (decoded['Flag'] == '1') {
                      widget.cancel();
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                            decoded['SMS'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          duration: Duration(seconds: 4)));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          globals.loc == 'en' ? 'Cancel Item' : 'إلغاء البند',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              decoration: TextDecoration.underline),
                        )
                      ],
                    ),
                  ),
                )
         */
              ],
            ),
          );
  }
}
