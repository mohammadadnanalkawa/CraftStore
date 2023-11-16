import 'package:crafts/core/color.dart';
import 'package:crafts/screens/checkout_complete.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/payment.dart';
import 'package:crafts/screens/paymentmada.dart';
import 'package:crafts/screens/paymentstc.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'dart:io' show Platform;

import 'checkout_error.dart';

class CheckoutTwo extends StatefulWidget {
  final String street;
  final String city;
  final String postcode;
  final String gustmail;
  final String gustname;
  final String order;

  CheckoutTwo(
      {@required this.street,
      @required this.city,
      @required this.postcode,
      @required this.gustmail,
      @required this.gustname,
       @required this.order});

  @override
  _CheckoutTwoState createState() => _CheckoutTwoState();
}

class _CheckoutTwoState extends State<CheckoutTwo> {
  static const platform = const MethodChannel('Hyperpay.demo.fultter/channel');
  final _formKey = GlobalKey<FormState>();
  int group = 2;
  bool tap = true;
  TextEditingController code = new TextEditingController();

  String deliveryType = '';
  String orderID;
  String name;
  String subTotal;
  String discount;
  String overTotal;
  String availablebalance;
  bool loading = false;
  bool loadButton = false;
  String brandicon = '';
  String shipvalue = "";
  String shiptax = "";
  String tax = "";
  String promo = "0";
  String sms = "";
  final _codeKey = GlobalKey<FormState>();
  bool loadKey = false;
  String promotionID;


  String brand = 'VISA',
      cardName,
      cardNo,
      cardCvv,
      cardDateMM,
      cardDateYYYY,
      entity = '8ac7a4c97ad2aab7017addf1b2500f93';

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

  Future<void> getCheckOut() async {
  
    setState(() {
      loading = true;
    });
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCheckoutV2 xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetCheckoutV2>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetCheckoutV2",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetCheckoutV2Result')[0]
        .text;
    final decoded = jsonDecode(json);
    deliveryType = decoded['DeliveryType'];
    name = decoded['Name'];
    orderID = decoded['OrderID'];
    subTotal = decoded['SubTotalWithoutTax'];
    discount = decoded['Discount'];
    overTotal = decoded['OverTotal'];
    availablebalance = decoded['Wallet'];
    tax = decoded['tax'];
    shiptax = decoded['shiptax'];
    shipvalue = decoded['shipvalue'];

promo =  decoded['promo'];
    if (decoded['OverTotal'] == '0') {
      group = 5;
    }
      setState(() {
      loading = false;
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  void loadData() async {
    setState(() {
      loading = true;
    });
    await getCheckOut();
    setState(() {
      loading = false;
    });
  }

  bool dialogOpen = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
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
            :  dialogOpen
                  ? SingleChildScrollView()
                  : Column(children: [
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
                          AppBarOne(
                            implyLeading: true,
                            text: globals.loc == 'en' ? 'Checkout' : 'الدفع',
                            press: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WillPopScope(
                                          onWillPop: () async => false,
                                          child: Home(
                                            index: 3,
                                          ))));
                            },
                            textColor: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(height: 15),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: yellow,
                                  size: 28,
                                ),
                                Text(
                                  '•' * 12,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.black,
                                  size: 28,
                                ),
                                Text(
                                  '•' * 12,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.grey,
                                  size: 28,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              globals.loc == 'en' ? 'Step 2' : 'الخطوة الثانية',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              globals.loc == 'en'
                                  ? 'Payment Options'
                                  : 'طرق الدفع',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 25),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              globals.loc == 'en'
                                  ? 'Order Details'
                                  : 'تفاصيل الطلب',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 15),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  globals.loc == 'en'
                                      ? 'Subtotal'
                                      : 'المجموع الفرعي',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '$subTotal SAR',
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 7.5),
                          discount == ''
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        globals.loc == 'en'
                                            ? 'Discount'
                                            : 'الخصم',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '$discount SAR',
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                          availablebalance != '0'
                              ? SizedBox(height: 7.5)
                              : SizedBox(height: 0),
                          availablebalance != '0'
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        globals.loc == 'en'
                                            ? 'Wallet balance'
                                            : 'رصيد المحفظة',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '$availablebalance',
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                          availablebalance != '0' && discount == ''
                              ? SizedBox(height: 7.5)
                              : SizedBox(height: 0),
                          discount == ''
                              ? SizedBox(
                                  height: 0,
                                )
                              : SizedBox(height: 7.5),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  globals.loc == 'en'
                                      ? 'Shipping Fee'
                                      : 'قيمة الشحن ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '$shipvalue SAR',
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 7.5),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  globals.loc == 'en'
                                      ? 'VAT '
                                      : 'ضريبة القيمة المضافة  ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '$tax SAR',
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 7.5),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  globals.loc == 'en'
                                      ? 'Shippment VAT '
                                      : 'ضريبة الشحن  ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '$shiptax SAR',
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 7.5),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  globals.loc == 'en'
                                      ? 'Grand Total'
                                      : 'الإجمالي',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${double.parse(overTotal).toStringAsFixed(2)} SAR',
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  sms = "";

                                  dialogOpen = true;
                                });
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dcontext) => StatefulBuilder(
                                    builder: (bcontext, settState) {
                                      return WillPopScope(
                                        onWillPop: () async {
                                          setState(() {
                                            dialogOpen = false;
                                          });

                                          return true;
                                        },
                                        child: Dialog(
                                          child: Directionality(
                                            textDirection: globals.loc == 'ar'
                                                ? TextDirection.rtl
                                                : TextDirection.ltr,
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              child: Form(
                                                key: _codeKey,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Align(
                                                          alignment:
                                                              globals.loc ==
                                                                      'en'
                                                                  ? Alignment
                                                                      .topLeft
                                                                  : Alignment
                                                                      .topRight,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context,
                                                                  false);
                                                              setState(() {
                                                                dialogOpen =
                                                                    false;
                                                              });
                                                            },
                                                            child: Text(
                                                                globals.loc ==
                                                                        'en'
                                                                    ? 'Done'
                                                                    : 'اغلاق',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 22,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                )),
                                                          )),
                                                    ),
                                                    TextFormField(
                                                        controller: code,
                                                        validator: (val) {
                                                          if (val.length == 0)
                                                            return globals
                                                                        .loc ==
                                                                    'en'
                                                                ? 'Required'
                                                                : 'مطلوب';
                                                          else
                                                            return null;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                                prefixIcon:
                                                                    Icon(Icons.local_offer_outlined,
                                                                        size:
                                                                            22),
                                                                hintText: globals
                                                                            .loc ==
                                                                        'en'
                                                                    ? 'Promo code...'
                                                                    : "كود الخصم...",
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.transparent),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.transparent),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.red),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.red),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.transparent),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                filled: true,
                                                                fillColor:
                                                                    Colors.grey[
                                                                        200],
                                                                isDense: true)),
                                                    SizedBox(height: 20),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10),
                                                      child: Text(
                                                        sms,
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 22),
                                                      ),
                                                    ),
                                                    loadKey
                                                        ? Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  new AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      yellow),
                                                            ),
                                                          )
                                                        : Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    RaisedButton(
                                                                        elevation:
                                                                            0,
                                                                        shape:
                                                                            RoundedRectangleBorder(),
                                                                        color:
                                                                            yellow,
                                                                        padding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                20,
                                                                            horizontal:
                                                                                15),
                                                                        child:
                                                                            Text(
                                                                          globals.loc == 'en'
                                                                              ? 'Add'
                                                                              : 'اضف',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 17),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          if (_codeKey
                                                                              .currentState
                                                                              .validate()) {
                                                                            settState(() {
                                                                              loadKey = true;
                                                                            });
                                                                            String
                                                                                soapLogin =
                                                                                '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <AddPromo xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
      <PromoCode>${code.text}</PromoCode>
      <OrderID>${widget.order}</OrderID>
    </AddPromo>
  </soap:Body>
</soap:Envelope>''';
                                                                            http.Response responseLogin = await http
                                                                                .post('https://craftapp.net/services/CraftWebService.asmx',
                                                                                    headers: {
                                                                                      "SOAPAction": "http://Craft.WS/AddPromo",
                                                                                      "Content-Type": "text/xml;charset=UTF-8",
                                                                                    },
                                                                                    body: utf8.encode(soapLogin),
                                                                                    encoding: Encoding.getByName("UTF-8"))
                                                                                .then((onValue) {
                                                                              return onValue;
                                                                            });
                                                                            settState(() {
                                                                              loadKey = false;
                                                                            });
                                                                            print(responseLogin.body);
                                                                            if (responseLogin.statusCode ==
                                                                                200) {
                                                                              String json = parse(responseLogin.body).getElementsByTagName('AddPromoResult')[0].text;
                                                                              final decodedLogin = jsonDecode(json);
                                                                              // Navigator.pop(context);

                                                                              if (mounted) {
                                                                                setState(() {
                                                                                  dialogOpen = false;
                                                                                  promotionID = decodedLogin['flag'];
                                                                                  if (promotionID != '0') {
                                                                                    getCheckOut();
                                                                                    Navigator.pop(context, false);
                                                                                  } else
                                                                                    sms = decodedLogin['message'];
                                                                                });
                                                                                /*  Scaffold.of(context).showSnackBar(SnackBar(content: Text(decodedLogin['message']), duration: Duration(seconds: 4))).closed.then((value) {
                                                                                  if (promotionID != '0') {
                                                                                    getBag();
                                                                                  } */
                                                                                //  });
                                                                              }
                                                                            }
                                                                          }
                                                                        }),
                                                              ),
                                                            ],
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: promo == ''
                                  ? Container(
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        children: [
                                          Icon(Icons.add_circle),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: Text(
                                            globals.loc == 'en'
                                                ? 'Add Promo Code'
                                                : 'أضف الرمز الترويجي',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17),
                                          ))
                                        ],
                                      ))
                                  : Container(
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            globals.loc == 'en'
                                                ? 'Promo Code used ' + promo
                                                : ' الرمز الترويجي المستخدم  ' +
                                                    promo,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17),
                                          ))
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 30,
                          ),
                          group == 5
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  child: Text(
                                    globals.loc == 'en'
                                        ? 'The wallet balance will be deducted'
                                        : 'سيتم الخصم من رصيد المحفظة',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          globals.loc == 'en'
                                              ? 'Select only one option'
                                              : 'حدد خيارًا واحدًا فقط',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                child: Row(
                                              children: [
                                                Radio(
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  value: 2,
                                                  groupValue: group,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      group = value;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  globals.loc == 'en'
                                                      ? 'Pay with'
                                                      : 'الدفع من خلال',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ],
                                            )),
                                            Container(
                                              child: Row(children: [
                                                Container(
                                                    child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 3,
                                                      vertical: 1),
                                                  child: Image.asset(
                                                    'assets/madapay.png',
                                                    width: 60,
                                                    height: 40,
                                                  ),
                                                )),
                                              ]),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                child: Row(
                                              children: [
                                                Radio(
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  value: 1,
                                                  groupValue: group,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      group = value;
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  globals.loc == 'en'
                                                      ? 'Pay with'
                                                      : 'الدفع من خلال',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ],
                                            )),
                                            Container(
                                              child: Row(children: [
                                                Container(
                                                    child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 3,
                                                      vertical: 1),
                                                  child: Image.asset(
                                                    'assets/visapay.png',
                                                    width: 60,
                                                    height: 40,
                                                  ),
                                                )),
                                                Container(
                                                    child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 3,
                                                      vertical: 1),
                                                  child: Image.asset(
                                                    'assets/masterpay.png',
                                                    width: 60,
                                                    height: 40,
                                                  ),
                                                )),
                                              ]),
                                            )
                                          ],
                                        ),
                                      ),
                                      Platform.isIOS
                                          ? Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        Radio(
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          value: 4,
                                                          groupValue: group,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              group = value;
                                                            });
                                                          },
                                                        ),
                                                        Text(
                                                          globals.loc == 'en'
                                                              ? 'Pay with'
                                                              : 'الدفع من خلال',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 17,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                      child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 3,
                                                            vertical: 1),
                                                    child: Image.asset(
                                                      'assets/applepay.png',
                                                      width: 60,
                                                      height: 40,
                                                    ),
                                                  ))
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Radio(
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      value: 3,
                                                      groupValue: group,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          group = value;
                                                        });
                                                      }),
                                                  Text(
                                                    globals.loc == 'en'
                                                        ? 'Pay with'
                                                        : 'الدفع من خلال',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3, vertical: 1),
                                              child: Image.asset(
                                                'assets/stcpay.png',
                                                width: 60,
                                                height: 40,
                                              ),
                                            ))
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: loadButton
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
                                          shape: RoundedRectangleBorder(),
                                          color: Colors.grey[800],
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 15),
                                          child: Text(
                                            globals.loc == 'en'
                                                ? 'Pay Now'
                                                : 'ادفع الان',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            if (group == 1) {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => Payment(
                                                          isorder: '1',
                                                          email:
                                                              widget.gustmail,
                                                          username:
                                                              widget.gustname,
                                                          city: widget.city,
                                                          postcode:
                                                              widget.postcode,
                                                          street: widget.street,
                                                          orderID: orderID,
                                                          amount: double.parse(
                                                                  overTotal)
                                                              .toStringAsFixed(
                                                                  2))));
                                            } else if (group == 2) {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PaymentMada(
                                                              isorder: '1',
                                                              email: widget
                                                                  .gustmail,
                                                              username: widget
                                                                  .gustname,
                                                              city: widget.city,
                                                              postcode: widget
                                                                  .postcode,
                                                              street:
                                                                  widget.street,
                                                              orderID: orderID,
                                                              amount: double.parse(
                                                                      overTotal)
                                                                  .toStringAsFixed(
                                                                      2))));
                                            } else if (group == 3) {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PaymentStc(
                                                              isorder: '1',
                                                              email: widget
                                                                  .gustmail,
                                                              username:
                                                                  widget
                                                                      .gustname,
                                                              city: widget.city,
                                                              postcode:
                                                                  widget
                                                                      .postcode,
                                                              street: widget
                                                                  .street,
                                                              orderID: orderID,
                                                              amount: double.parse(
                                                                      overTotal)
                                                                  .toStringAsFixed(
                                                                      2))));
                                            } else if (group == 5) {
                                              String soap =
                                                  '''<?xml version="1.0" encoding="utf-8"?>
                                <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                                      <soap:Body>
                      <PayLevel2 xmlns="http://Craft.WS/">
                        <OrderID>$orderID</OrderID>
                        <PaymentType>4</PaymentType>
                        <CreditNumber></CreditNumber>
                        <ExpDate></ExpDate>
                        <CreditHolder></CreditHolder>
                        <CustomerID>${globals.user.id}</CustomerID>
                        <CVV></CVV>
                        <billid>${'W-' + orderID}</billid>
                        <billdesc>Transaction succeeded</billdesc>
                        <billcode>000.000.000</billcode>

                      </PayLevel2>
                                      </soap:Body>
                                </soap:Envelope>''';

                                              http.Response response2 =
                                                  await http
                                                      .post(
                                                          'https://craftapp.net/services/CraftWebService.asmx',
                                                          headers: {
                                                            "SOAPAction":
                                                                "http://Craft.WS/PayLevel2",
                                                            "Content-Type":
                                                                "text/xml;charset=UTF-8",
                                                          },
                                                          body:
                                                              utf8.encode(soap),
                                                          encoding: Encoding
                                                              .getByName(
                                                                  "UTF-8"))
                                                      .then((onValue) {
                                                return onValue;
                                              });
                                              setState(() {
                                                loading = false;
                                              });

                                              String json2 =
                                                  parse(response2.body)
                                                      .getElementsByTagName(
                                                          'PayLevel2Result')[0]
                                                      .text;
                                              final decoded2 =
                                                  jsonDecode(json2);

                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CheckoutComplete(
                                                            isorder: '1',
                                                            orderID: orderID,
                                                            total: double.parse(
                                                                    overTotal)
                                                                .toStringAsFixed(
                                                                    2),
                                                          )));
                                            } else if (group == 4) {
                                              if (tap == false) {
                                              } else {
                                                setState(() {
                                                  tap = false;
                                                });
                                                Future.delayed(
                                                    Duration(seconds: 3), () {
                                                  setState(() {
                                                    tap = true;
                                                  });
                                                });

                                                String checkoutID = '';
                                                var headers = {
                                                  'Authorization':
                                                      'Bearer OGFjZGE0Y2E3YmU4NThmNjAxN2JmZDljY2EyMTQzZGN8bW01UHhja25EZQ==',
                                                  'Content-Type':
                                                      'application/x-www-form-urlencoded',
                                                  'Cookie':
                                                      'ak_bmsc=C19285FEC3E9A212B393CB465EC43D5F~000000000000000000000000000000~YAAQbkZYaArYWSh7AQAAAcffbQx9BX3E9ut8z65tXpxwp/pubB3s/BNOaYd3VxP6PyYbZ9wuqZ7IXYr7FB/LvwL3xh3nOi0RXeYYc9GKxonahVatMOyXuGqk4++heLh3UQlnvB7ZT5YGbgAYf2TC2wfoITLXL84XDsJzYLUYJHHHmTqer0YZ3uNWl6BVYgygHkVO0WlYq/bPca07VyhieulgvLDGYTzaMAAHoOoJNUKbTPIXs2+pWQeO4FPnQtWpAYlvKLkOQRtVK4vkWxyxcKMdyk6YXjT3tSijUSCckiAoTFsOYT/KSVbRYQWTjAbWG9POqgi+4r2RahWxQqpwAXTlMIBMmFr8aQC3TTZ7Fp8DU7+lKtNieUAc4PI=; bm_sv=500E59A08A7078190479D673798D8FB5~CkRAUDsUOtuCqy69l5/78uJlvwn3/AMsnj3EXbaDLaLv9LYs0VLIKfizgAoy/4CftCIYmi26vJJBWhd3+LkXUSHOe8Qit3UHEq9Dv15aXmeJQWoPev/JUa3w6fzPma3bK9fBZOYBKmcvk6VvjDeJZeKIre5/Ib3pWUPulJoYtZs='
                                                };
                                                var request = http.Request(
                                                    'POST',
                                                    Uri.parse(
                                                        'https://oppwa.com/v1/checkouts'));
                                                request.bodyFields = {
                                                  'entityId':
                                                      '8acda4c77c07d106017c0860e5f60e68',
                                                  'amount':
                                                      '${double.parse(overTotal).toStringAsFixed(2)}',
                                                  'currency': 'SAR',
                                                  'paymentType': 'DB',
                                                  'merchantTransactionId':
                                                      '$orderID',
                                                  'customer.email':
                                                      '${globals.user.email == '' ? widget.gustmail : globals.user.email}',
                                                  'billing.street1':
                                                      '${widget.street}',
                                                  'billing.city':
                                                      '${widget.city}',
                                                  'billing.state':
                                                      '${widget.city}',
                                                  'billing.postcode':
                                                      '${widget.postcode}',
                                                  'customer.surname':
                                                      '${globals.user.name == '' ? widget.gustname : globals.user.name}',
                                                  'customer.givenName':
                                                      '${globals.user.name == '' ? widget.gustname : globals.user.name}',
                                                  'billing.country': 'SA',
                                                };
                                                request.headers.addAll(headers);

                                                http.StreamedResponse response =
                                                    await request.send();
                                                String json;
                                                if (response.statusCode ==
                                                    200) {
                                                  json = await response.stream
                                                      .bytesToString();
                                                } else {
                                                  print(response.reasonPhrase);
                                                }
                                                final decoded =
                                                    jsonDecode(json);
                                                checkoutID = decoded['id'];
                                                String transactionStatus;
                                                try {
                                                  final String result =
                                                      await platform.invokeMethod(
                                                          'gethyperpayresponse',
                                                          {
                                                        "amount": double.parse(
                                                            overTotal),
                                                        "type": "ReadyUI",
                                                        "mode": "LIVE",
                                                        "checkoutid":
                                                            checkoutID,
                                                        "brand": "APPLEPAY",
                                                      });
                                                  transactionStatus = '$result';
                                                } on PlatformException catch (e) {
                                                  transactionStatus =
                                                      "${e.message}";
                                                }

                                                if (transactionStatus != null ||
                                                    transactionStatus ==
                                                        "success" ||
                                                    transactionStatus ==
                                                        "SYNC") {
                                                  print(transactionStatus);
                                                  var headers = {
                                                    'Authorization':
                                                        'Bearer OGFjZGE0Y2E3YmU4NThmNjAxN2JmZDljY2EyMTQzZGN8bW01UHhja25EZQ==',
                                                    'Cookie':
                                                        'ak_bmsc=9F01A4B7085637DE3B05061F2DFD53CF~000000000000000000000000000000~YAAQF+scuBMenJ16AQAADUm3cQyumPt4zBOsXlGB2LDQqXA/GODYSndAPHKra8NCEwPlRdYF7Jk1Cml1M48Nj6ey3reLFu+TTNryvGY9Rd4Tsgxx5XmK4Qcyxdff0h0gsfPjVKe7Dl3n591yIzzPszOGk5j28lCSOL2Z/GfPX7kdVdyUtKVNkbnVsnu4akENE4+xK5kex8FSVutm7fPxr0K+3sIr4MH0t7Bpha8GjIRzrFxrFR432W6uLcJezBqqzxadeF0o9wVnGHswXu7x9K0aDcCoW7ed6IqPlTt/QFyWPmZRvmPdE4ZD0FIYIyzlZU6ZuajyP3UYwBSIh6WlJJpH8a8VAD2/YIFG4TtWtZsk0D3KYoEGv4ivew==; bm_sv=B989EB900290E3E4C14C4F9936C42CE9~vN4XcwPB42EGfB6BYIsACkvmM1praH4dK9gRjFdl5ELUy2gSs7j89ScdRXeov6jFdS/l+Ks2P4JsDlitr43bI0QwBbHI4N+Cog4XJyvd/K8D+G97jGYaeI4LJOLIDWUJbSn3YlMVeP5ThC+kS8gK/+3MbPaTrm9KxejpCk2KHXQ='
                                                  };
                                                  var request = http.Request(
                                                      'GET',
                                                      Uri.parse(
                                                          'https://oppwa.com/v1/checkouts/$checkoutID/payment?entityId=8acda4c77c07d106017c0860e5f60e68'));

                                                  request.headers
                                                      .addAll(headers);

                                                  http.StreamedResponse
                                                      response =
                                                      await request.send();

                                                  String json;
                                                  json = await response.stream
                                                      .bytesToString();

                                                  print(json);
                                                  final data = jsonDecode(json);

                                                  print(data['result']['code']);
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  String soap =
                                                      '''<?xml version="1.0" encoding="utf-8"?>
                                <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                                      <soap:Body>
                      <PayLevel2 xmlns="http://Craft.WS/">
                        <OrderID>$orderID</OrderID>
                        <PaymentType>4</PaymentType>
                        <CreditNumber></CreditNumber>
                        <ExpDate></ExpDate>
                        <CreditHolder></CreditHolder>
                        <CustomerID>${globals.user.id}</CustomerID>
                        <CVV></CVV>
                        <billid>$checkoutID</billid>
                        <billdesc>${data['result']['description']}</billdesc>
                        <billcode>${data['result']['code']}</billcode>

                      </PayLevel2>
                                      </soap:Body>
                                </soap:Envelope>''';
                                                  http.Response response2 =
                                                      await http
                                                          .post(
                                                              'https://craftapp.net/services/CraftWebService.asmx',
                                                              headers: {
                                                                "SOAPAction":
                                                                    "http://Craft.WS/PayLevel2",
                                                                "Content-Type":
                                                                    "text/xml;charset=UTF-8",
                                                              },
                                                              body: utf8
                                                                  .encode(soap),
                                                              encoding: Encoding
                                                                  .getByName(
                                                                      "UTF-8"))
                                                          .then((onValue) {
                                                    return onValue;
                                                  });
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  try {
                                                    String json2 = parse(
                                                            response2.body)
                                                        .getElementsByTagName(
                                                            'PayLevel2Result')[0]
                                                        .text;
                                                    final decoded2 =
                                                        jsonDecode(json2);
                                                  } catch (e) {}

                                                  RegExp regExp = new RegExp(
                                                    r"^(000\.000\.|000\.100\.1|000\.[36])",
                                                    caseSensitive: false,
                                                    multiLine: false,
                                                  );
                                                  RegExp regExp2 = new RegExp(
                                                    r"^(000\.400\.0[^3]|000\.400\.100)",
                                                    caseSensitive: false,
                                                    multiLine: false,
                                                  );

                                                  if (regExp.hasMatch(
                                                          data['result']
                                                              ['code']) ||
                                                      regExp2.hasMatch(
                                                          data['result']
                                                              ['code'])) {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    Navigator.pop(context);
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CheckoutComplete(
                                                                  isorder: '1',
                                                                  orderID:
                                                                      orderID,
                                                                  total: double
                                                                          .parse(
                                                                              overTotal)
                                                                      .toStringAsFixed(
                                                                          2),
                                                                )));
                                                  } else {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    Navigator.pop(context);
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CheckoutError(
                                                                  orderID:
                                                                      orderID,
                                                                  error: data[
                                                                          'result']
                                                                      [
                                                                      'description'],
                                                                )));
                                                  }
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                )
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
