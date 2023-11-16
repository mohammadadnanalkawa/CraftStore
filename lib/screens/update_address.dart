import 'dart:io';

import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:crafts/screens/addresses.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:crafts/core/color.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:location/location.dart' as loccheck;
import 'package:geocoding/geocoding.dart' as GEO;
import 'package:crafts/helpers/map_key.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:flutter/cupertino.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';
import 'package:location_permissions/location_permissions.dart';

class UpdateAddress extends StatefulWidget {
  final String id;
  UpdateAddress({@required this.id});
  @override
  _UpdateAddressState createState() => _UpdateAddressState();
}

class _UpdateAddressState extends State<UpdateAddress> {
  String addressVal;
  TextEditingController title = new TextEditingController();
  TextEditingController address = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController country = new TextEditingController();
  TextEditingController zip = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  TextEditingController neighbourhood = new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static LatLng _initialPosition;
  bool locationServiceActive = true;
  bool load = false;
  bool loadAdd = false;
  PickResult pickPlace;
  bool loading = false;
  String isoCode = 'SA';

  void _getUserLocation() async {
    setState(() {
      loadAdd = true;
    });
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, forceAndroidLocationManager: false );
   
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
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

  loccheck.Location locationenable =
      loccheck.Location(); //explicit reference to the Location class
  Future _checkGpsfun() async {
    if (!await locationenable.serviceEnabled()) {
      locationenable.requestService();
    }
  }

  void location_permission() async {
    final PermissionStatus permission = await _getLocationPermission();
    if (permission == PermissionStatus.granted) {
      final position = await Geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      // Use the position to do whatever...
    }
  }

  Future<PermissionStatus> _getLocationPermission() async {
    final PermissionStatus permission = await LocationPermissions()
        .checkPermissionStatus(level: LocationPermissionLevel.location);

    if (permission != PermissionStatus.granted) {
      final PermissionStatus permissionStatus = await LocationPermissions()
          .requestPermissions(
              permissionLevel: LocationPermissionLevel.location);

      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _loadingInitialPosition() async {
    await Future.delayed(Duration(seconds: 5)).then((v) {
      if (_initialPosition == null) {
        locationServiceActive = false;
      }
      setState(() {
        loadAdd = false;
      });
    });
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    await getLocation();
    setState(() {
      loading = false;
    });
  }

  Future<void> getLocation() async {
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetLocationByID xmlns="http://Craft.WS/">
      <LocationID>${widget.id}</LocationID>
    </GetLocationByID>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetLocationByID",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetLocationByIDResult')[0]
        .text;
    final decoded = jsonDecode(json);
    title.text = decoded['Name'];
    address.text = decoded['Addresstxt'];
    addressVal = decoded['Addressval'];
    city.text = decoded['City'];
    zip.text = decoded['Zipcode'];
    country.text = decoded['Country'];
    phone.text = decoded['Phone'];
    neighbourhood.text = decoded['neighbourhood'];
    setState(() {
       if(decoded['ISO'] != '')
    isoCode = decoded['ISO'];
    print(isoCode);
    });
   
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      location_permission();
    }
    _checkGpsfun();
    _getUserLocation();
    _loadingInitialPosition();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return _initialPosition == null
        ? Scaffold(
            body: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/location-off.png',
                        height: 150, width: 150, fit: BoxFit.fill),
                    loadAdd
                        ? SizedBox(height: 20)
                        : Container(height: 0, width: 0),
                    loadAdd
                        ? SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(yellow),
                            ),
                          )
                        : Container(height: 0, width: 0),
                  ],
                )),
          )
        : Directionality(
            textDirection:
                globals.loc == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Colors.white,
              key: _scaffoldKey,
              body: loading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(yellow),
                          )
                        ],
                      ),
                    )
                  : Column(children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top + 10,
                      ),
                      Header(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppBarOne(
                                    implyLeading: true,
                                    text: globals.loc == 'en'
                                        ? 'Location Information'
                                        : 'تفاصيل الموقع',
                                    press: () {
                                      Navigator.pop(context);
                                    },
                                    textColor: Colors.black,
                                    backgroundColor: Colors.white,
                                  ),
                                  SizedBox(height: 30),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                            controller: title,
                                            style: TextStyle(fontSize: 20),
                                            validator: (val) {
                                              if (val.length == 0)
                                                return globals.loc == 'en'
                                                    ? 'Required'
                                                    : 'مطلوب';
                                              else
                                                return null;
                                            },
                                            cursorColor: Colors.black,
                                            decoration: InputDecoration(
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior
                                                        .always,
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
                                                    color: Colors.black),
                                                labelText: globals.loc == 'en'
                                                    ? 'Address Name'
                                              : 'اسم العنوان',
                                                isDense: true)),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: TextFormField(
                                                    controller: address,
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                    enabled: false,
                                                    validator: (val) {
                                                      if (val.length == 0)
                                                        return globals.loc ==
                                                                'en'
                                                            ? 'Required'
                                                            : 'مطلوب';
                                                      else
                                                        return null;
                                                    },
                                                    cursorColor: Colors.black,
                                                    decoration: InputDecoration(
                                                        errorStyle: TextStyle(
                                                            color: Colors.red),
                                                        floatingLabelBehavior:
                                                            FloatingLabelBehavior
                                                                .always,
                                                        disabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        errorBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        enabledBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        focusedBorder:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        border:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        labelStyle: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        labelText:
                                                            globals.loc == 'en'
                                                                ? 'Address'
                                                                : 'العنوان',
                                                        isDense: true)),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return PlacePicker(
                                                            apiKey: apiKey,
                                                            initialPosition:
                                                                _initialPosition,
                                                            automaticallyImplyAppBarLeading:
                                                                false,
                                                            useCurrentLocation:
                                                                true,
                                                            selectInitialPosition:
                                                                true,
                                                            onPlacePicked:
                                                                (result) async {
                                                              pickPlace =
                                                                  result;
                                                              address.text =
                                                                  pickPlace
                                                                      .formattedAddress;
                                                              List<GEO.Placemark>
                                                                  placemarks =
                                                                  await GEO.placemarkFromCoordinates(
                                                                      pickPlace
                                                                          .geometry
                                                                          .location
                                                                          .lat,
                                                                      pickPlace
                                                                          .geometry
                                                                          .location
                                                                          .lng);
                                                              city.text =
                                                                  placemarks[0]
                                                                      .locality;
                                                              country.text =
                                                                  placemarks[0]
                                                                      .country;
                                                              zip.text =
                                                                  placemarks[0]
                                                                      .postalCode;
                                                              neighbourhood
                                                                      .text =
                                                                  placemarks[0]
                                                                      .street;
                                                              addressVal =
                                                                  '${pickPlace.geometry.location.lat},${pickPlace.geometry.location.lng}';
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              setState(() {});
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: SizedBox(
                                                      height: 40,
                                                      width: 40,
                                                      child: Image.asset(
                                                          'assets/location.png',
                                                          fit: BoxFit.fill)))
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                  controller: city,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                  validator: (val) {
                                                    if (val.length == 0)
                                                      return globals.loc == 'en'
                                                          ? 'Required'
                                                          : 'مطلوب';
                                                    else
                                                      return null;
                                                  },
                                                  cursorColor: Colors.black,
                                                  decoration: InputDecoration(
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .always,
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      border:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      labelStyle: TextStyle(
                                                          color: Colors.black),
                                                      labelText:
                                                          globals.loc == 'en'
                                                              ? 'City'
                                                              : 'المدينة',
                                                      isDense: true)),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                  controller: zip,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                  validator: (val) {
                                                    if (val.length == 0)
                                                      return globals.loc == 'en'
                                                          ? 'Required'
                                                          : 'مطلوب';
                                                    else
                                                      return null;
                                                  },
                                                  cursorColor: Colors.black,
                                                  decoration: InputDecoration(
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .always,
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      border:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      labelStyle: TextStyle(
                                                          color: Colors.black),
                                                      labelText: globals.loc ==
                                                              'en'
                                                          ? 'Zip Code'
                                                          : ' الرمز البريدي',
                                                      isDense: true)),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                            controller: country,
                                            style: TextStyle(fontSize: 20),
                                            validator: (val) {
                                              if (val.length == 0)
                                                return globals.loc == 'en'
                                                    ? 'Required'
                                                    : 'مطلوب';
                                              else
                                                return null;
                                            },
                                            cursorColor: Colors.black,
                                            decoration: InputDecoration(
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior
                                                        .always,
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
                                                    color: Colors.black),
                                                labelText: globals.loc == 'en'
                                                    ? 'Country'
                                                    : ' البلد',
                                                isDense: true)),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        TextFormField(
                                            style: TextStyle(fontSize: 22),
                                            controller: neighbourhood,
                                            validator: (val) {
                                              if (val.length == 0)
                                                return globals.loc == 'en'
                                                    ? 'Required'
                                                    : 'مطلوب';
                                              else
                                                return null;
                                            },
                                            cursorColor: Colors.black,
                                            decoration: InputDecoration(
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior
                                                        .always,
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
                                                    color: Colors.black,
                                                    fontSize: 26),
                                                labelText: globals.loc == 'en'
                                                    ? 'Neighbourhood'
                                                    : ' الحي',
                                                isDense: true)),
                                        SizedBox(
                                          height: 10,
                                        ),
                                          Text(
                          globals.loc == 'en' ? 'Mobile Number' : 'رقم الهاتف',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: IntlPhoneField(
                            autoValidate: false,
                            initialCountryCode: isoCode,
                            style: TextStyle(fontSize: 24),
                            controller: phone,
                            validator: (val) {
                              if (val.length == 0)
                                return globals.loc == 'en'
                                    ? 'Required'
                                    : 'مطلوب';
                              else
                                return null;
                            },
                            decoration: InputDecoration(
                                hintText: 'xxxxxxxxx',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                isDense: true),
                            onCountryChanged: (phoneval) {
                              setState(() {
                                isoCode = phoneval.countryISOCode;
                              }); 
                            },
                            onChanged: (phoneval) {
                              setState(() {
                                isoCode = phoneval.countryISOCode;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                                          height: 30,
                                        ),
                                        load
                                            ? Align(
                                                alignment: Alignment.center,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      new AlwaysStoppedAnimation<
                                                          Color>(yellow),
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child: RaisedButton(
                                                        elevation: 0,
                                                        shape:
                                                            RoundedRectangleBorder(),
                                                        color: Colors.black,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20,
                                                                horizontal: 15),
                                                        child: Text(
                                                          globals.loc == 'en'
                                                              ? 'Save'
                                                              : 'حفظ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        onPressed: () async {
                                                          if (_formKey
                                                              .currentState
                                                              .validate()) {
                                                            setState(() {
                                                              load = true;
                                                            });
                                                            String soap =
                                                                '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <UpdateLocationV2 xmlns="http://Craft.WS/">
      <LocationID>${widget.id}</LocationID>
      <Title>${title.text}</Title>
      <Addresstxt>${address.text}</Addresstxt>
      <Addressval>$addressVal</Addressval>
      <City>${city.text}</City>
      <Zipcode>${zip.text}</Zipcode>
      <Country>${country.text}</Country>
      <Phone>${phone.text}</Phone>
      <CustomerID>${globals.user.id}</CustomerID>
      <neighbourhood>${neighbourhood.text}</neighbourhood>
      <ISOCode>$isoCode</ISOCode>


    </UpdateLocationV2>
  </soap:Body>
</soap:Envelope>''';
                                                            http.Response
                                                                responseUpdate =
                                                                await http
                                                                    .post(
                                                                        'https://craftapp.net/services/CraftWebService.asmx',
                                                                        headers: {
                                                                          "SOAPAction":
                                                                              "http://Craft.WS/UpdateLocationV2",
                                                                          "Content-Type":
                                                                              "text/xml;charset=UTF-8",
                                                                        },
                                                                        body: utf8.encode(
                                                                            soap),
                                                                        encoding:
                                                                            Encoding.getByName(
                                                                                "UTF-8"))
                                                                    .then(
                                                                        (onValue) {
                                                              return onValue;
                                                            });
                                                            String json = parse(
                                                                    responseUpdate
                                                                        .body)
                                                                .getElementsByTagName(
                                                                    'UpdateLocationV2Result')[0]
                                                                .text;
                                                            final decoded =
                                                                jsonDecode(
                                                                    json);
                                                            print(responseUpdate
                                                                .body);
                                                            setState(() {
                                                              load = false;
                                                            });
                                                            _scaffoldKey
                                                                .currentState
                                                                .showSnackBar(SnackBar(
                                                                    content: Text(
                                                                        decoded,
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                                15)),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            4)))
                                                                .closed
                                                                .then((_) {
                                                              Navigator.pop(
                                                                  context);
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              Addresses()));
                                                            });
                                                          }
                                                        }),
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                                  )
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
            ));
  }
}
