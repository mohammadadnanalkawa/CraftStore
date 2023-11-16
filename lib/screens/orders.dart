import 'package:crafts/core/color.dart';
import 'package:crafts/screens/order_details.dart';
import 'package:crafts/screens/return_details.dart';
import 'package:crafts/screens/return_product.dart';
import 'package:crafts/widgets/app_bar_order.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'home.dart';
import 'package:crafts/core/hex_color.dart';
import 'package:flutter/cupertino.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

List<Reason> cancelreason = <Reason>[];
Reason currentSelectedValue;

class _OrdersState extends State<Orders> with SingleTickerProviderStateMixin {
  TabController controller;
  bool loading = false;
  int tabindex = 0;
  List<OrderWidget> orders = <OrderWidget>[];
  String enable;
  List<String> policyList = <String>[];
  List<RuleWidget> rules = <RuleWidget>[];

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 2, vsync: this, initialIndex: 0);
    loadData();
  }

  Future<void> getcancelreason() async {
    cancelreason = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCancelReason xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetCancelReason>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetCancelReason",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetCancelReasonResult')[0]
        .text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      cancelreason
          .add(Reason(id: decoded[i]['ID'], title: decoded[i]['Title']));
    }
    if (cancelreason.isNotEmpty) {
      currentSelectedValue = cancelreason[0];
    }
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
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetReturndata xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetReturndata>
  </soap:Body>
</soap:Envelope>''';

    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetReturndata",
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
          .getElementsByTagName('GetReturndataResult')[0]
          .text;
      final decoded = jsonDecode(json);
      print(decoded);
      enable = decoded['EnableButton'];
      for (int i = 0; i < decoded['RulesList'].length; i++) {
        policyList.add(decoded['RulesList'][i]['Title']);
      }
      for (int i = 0; i < decoded['MyReturnList'].length; i++) {
        rules.add(RuleWidget(
            id: decoded['MyReturnList'][i]['ID'],
            request: decoded['MyReturnList'][i]['Request'],
            date: decoded['MyReturnList'][i]['Date'],
            status: decoded['MyReturnList'][i]['Status']));
      }
    }

    await getOrders();
    await getcancelreason();
    setState(() {
      loading = false;
    });
  }

  Future<void> getOrders() async {
    orders = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetMyOrders xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetMyOrders>
  </soap:Body>
</soap:Envelope>''';
/*       <CustomerID>${globals.user.id}</CustomerID>
 */
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetMyOrders",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetMyOrdersResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      List<String> photos = <String>[];
      for (int j = 0; j < decoded[i]['PhotoList'].length; j++) {
        photos.add(decoded[i]['PhotoList'][j]['Photo']);
      }
      orders.add(OrderWidget(
        id: decoded[i]['ID'],
        date: decoded[i]['Date'],
        orderNo: decoded[i]['OrderNumber'],
        total: decoded[i]['Total'],
        status: decoded[i]['Status'],
        photos: photos,
        enablecancel: decoded[i]['EnableCancel'],
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
                        AppBarOrder(
                          implyLeading: true,
                          text: globals.loc == 'en' ? 'My Orders' : 'الطلبات',
                          press: () {
                            Navigator.pop(context);
                          },
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        Divider(),
                        TabBar(
                          unselectedLabelColor: Colors.grey,
                          unselectedLabelStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'MainFont'),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.black,
                          labelStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'MainFont'),
                          indicatorColor: yellow,
                          indicatorWeight: 3.0,
                          controller: controller,
                          tabs: <Widget>[
                            GestureDetector(
                              child: Tab(
                                  text: globals.loc == 'en'
                                      ? 'New Orders'
                                      : 'طلبات جديدة'),
                              onTap: () {
                                setState(() {
                                  controller.index = 0;
                                });
                              },
                            ),
                            GestureDetector(
                                child: Tab(
                                  text: globals.loc == 'en'
                                      ? 'Return Orders'
                                      : 'الطلبات المسترجعة',
                                ),
                                onTap: () {
                                  setState(() {
                                    controller.index = 1;
                                  });
                                }),
                          ],
                        ),
                        SizedBox(height: 15),
                        controller.index == 0
                            ? Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) =>
                                      orders[index],
                                  itemCount: orders.length,
                                  separatorBuilder: (context, index) => Divider(
                                    thickness: 1.0,
                                  ),
                                ),
                              )
                            : Container(
                                child: Column(
                                children: [
                                  enable == '1'
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: RaisedButton(
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(),
                                                    color: Colors.grey[800],
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 15,
                                                            horizontal: 15),
                                                    child: Text(
                                                      globals.loc == 'en'
                                                          ? 'New Return'
                                                          : ' ارجاع جديد',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 20),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ReturnProduct()));
                                                    }),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: 0,
                                          width: 0,
                                        ),
                                  enable == '1'
                                      ? SizedBox(
                                          height: 20,
                                        )
                                      : Container(
                                          height: 0,
                                          width: 0,
                                        ),
                                  enable == '1' ? Divider() : Container(),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  rules.length == 0
                                      ? Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(CupertinoIcons.cube_box,
                                                  size: 50),
                                              SizedBox(height: 15),
                                              Text(
                                                  globals.loc == 'en'
                                                      ? 'Your return list is empty'
                                                      : 'قائمة الاستبدال والاسترجاع الخاصة بك فارغة',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 22))
                                            ],
                                          ),
                                        )
                                      : ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          shrinkWrap: true,
                                          itemCount: rules.length,
                                          itemBuilder: (context, index) =>
                                              rules[index],
                                        ),
                                ],
                              )),
                      ],
                    ),
                  )),
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
        ));
  }
}

class OrderWidget extends StatefulWidget {
  final String id;
  final String date;
  final String orderNo;
  final String total;
  final String status;
  final List<String> photos;
  final String enablecancel;

  OrderWidget(
      {@required this.date,
      @required this.id,
      @required this.orderNo,
      @required this.total,
      @required this.photos,
      @required this.status,
      @required this.enablecancel});
  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderDetails(id: widget.id)));
            },
            child: Container(
              decoration: BoxDecoration(),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.date,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontFamily: 'MainFont')),
                      SizedBox(
                        height: 5,
                      ),
                      RichText(
                        text: new TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            new TextSpan(
                                text:
                                    globals.loc == 'en' ? 'Order# ' : 'الطلب# ',
                                style: TextStyle(
                                    fontSize: 22, fontFamily: 'MainFont')),
                            new TextSpan(
                                text: widget.orderNo,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    fontFamily: 'MainFont')),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      RichText(
                        text: new TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            new TextSpan(
                                text: globals.loc == 'en'
                                    ? 'Total: '
                                    : 'المجموع: ',
                                style: TextStyle(
                                    fontSize: 22, fontFamily: 'MainFont')),
                            new TextSpan(
                                text: '${widget.total} SAR',
                                style: new TextStyle(
                                    color: yellow,
                                    fontSize: 22,
                                    fontFamily: 'MainFont')),
                          ],
                        ),
                      ),
                    ],
                  )),
                  SizedBox(
                    width: 20,
                  ),
                  Text(globals.loc == 'en' ? 'Order Details' : 'تفاصيل الطلب',
                      style: TextStyle(fontSize: 20)),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          RichText(
            text: new TextSpan(
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                new TextSpan(
                    text:
                        globals.loc == 'en' ? 'Order Status: ' : 'حالة الطلب: ',
                    style: TextStyle(fontSize: 22, fontFamily: 'MainFont')),
                new TextSpan(
                    text: widget.status,
                    style: new TextStyle(
                        color: yellow, fontSize: 22, fontFamily: 'MainFont')),
              ],
            ),
          ),
          widget.photos.isEmpty
              ? Container(height: 0, width: 0)
              : SizedBox(
                  height: 10,
                ),
          widget.photos.isEmpty
              ? Container(height: 0, width: 0)
              : Container(
                  height: 120,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.photos.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 120,
                        width: 80,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          height: 120,
                          width: 80,
                          child: Image.network(
                            widget.photos[index],
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(yellow),
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                ),
                              );
                            },
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                  ),
                ),
          SizedBox(
            height: 10,
          ),
          widget.enablecancel == '0'
              ? Container()
              : Align(
                  alignment: globals.loc == 'en'
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: GestureDetector(
                    child: Text(
                      globals.loc == 'en' ? 'Cancel Order' : 'الغاء الطلب',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 20),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => _cancelConfirmDialog(widget.id),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25))));
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _cancelConfirmDialog(String cancelid) {
    return Directionality(
      textDirection:
          globals.loc == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                  ),
                  child: Icon(Icons.arrow_drop_down),
                ),
              ),
              SizedBox(height: 20),
              Text(globals.loc == 'en' ? 'Confirmation' : 'تأكيد',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  )),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                      ),
                      child: DropdownButtonFormField<Reason>(
                        isDense: true,
                        hint: Text(globals.loc == 'en' ? 'Reason' : 'السبب',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            )),
                        onChanged: (value) {
                          setState(() {
                            currentSelectedValue = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return globals.loc == 'en' ? 'Required' : 'مطلوب';
                          } else
                            return null;
                        },
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                        // value: widget.selected,
                        items: cancelreason.map((e) {
                          return DropdownMenuItem<Reason>(
                            value: e,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Align(
                                alignment: globals.loc != 'en'
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Text(
                                  e.title,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                        globals.loc == 'en'
                            ? 'Are you sure you want to cancel this order?'
                            : 'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#e85d64'))),
                    SizedBox(height: 20),
                    Text(
                        globals.loc == 'en'
                            ? 'This Order will be automatically canceled if the seller does not ship your order within 3- 20 working days and return the full amount refund return back to your bank account'
                            : 'سيتم إلغاء هذا الطلب تلقائيًا إذا لم يشحن البائع طلبك في غضون 3 إلى 20 يوم عمل وإعادة المبلغ المسترد بالكامل إلى حسابك المصرفي',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: RaisedButton(
                              elevation: 0,
                              color: yellow,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Text(
                                globals.loc == 'en' ? 'Yes' : 'نعم',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20),
                              ),
                              onPressed: () async {
                                print(cancelid);
                                String soapCategory =
                                    '''<?xml version="1.0" encoding="utf-8"?>
                                                           <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                                                             <soap:Body>
                                  <CancelOrder xmlns="http://Craft.WS/">
                                    <OrderID>$cancelid</OrderID>
                                   <ReasonID>${currentSelectedValue.id}</ReasonID>
                                  </CancelOrder>
                                                             </soap:Body>
                                                           </soap:Envelope>''';

                                print(soapCategory);
                                http
                                    .post(
                                        'https://craftapp.net/services/CraftWebService.asmx',
                                        headers: {
                                          "SOAPAction":
                                              "http://Craft.WS/CancelOrder",
                                          "Content-Type":
                                              "text/xml;charset=UTF-8",
                                        },
                                        body: utf8.encode(soapCategory),
                                        encoding: Encoding.getByName("UTF-8"))
                                    .then((onValue) {
                                  return onValue;
                                });

                                await Future.delayed(Duration(seconds: 2));
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WillPopScope(
                                            onWillPop: () async => false,
                                            child: Orders())));
                              }),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: RaisedButton(
                              elevation: 0,
                              color: Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: Text(
                                globals.loc == 'en' ? 'No' : 'لا',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                              }),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RuleWidget extends StatefulWidget {
  final String id;
  final String request;
  final String date;
  final String status;
  RuleWidget(
      {@required this.id,
      @required this.request,
      @required this.date,
      @required this.status});

  @override
  _RuleWidgetState createState() => _RuleWidgetState();
}

class _RuleWidgetState extends State<RuleWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReturnDetails(id: widget.id)));
      },
      child: Container(
        decoration: BoxDecoration(),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      globals.loc == 'en'
                          ? 'Request# ${widget.request}'
                          : 'طلب# ${widget.request}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 10),
                  Text(
                      globals.loc == 'en'
                          ? 'Date: ${widget.date}'
                          : 'التاريخ: ${widget.date}',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  /*  SizedBox(height: 20),
                  Text(
                      globals.loc == 'en'
                          ? 'Items: ${widget.items}'
                          : 'العناصر: ${widget.items}',
                      style: TextStyle(fontSize: 13)) */
                ],
              ),
            ),
            widget.status != ''
                ? SizedBox(width: 20)
                : SizedBox(
                    height: 0,
                  ),
            widget.status != ''
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7.5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow[700])),
                    child: Text(
                      widget.status,
                      style: TextStyle(color: Colors.yellow[700], fontSize: 18),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class Reason {
  final String id;
  final String title;
  Reason({@required this.id, @required this.title});
}
