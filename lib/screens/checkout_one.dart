import 'package:crafts/core/color.dart';
import 'package:crafts/screens/checkout_two.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';

import 'new_address.dart';
import 'package:flutter/cupertino.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CheckoutOne extends StatefulWidget {
  final String name;
  final String email;

  CheckoutOne({@required this.name, @required this.email});

  @override
  _CheckoutOneState createState() => _CheckoutOneState();
}

class _CheckoutOneState extends State<CheckoutOne> {
  List<Address> addresses = <Address>[];
  List<Address> cities = <Address>[];
  List<String> citiesddl = <String>[];
  bool cityreq = false;

  String deliveryType = '';
  String orderID;
  String street;

  Address currentSelectedValue;
  String currentcityValue;

  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();

  TextEditingController addressDetails = new TextEditingController();
  TextEditingController zip = new TextEditingController();
  TextEditingController country = new TextEditingController();

  bool loading = false;
  bool load = false;
  bool loadButton = false;
  String sms = "";
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  void loadData() async {
    setState(() {
      loading = true;
    });
    await getLocations();
    await getCity();
    if (currentSelectedValue != null) {
      await getLocDetails(currentSelectedValue.id);
    }
    await getCheckOut();
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

  Future<void> getLocDetails(String id) async {
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetLocationDetails xmlns="http://Craft.WS/">
      <LocationID>$id</LocationID>
    </GetLocationDetails>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetLocationDetails",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetLocationDetailsResult')[0]
        .text;
    final decoded = jsonDecode(json);
    addressDetails.text = decoded['Addresstxt'];
    country.text = decoded['Country'];

    zip.text = decoded['Zipcode'];

    setState(() {
      street = decoded['neighbourhood'];
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

  Future<void> getCity() async {
    cities = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCities xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetCities>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetCities",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetCitiesResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      cities.add(Address(id: decoded[i]['ID'], title: decoded[i]['Title']));
      citiesddl.add(decoded[i]['Title']);
    }
    if (cities.isNotEmpty) {
      currentcityValue = cities[0].title;
    }
  }

  Future<void> getCheckOut() async {
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCheckoutOne xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id}</CustomerID>
    </GetCheckoutOne>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetCheckoutOne",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetCheckoutOneResult')[0]
        .text;
    final decoded = jsonDecode(json);
    deliveryType = decoded['DeliveryType'];

    name.text = widget.name;
    email.text = widget.email;

    if (widget.name == '') name.text = decoded['Name'];
    orderID = decoded['OrderID'];

    if (name.text == '') name.text = globals.user.name;
  }

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
                      child: Form(
                        key: _formKey,
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
                                    color: Colors.black,
                                    size: 28,
                                  ),
                                  Text(
                                    '•' * 12,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(
                                    Icons.credit_card,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                  Text(
                                    '•' * 12,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
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
                                globals.loc == 'en'
                                    ? 'Step 1'
                                    : 'الخطوة الأولى',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                deliveryType,
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: 
                              TextFormField(
                                  controller: name,
                                  validator: (val) {
                                    if (val.length == 0)
                                      return globals.loc == 'en'
                                          ? 'Required'
                                          : 'مطلوب';
                                    else
                                      return null;
                                  },
                                  enabled: true,
                                  cursorColor: Colors.black,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                  decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      labelStyle: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                      labelText: globals.loc == 'en'
                                          ? 'Name'
                                          : 'الاسم',
                                      isDense: true)),
                            ),
                            globals.user.type == '1'
                                ? SizedBox(height: 15)
                                : SizedBox(height: 0),
                            globals.user.type == '1'
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: TextFormField(
                                        controller: email,
                                        validator: (val) {
                                          if (val.length == 0 &&
                                              globals.user.type == '1')
                                            return globals.loc == 'en'
                                                ? 'Required'
                                                : 'مطلوب';
                                          else
                                            return null;
                                        },
                                        enabled: true,
                                        cursorColor: Colors.black,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22),
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                            labelStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 20),
                                            labelText: globals.loc == 'en'
                                                ? 'Email'
                                                : 'البريد الالكتروني',
                                            isDense: true)),
                                  )
                                : Container(),
                            SizedBox(height: 15),
                            addresses.length == 0
                                ? Container(height: 0, width: 0)
                                : SizedBox(height: 15),
                            addresses.length == 0
                                ? Container(height: 0, width: 0)
                                : Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: 
                                    FormField<String>(
                                      builder: (FormFieldState<String> state) {
                                        return InputDecorator(
                                          decoration: InputDecoration(
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black),
                                              ),
                                              labelStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22),
                                              labelText: globals.loc == 'en'
                                                  ? 'Address'
                                                  : 'العنوان',
                                              isDense: true),
                                          isEmpty: currentSelectedValue == null,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<Address>(
                                              value: currentSelectedValue,
                                              isDense: true,
                                              onChanged:
                                                  (Address newValue) async {
                                                setState(() {
                                                  currentSelectedValue =
                                                      newValue;
                                                  load = true;
                                                });
                                                await getLocDetails(
                                                    currentSelectedValue.id);
                                                setState(() {
                                                  load = false;
                                                });
                                              },
                                              items: addresses
                                                  .map((Address value) {
                                                return DropdownMenuItem<
                                                    Address>(
                                                  value: value,
                                                  child: Text(
                                                    value.title,
                                                    style: TextStyle(
                                                        fontSize: 22,
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
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => NewAddress(
                                                from: "1",
                                                name: name.text,
                                                email: email.text,
                                              )));
                                },
                                child: Container(
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
                                            ? 'Add new address'
                                            : 'اضافة عنوان جديد',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: load
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                yellow),
                                      ),
                                    )
                                  : TextFormField(
                                      minLines: 2,
                                      maxLines: 5,
                                      controller: addressDetails,
                                      enabled: true,
                                      readOnly: true,
                                      cursorColor: Colors.black,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          border: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          labelStyle: TextStyle(
                                              color: Colors.grey, fontSize: 24),
                                          labelText: globals.loc == 'en'
                                              ? 'Delivery Location Details'
                                              : 'تفاصيل موقع التسليم',
                                          isDense: true)),
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: FormField<String>(
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        labelStyle: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22),
                                        labelText: globals.loc == 'en'
                                            ? 'City'
                                            : 'المدينة',
                                        isDense: true),
                                    isEmpty: currentcityValue == null,
                                    child: DropdownButtonHideUnderline( 
                                      child: DropdownSearch<String>(
                                          validator: (String item) {
                                            if (item == null || item == 'يرجى الاختيار' || item == 'Please Select..')
                                              return  globals.loc == 'en'
                                          ? 'Required'
                                          : 'مطلوب';
                                            else
                                              return null;
                                          },
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                                  enabledBorder:
                                                      InputBorder.none),
                                          mode: Mode.DIALOG,
                                          showSelectedItem: true,
                                          showSearchBox: true,
                                          items: citiesddl,
                                          onChanged: (val) {
                                            // print(val);
                                            currentcityValue = val;
                                          },
                                          selectedItem: currentcityValue),
                                    ),
                                  );
                                },
                              ),
                            ),
                            cityreq
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      globals.loc == 'en'
                                          ? 'Please Select City to complete order'
                                          : 'يجب تعبئة المدينة لإتمام الطلب',
                                      style: TextStyle(color: Colors.red),
                                    ))
                                : Container(),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                  controller: zip,
                                  validator: (val) {
                                    if (val.length == 0)
                                      return globals.loc == 'en'
                                          ? 'Required'
                                          : 'مطلوب';
                                    else
                                      return null;
                                  },
                                  enabled: true,
                                  cursorColor: Colors.black,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                  decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      labelStyle: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                      labelText: globals.loc == 'en'
                                          ? 'Zip Code'
                                          : 'الرمز البريدي',
                                      isDense: true)),
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                  enabled: true,
                                  controller: country,
                                  validator: (val) {
                                    if (val.length == 0)
                                      return globals.loc == 'en'
                                          ? 'Required'
                                          : 'مطلوب';
                                    else
                                      return null;
                                  },
                                  cursorColor: Colors.black,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                  decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      labelStyle: TextStyle(
                                          color: Colors.grey, fontSize: 22),
                                      labelText: globals.loc == 'en'
                                          ? 'Country'
                                          : 'البلد',
                                      isDense: true)),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                sms,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
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
                                                    ? 'Continue to Payment'
                                                    : 'مواصلة الدفع',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              onPressed: currentSelectedValue ==
                                                          null ||
                                                      currentcityValue == ''
                                                  ? null
                                                  : () async {
                                                      if (_formKey.currentState
                                                          .validate()) {
                                                        if (currentcityValue ==
                                                                '' ||
                                                            currentcityValue ==
                                                                'Please Select..' ||
                                                            currentcityValue ==
                                                                'يرجى الاختيار') {
                                                          setState(() {
                                                            cityreq = true;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            loadButton = true;
                                                          });
                                                          String soap =
                                                              '''<?xml version="1.0" encoding="utf-8"?>
                              <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                  <soap:Body>
                    <PayLevel1 xmlns="http://Craft.WS/">
                      <OrderID>$orderID</OrderID>
                      <Name>${name.text}</Name>
                      <AddressID>${currentSelectedValue.id}</AddressID>
                      <City>$currentcityValue</City>
                      <ZipCode>${zip.text}</ZipCode>
                      <Country>${country.text}</Country>
                      <Email>${globals.user.type == '1' ? email.text : ''}</Email>
                      
                    </PayLevel1>
                  </soap:Body>
                              </soap:Envelope>''';

                              print(soap);
                                                          http.Response
                                                              response =
                                                              await http
                                                                  .post(
                                                                      'https://craftapp.net/services/CraftWebService.asmx',
                                                                      headers: {
                                                                        "SOAPAction":
                                                                            "http://Craft.WS/PayLevel1",
                                                                        "Content-Type":
                                                                            "text/xml;charset=UTF-8",
                                                                      },
                                                                      body: utf8
                                                                          .encode(
                                                                              soap),
                                                                      encoding:
                                                                          Encoding.getByName(
                                                                              "UTF-8"))
                                                                  .then(
                                                                      (onValue) {
                                                            return onValue;
                                                          });
                                                          String json = parse(
                                                                  response.body)
                                                              .getElementsByTagName(
                                                                  'PayLevel1Result')[0]
                                                              .text;
                                                          final decoded =
                                                              jsonDecode(json);
                                                          setState(() {
                                                            loadButton = false;
                                                            if (decoded[
                                                                    'Flag'] ==
                                                                '-1')
                                                              sms = decoded[
                                                                  "SMS"];
                                                            else {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => CheckoutTwo(
                                                                            city:
                                                                                '$currentcityValue',
                                                                            postcode:
                                                                                '${zip.text}',
                                                                            street:
                                                                                '$street',
                                                                            gustmail:
                                                                                email.text,
                                                                            gustname:
                                                                                name.text,
                                                                                order: orderID,
                                                                          )));
                                                            }
                                                          });
                                                          /*     if (decoded == '1') {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              CheckoutTwo()));
                                                            } else {
                                                              _scaffoldKey
                                                                  .currentState
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text(
                                                                            globals.loc == 'en'
                                                                                ? 'Process Failed'
                                                                                : 'فشلت العملية',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15),
                                                                          ),
                                                                          duration:
                                                                              Duration(seconds: 4)));
                                                            } */
                                                        }
                                                      }
                                                    }),
                                        ),
                                      ],
                                    ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            /*  Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  title: Text(
                                    globals.loc == 'en'
                                        ? 'Delivery & Returns'
                                        : 'التسليم والارجاع',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Icon(
                                    Icons.add,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ) */
                          ],
                        ),
                      ),
                    ),
                  ),
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

class Address {
  final String id;
  final String title;
  Address({@required this.id, @required this.title});
}
