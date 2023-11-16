import 'package:crafts/core/color.dart';
import 'package:crafts/screens/checkout_one.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';

class Bag extends StatefulWidget {
  @override
  _BagState createState() => _BagState();
}

class _BagState extends State<Bag> {
  List<BagWidget> bagWid = <BagWidget>[];
  String subTotal = "0";
  String nodata = "0";
  String mainID = "0";
  String promo = "0";
  String warningflag = "0";
  String smswarning = "";
  bool loading = false;
  String promotionID;
  String sms = "";

  TextEditingController code = new TextEditingController();
  final _codeKey = GlobalKey<FormState>();
  bool loadKey = false;
  void getBag() async {
    smswarning = "";
    bagWid = [];
    setState(() {
      loading = true;
    });
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <MyBagV2 xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </MyBagV2>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/MyBagV2",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('MyBagV2Result')[0].text;
    final decoded = jsonDecode(json);
    if (decoded != "") {
      subTotal = decoded['SubTotal'];
      mainID = decoded['MainID'];
      promo = decoded['promo'];
      warningflag = decoded['warningflag'];

      for (int i = 0; i < decoded['ItemsList'].length; i++) {
        bagWid.add(BagWidget(
          id: decoded['ItemsList'][i]['ID'],
          brand: decoded['ItemsList'][i]['Brand'],
          title: decoded['ItemsList'][i]['Title'],
          by: decoded['ItemsList'][i]['By'],
          currPrice: decoded['ItemsList'][i]['CurrentPrice'],
          oldPrice: decoded['ItemsList'][i]['OldPrice'],
          image: decoded['ItemsList'][i]['Photo'],
          quantity: decoded['ItemsList'][i]['Quantity'],
          custom: decoded['ItemsList'][i]['custom'],
          warning: decoded['ItemsList'][i]['warning'],
          tap: () {
            getBag();
          },
        ));
      }
    } else
      nodata = "1";

    setState(() {
      loading = false;
    });
  }

  bool dialogOpen = false;
  @override
  void initState() {
    super.initState();
    getBag();
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
          : nodata == '0'
              ? dialogOpen
                  ? SingleChildScrollView()
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          AppBarOne(
                            implyLeading: false,
                            text: globals.loc == 'en' ? 'My Bag' : 'الحقيبة',
                            press: () {},
                            textColor: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(height: 15),
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => bagWid[index],
                              itemCount: bagWid.length,
                              separatorBuilder: (context, index) => Divider(),
                            ),
                          ),
                          Container(),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  globals.loc == 'en'
                                      ? 'Subtotal'
                                      : 'المجموع الفرعي',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$subTotal SAR',
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        /*   Divider(), */
                          SizedBox(
                            height: 5,
                          ),
                         /*  Padding(
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
      <OrderID>$mainID</OrderID>
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
                                                                                    getBag();
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
                          ), */
                          SizedBox(
                            height: 20,
                          ),
                          smswarning != ''
                              ? Padding(
                                padding:     EdgeInsets.symmetric(vertical: 10),

                                child: Text(
                                                          
                                    smswarning,
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.red),  textAlign: TextAlign.left,
                                  ),
                              )
                              : Container(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
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
                                            ? 'Check Out'
                                            : 'الدفع',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 17),
                                      ),
                                      onPressed: () async {
                                        if (warningflag == '0') {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CheckoutOne(
                                                        name: '',
                                                        email: ''
                                                      )));
                                        } else {
                                          setState(() {
                                            smswarning = globals.loc == 'en'
                                                ? 'Please check products quantity'
                                                : 'يرجى التحقق من كمية المنتجات';
                                          });
                                        }
                                      }),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RaisedButton(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(),
                                      color: yellow,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 15),
                                      child: Text(
                                        globals.loc == 'en'
                                            ? 'Continue Shopping'
                                            : 'مواصلة التسوق',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WillPopScope(
                                                        onWillPop: () async =>
                                                            false,
                                                        child: Home(
                                                          index: 0,
                                                        ))));
                                      }),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(children: [
                    SizedBox(height: 30),
                    AppBarOne(
                      implyLeading: false,
                      text: globals.loc == 'en' ? 'My Bag' : 'الحقيبة',
                      press: () {},
                      textColor: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Expanded(
                      child: Text(
                          globals.loc == 'en' ? 'Empty Bag' : 'الحقيبة فارغة',
                          style: TextStyle(
                            fontSize: 32,
                          )),
                    ),
                  ])),
    );
  }
}

typedef void VoidCallback();

class BagWidget extends StatefulWidget {
  final String brand;
  final String title;
  final String id;
  final String currPrice;
  final String image;
  final String by;
  final String quantity;
  final String oldPrice;
  final VoidCallback tap;
  final String custom;
  final String warning;

  BagWidget(
      {@required this.brand,
      @required this.tap,
      @required this.title,
      @required this.id,
      @required this.currPrice,
      @required this.image,
      @required this.by,
      @required this.quantity,
      @required this.oldPrice,
      @required this.custom,
      @required this.warning});

  @override
  _BagWidgetState createState() => _BagWidgetState();
}

class _BagWidgetState extends State<BagWidget> {
  int quantity;
  bool load = false;
  @override
  void initState() {
    quantity = int.parse(widget.quantity);
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
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        load = true;
                      });
                      String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <DeleteItemBag xmlns="http://Craft.WS/">
      <ClientID>${globals.user.id}</ClientID>
      <ItemID>${widget.id}</ItemID>
    </DeleteItemBag>
  </soap:Body>
</soap:Envelope>''';
                      http.Response response = await http
                          .post(
                              'https://craftapp.net/services/CraftWebService.asmx',
                              headers: {
                                "SOAPAction": "http://Craft.WS/DeleteItemBag",
                                "Content-Type": "text/xml;charset=UTF-8",
                              },
                              body: utf8.encode(soap),
                              encoding: Encoding.getByName("UTF-8"))
                          .then((onValue) {
                        return onValue;
                      });
                      String json = parse(response.body)
                          .getElementsByTagName('DeleteItemBagResult')[0]
                          .text;
                      final decoded = jsonDecode(json);
                      setState(() {
                      
                        load = false;
                        widget.tap();
                      });

                      /*      Scaffold.of(context)
                          .showSnackBar(SnackBar(
                              content: Text(
                                decoded,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              duration: Duration(seconds: 4)))
                          .closed
                          .then((_) {
                        widget.tap();
                      }); */
                    },
                    child: Container(
                      padding: EdgeInsets.all(1.25),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Hero(
                        tag: '${Icons.close_rounded}' +
                            DateTime.now().toString(),
                        child: Text(
                            String.fromCharCode(Icons.close_rounded.codePoint),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontFamily: Icons.close_rounded.fontFamily,
                                package: Icons.close_rounded.fontPackage)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 120,
                      width: 80,
                      child: ClipRRect(
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(yellow),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
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
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.brand,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 18),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            widget.by,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellow,
                                fontSize: 16),
                          ),
                          widget.custom != ''
                              ? SizedBox(
                                  height: 5,
                                )
                              : Container(),
                          widget.custom != ''
                              ? Text(
                                  widget.custom,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                )
                              : Container(),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.currPrice} SAR',
                                textDirection: TextDirection.ltr,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                                textAlign: TextAlign.right,
                              ),
                              widget.oldPrice != ''
                                  ? Text(
                                      '${widget.oldPrice} SAR',
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    )
                                  : Text('')
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(globals.loc == 'en' ? 'Quantity:' : 'الكمية:',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: quantity <= 0
                                  ? null
                                  : () async {
                                      setState(() {
                                        load = true;
                                        quantity--;
                                      });
                                      String soap =
                                          '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <QuantityItemBag xmlns="http://Craft.WS/">
      <ClientID>${globals.user.id}</ClientID>
      <ItemID>${widget.id}</ItemID>
      <Quantity>${quantity.toString()}</Quantity>
    </QuantityItemBag>
  </soap:Body>
</soap:Envelope>''';
                                      http.Response response = await http
                                          .post(
                                              'https://craftapp.net/services/CraftWebService.asmx',
                                              headers: {
                                                "SOAPAction":
                                                    "http://Craft.WS/QuantityItemBag",
                                                "Content-Type":
                                                    "text/xml;charset=UTF-8",
                                              },
                                              body: utf8.encode(soap),
                                              encoding:
                                                  Encoding.getByName("UTF-8"))
                                          .then((onValue) {
                                        return onValue;
                                      });
                                      String json = parse(response.body)
                                          .getElementsByTagName(
                                              'QuantityItemBagResult')[0]
                                          .text;
                                      final decoded = jsonDecode(json);
                                      setState(() {
                                        load = false;
                                      });
                                          widget.tap();
                                    

                                    },
                              child: Container(
                                decoration: BoxDecoration(),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  color: yellow,
                                  size: 28,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(quantity.toString()),
                            SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  load = true;
                                  quantity++;
                                });
                                String soap =
                                    '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <QuantityItemBag xmlns="http://Craft.WS/">
      <ClientID>${globals.user.id}</ClientID>
      <ItemID>${widget.id}</ItemID>
      <Quantity>${quantity.toString()}</Quantity>
    </QuantityItemBag>
  </soap:Body>
</soap:Envelope>''';
                                http.Response response = await http
                                    .post(
                                        'https://craftapp.net/services/CraftWebService.asmx',
                                        headers: {
                                          "SOAPAction":
                                              "http://Craft.WS/QuantityItemBag",
                                          "Content-Type":
                                              "text/xml;charset=UTF-8",
                                        },
                                        body: utf8.encode(soap),
                                        encoding: Encoding.getByName("UTF-8"))
                                    .then((onValue) {
                                  return onValue;
                                });
                                String json = parse(response.body)
                                    .getElementsByTagName(
                                        'QuantityItemBagResult')[0]
                                    .text;
                                final decoded = jsonDecode(json);
                                setState(() {
                                  load = false;
                                });
                                widget.tap();

                                /*   Scaffold.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Text(
                                          decoded,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        duration: Duration(seconds: 4)))
                                    .closed
                                    .then((_) {
                                  widget.tap();
                                }); */
                              },
                              child: Container(
                                decoration: BoxDecoration(),
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: yellow,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                widget.warning != ''
                    ? Text(
                        widget.warning,
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      )
                    : Container()
              ],
            ),
          );
  }
}
