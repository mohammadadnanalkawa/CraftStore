import 'package:auto_size_text/auto_size_text.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/core/hex_color.dart';
import 'package:crafts/screens/orders.dart';
import 'package:crafts/screens/rules.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'return_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';

class ConfirmReturn extends StatefulWidget {
  final List<Product> selected;
  ConfirmReturn({@required this.selected});
  @override
  _ConfirmReturnState createState() => _ConfirmReturnState();
}

class _ConfirmReturnState extends State<ConfirmReturn> {
  List<Address> addresses = <Address>[];
  Address currentSelectedValue;

  bool bottom = true;
  String refund = '1';
  bool loadReturn = false;
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  List<Reason> reasons = <Reason>[];
  bool showppay = false;
  List<ItemWidget> items = <ItemWidget>[];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String sms = "";
  void loadData() async {
    setState(() {
      loading = true;
    });
    await getLocations();

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetReason xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetReason>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetReason",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });

    for (int i = 0; i < widget.selected.length; i++) {
      reasons = [];
      if (response.statusCode == 200) {
        print(response.body);
        String json = parse(response.body)
            .getElementsByTagName('GetReasonResult')[0]
            .text;
        final decoded = jsonDecode(json);
        print(decoded);
        for (int x = 0; x < decoded.length; x++) {
          if (widget.selected[i].groupprod == '1' && decoded[x]['Type'] == '0')
            reasons.add(Reason(
                id: decoded[x]['ID'],
                title: decoded[x]['Title'],
                type: decoded[x]['Type']));
          else if (widget.selected[i].groupprod == '2' &&
              decoded[x]['Type'] == '1')
            reasons.add(Reason(
                id: decoded[x]['ID'],
                title: decoded[x]['Title'],
                type: decoded[x]['Type']));
        }
      }
      if (showppay == false && widget.selected[i].groupprod == "1")
        showppay = true;

      items.add(ItemWidget(
        brand: widget.selected[i].brand,
        reason: reasons,
        by: widget.selected[i].by,
        title: widget.selected[i].title,
        id: widget.selected[i].id,
        price: widget.selected[i].price,
        image: widget.selected[i].image,
        quantity: widget.selected[i].quantity.toString(),
        returnflag: widget.selected[i].returnflag,
        group: widget.selected[i].groupprod,
      ));
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getLocations() async {
    addresses = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetLocations xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetLocations>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetLocations",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetLocationsResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      addresses.add(Address(id: decoded[i]['ID'], title: decoded[i]['Title']));
    }
    if (addresses.isNotEmpty) {
      currentSelectedValue = addresses[0];
    }
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  BuildContext parentContext;
  @override
  Widget build(BuildContext context) {
    parentContext = context;
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
                          child: Form(
                            key: formKey,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              shrinkWrap: true,
                              itemCount: items.length,
                              itemBuilder: (context, index) => items[index],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    sms,
                    style: TextStyle(color: Colors.red, fontSize: 22),
                  ),
                ),
              ]),
        bottomNavigationBar: !bottom
            ? Container(width: 0, height: 0)
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: RaisedButton(
                          elevation: 0,
                          shape: RoundedRectangleBorder(),
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child: Text(
                            globals.loc == 'en'
                                ? 'Return Items'
                                : 'إرجاع العناصر',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20),
                          ),
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              setState(() {
                                bottom = false;
                              });
                              showModalBottomSheet(
                                context: context,
                                isDismissible: false,
                                enableDrag: false,
                                builder: (context) {
                                  return Directionality(
                                    textDirection: globals.loc == 'en'
                                        ? TextDirection.ltr
                                        : TextDirection.rtl,
                                    child: StatefulBuilder(
                                      builder: (context, settState) {
                                        return WillPopScope(
                                          onWillPop: () {
                                            setState(() {
                                              bottom = true;
                                            });
                                            return Future.value(true);
                                          },
                                          child: loadReturn
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        valueColor:
                                                            new AlwaysStoppedAnimation<
                                                                Color>(yellow),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[200]),
                                                  padding: EdgeInsets.only(
                                                      bottom: 20,
                                                      left: 20,
                                                      right: 20,
                                                      top: 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                                  globals.loc ==
                                                                          'en'
                                                                      ? 'Pickup Location'
                                                                      : 'موقع الاستلام',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          Spacer(),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              setState(() {
                                                                bottom = true;
                                                              });
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child: Icon(
                                                                  Icons.close,
                                                                  size: 18),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 20),
                                                        child:
                                                            FormField<String>(
                                                          builder:
                                                              (FormFieldState<
                                                                      String>
                                                                  state) {
                                                            return InputDecorator(
                                                              decoration:
                                                                  InputDecoration(
                                                                      enabledBorder:
                                                                          UnderlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(color: Colors.black),
                                                                      ),
                                                                      focusedBorder:
                                                                          UnderlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(color: Colors.black),
                                                                      ),
                                                                      border:
                                                                          UnderlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(color: Colors.black),
                                                                      ),
                                                                      labelStyle: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              26),
                                                                      labelText: globals.loc ==
                                                                              'en'
                                                                          ? 'Address'
                                                                          : 'العنوان',
                                                                      isDense:
                                                                          true),
                                                              isEmpty:
                                                                  currentSelectedValue ==
                                                                      null,
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    DropdownButton<
                                                                        Address>(
                                                                  value:
                                                                      currentSelectedValue,
                                                                  isDense: true,
                                                                  onChanged:
                                                                      (Address
                                                                          newValue) async {
                                                                    settState(
                                                                        () {
                                                                      currentSelectedValue =
                                                                          newValue;
                                                                    });
                                                                  },
                                                                  items: addresses
                                                                      .map((Address
                                                                          value) {
                                                                    return DropdownMenuItem<
                                                                        Address>(
                                                                      value:
                                                                          value,
                                                                      child:
                                                                          Text(
                                                                        value
                                                                            .title,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                      Divider(),
                                                      showppay == false 
                                                          ? Container()
                                                          : Text(
                                                              globals.loc ==
                                                                      'en'
                                                                  ? 'In Return case once we receive the items, how would you prefer the refund?'
                                                                  : 'في حالة الاسترجاع بمجرد استلام العناصر، كيف تفضل استرداد الأموال؟',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: HexColor(
                                                                      '#e85d64')),
                                                            ),
                                                      showppay == false &&
                                                              globals.user
                                                                      .type ==
                                                                  '0'
                                                          ? Container()
                                                          : SizedBox(
                                                              height: 15),
                                                      (showppay == false ) ||
                                                              globals.user
                                                                      .type !=
                                                                  '0'
                                                          ? Container()
                                                          : Row(
                                                              children: [
                                                                Radio(
                                                                    value: '0',
                                                                    groupValue:
                                                                        refund,
                                                                    onChanged:
                                                                        (value) {
                                                                      settState(
                                                                          () {
                                                                        refund =
                                                                            value;
                                                                      });
                                                                    }),
                                                                Expanded(
                                                                  child: Text(
                                                                    globals.loc ==
                                                                            'en'
                                                                        ? 'Wallet balance'
                                                                        : 'رصيد المحفظة',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                      showppay == false 
                                                          ? Container()
                                                          : Row(
                                                              children: [
                                                                Radio(
                                                                    value: '1',
                                                                    groupValue:
                                                                        refund,
                                                                    onChanged:
                                                                        (value) {
                                                                      settState(
                                                                          () {
                                                                        refund =
                                                                            value;
                                                                      });
                                                                    }),
                                                                Expanded(
                                                                  child: Text(
                                                                    globals.loc ==
                                                                            'en'
                                                                        ? 'Credit/Debit Card'
                                                                        : 'بطاقة الائتمان/الخصم',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 20),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  RaisedButton(
                                                                      elevation:
                                                                          0,
                                                                      shape:
                                                                          RoundedRectangleBorder(),
                                                                      color: Colors
                                                                          .black,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              15,
                                                                          horizontal:
                                                                              15),
                                                                      child: Text(
                                                                          globals.loc == 'en'
                                                                              ? 'Continue'
                                                                              : 'متابعة',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              color: Colors
                                                                                  .white,
                                                                              fontSize:
                                                                                  20)),
                                                                      onPressed:
                                                                          () async {
                                                                        settState(
                                                                            () {
                                                                          loadReturn =
                                                                              true;
                                                                        });
                                                                        List<String>
                                                                            prices =
                                                                            <String>[];
                                                                        List<String>
                                                                            reasonID =
                                                                            <String>[];
                                                                        List<String>
                                                                            returnID =
                                                                            <String>[];
                                                                        List<String>
                                                                            typeID =
                                                                            <String>[];
                                                                        for (int i =
                                                                                0;
                                                                            i < items.length;
                                                                            i++) {
                                                                          reasonID.add(items[i]
                                                                              .selected
                                                                              .id);
                                                                          returnID
                                                                              .add(items[i].id);
                                                                          typeID
                                                                              .add(items[i].group);

                                                                          prices
                                                                              .add(items[i].price);
                                                                        }
                                                                        String
                                                                            reasons =
                                                                            reasonID.join(',');
                                                                        String
                                                                            returns =
                                                                            returnID.join(',');
                                                                        String
                                                                            types =
                                                                            typeID.join(',');

                                                                        String
                                                                            priceall =
                                                                            prices.join(',');
                                                                        String
                                                                            soap =
                                                                            '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ReturnItem xmlns="http://Craft.WS/">
      <ReturnID>$returns</ReturnID>
      <ReasonID>$reasons</ReasonID>
      <ReturnOption>$refund</ReturnOption>
      <CustomerID>${globals.user.id}</CustomerID>
    <ReturnFlag>$types</ReturnFlag>
    <LocationID>${currentSelectedValue.id}</LocationID>
    <Prices>$priceall</Prices>

    </ReturnItem>
  </soap:Body>
</soap:Envelope>''';
                                                                        http.Response response = await http
                                                                            .post('https://craftapp.net/services/CraftWebService.asmx',
                                                                                headers: {
                                                                                  "SOAPAction": "http://Craft.WS/ReturnItem",
                                                                                  "Content-Type": "text/xml;charset=UTF-8",
                                                                                },
                                                                                body: utf8.encode(soap),
                                                                                encoding: Encoding.getByName("UTF-8"))
                                                                            .then((onValue) {
                                                                          return onValue;
                                                                        });
                                                                        String json = parse(response.body)
                                                                            .getElementsByTagName('ReturnItemResult')[0]
                                                                            .text;
                                                                        final decoded =
                                                                            jsonDecode(json);
                                                                        settState(
                                                                            () {
                                                                          loadReturn =
                                                                              false;

                                                                          if (decoded['Flag'] ==
                                                                              '-1')
                                                                            sms =
                                                                                decoded["SMS"];
                                                                          else {
                                                                            Navigator.pop(parentContext);
                                                                            Navigator.pop(parentContext);
                                                                            Navigator.pushReplacement(parentContext,
                                                                                MaterialPageRoute(builder: (context) => Orders()));

                                                                            MaterialPageRoute(builder: (context) => Account());
                                                                          }
                                                                        });
                                                                        /*  Navigator.pop(
                                                                            context);
                                                                        _scaffoldKey
                                                                            .currentState
                                                                            .showSnackBar(SnackBar(
                                                                                content: Text(
                                                                                  json,
                                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                                ),
                                                                                duration: Duration(seconds: 4)))
                                                                            .closed
                                                                            .then((_) {
                                                                          Navigator.pop(
                                                                              parentContext);
                                                                          Navigator.pop(
                                                                              parentContext);
                                                                          Navigator.pushReplacement(
                                                                              parentContext,
                                                                              MaterialPageRoute(builder: (context) => Orders()));
                                                                        }); */
                                                                      }),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            }
                          }),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ItemWidget extends StatefulWidget {
  final List<Reason> reason;
  Reason selected;
  final String by;
  final String brand;
  final String title;
  final String id;
  final String price;
  final String image;
  final String quantity;
  final String returnflag;
  String group;

  ItemWidget({
    @required this.brand,
    @required this.reason,
    @required this.by,
    @required this.title,
    @required this.id,
    @required this.price,
    @required this.image,
    @required this.quantity,
    @required this.returnflag,
    @required this.group,
  });

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
              ClipRRect(
                  child: widget.image == ''
                      ? Container()
                      : Image.network(
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
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      widget.brand,
                      style: TextStyle(color: Colors.grey[700], fontSize: 17),
                    ),
                    SizedBox(
                      height: 3,
                    ),
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
                    )
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(globals.loc == 'en' ? 'Reason' : 'سبب',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: DropdownButtonFormField<Reason>(
                  isDense: true,
                  hint: Text(globals.loc == 'en' ? 'Select' : 'يختار',
                      style: TextStyle(fontSize: 18)),
                  onChanged: (value) {
                    setState(() {
                      widget.selected = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return '';
                    } else
                      return null;
                  },
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                  value: widget.selected,
                  items: widget.reason.map((e) {
                    return DropdownMenuItem<Reason>(
                      value: e,
                      child: Text(
                        e.title,
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class Reason {
  final String id;
  final String title;
  final String type;

  Reason({@required this.id, @required this.title, @required this.type});
}

class Address {
  final String id;
  final String title;
  Address({@required this.id, @required this.title});
}
