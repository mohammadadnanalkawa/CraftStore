import 'dart:io';

import 'package:crafts/screens/checkout_one.dart';
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
import 'package:open_settings/open_settings.dart';
import 'package:location_permissions/location_permissions.dart';

class NewAddress extends StatefulWidget {
  final String from;
  final String name;
  final String email;

  NewAddress({@required this.from, @required this.name, @required this.email});
  @override
  _NewAddressState createState() => _NewAddressState();
}

// with WidgetsBindingObserver
class _NewAddressState extends State<NewAddress> {
  TextEditingController title = new TextEditingController();
  TextEditingController address = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController country = new TextEditingController();
  TextEditingController neighbourhood = new TextEditingController();

  TextEditingController zip = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static LatLng _initialPosition;
  bool locationServiceActive = true;
  bool load = false;
  bool loadAdd = false;
  String sms = "";
  String isoCode = 'SA';

  PickResult pickPlace;
  void _getUserLocation() async {
    setState(() {
      loadAdd = true;
    });
    Position position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
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
    // WidgetsBinding.instance.addObserver(this);
    if (Platform.isIOS) {
      location_permission();
    }

    if (globals.user.phone != null && globals.user.phone != '') {
      phone.text = globals.user.phone;
    }
    _checkGpsfun();
    _getUserLocation();
    _loadingInitialPosition();
  }

  @override
  void dispose() {
    //  WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /*    @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
       //do your stuff
        if (Platform.isIOS) {
      location_permission();
    }

    if (globals.user.phone != null && globals.user.phone != '') {
      phone.text = globals.user.phone;
    }
    _checkGpsfun();
    //_getUserLocation();
   _loadingInitialPosition();
   setState(() {
        
      });
    }
  }
 */

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
                    SizedBox(height: 20),
                    loadAdd
                        ? SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(yellow),
                            ),
                          )
                        : Container(
                            child: Column(children: [
                              RaisedButton(
                                  elevation: 0,
                                  color: yellow,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 15),
                                  child: Text(
                                    globals.loc == 'en'
                                        ? 'Please enable location'
                                        : 'يرجى تفعيل الموقع ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    OpenSettings.openLocationSourceSetting();
                                  }

                                  // }
                                  ),
                            SizedBox(height: 20,),
                              GestureDetector(
                                onTap: (){
                                   Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewAddress(
                                        from: widget.from,
                                        name: widget.name,
                                        email: widget.email,
                                      )));
                            
                                },
                                child: Container(
                                    decoration: BoxDecoration(),
                                    child: Icon(Icons.refresh, size: 42, )),
                              )
                            ]),
                          ),
                  ],
                )),
          )
        : Directionality(
            textDirection:
                globals.loc == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Colors.white,
              key: _scaffoldKey,
              body: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 10,
                ),
                Header(),
                Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
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
                                  : 'تفاصيل العنوان',
                              press: () {
                                Navigator.pop(context);
                              },
                              textColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                      style: TextStyle(fontSize: 22),
                                      controller: title,
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
                                              FloatingLabelBehavior.always,
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
                                              color: Colors.black,
                                              fontSize: 26),
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
                                              style: TextStyle(fontSize: 22),
                                              enabled: false,
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
                                                  errorStyle: TextStyle(
                                                      color: Colors.red),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always,
                                                  disabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black),
                                                  ),
                                                  errorBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.red),
                                                  ),
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
                                                      useCurrentLocation: true,
                                                      selectInitialPosition:
                                                          true,
                                                      onPlacePicked:
                                                          (result) async {
                                                        pickPlace = result;
                                                        address.text = pickPlace
                                                            .formattedAddress;
                                                        List<
                                                                GEO.Placemark>
                                                            placemarks =
                                                            await GEO
                                                                .placemarkFromCoordinates(
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
                                                        zip.text = placemarks[0]
                                                            .postalCode;
                                                        neighbourhood.text =
                                                            placemarks[0]
                                                                .street;
                                                        Navigator.of(context)
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
                                            style: TextStyle(fontSize: 22),
                                            controller: city,
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
                                                    ? 'City'
                                                    : 'المدينة',
                                                isDense: true)),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                            style: TextStyle(fontSize: 22),
                                            controller: zip,
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
                                              FloatingLabelBehavior.always,
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
                                              color: Colors.black,
                                              fontSize: 26),
                                          labelText: globals.loc == 'en'
                                              ? 'Neighbourhood'
                                              : ' الحي',
                                          isDense: true)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  TextFormField(
                                      style: TextStyle(fontSize: 22),
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
                                      decoration: InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
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
                                              color: Colors.black,
                                              fontSize: 26),
                                          labelText: globals.loc == 'en'
                                              ? 'Country'
                                              : ' البلد',
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
                            initialCountryCode: 'SA',
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
                        
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      sms,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 22),
                                    ),
                                  ),
                                  load
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
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
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 15),
                                                  child: Text(
                                                    globals.loc == 'en'
                                                        ? 'Save'
                                                        : 'حفظ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                  onPressed: () async {
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      setState(() {
                                                        load = true;
                                                      });
                                                      String soap =
                                                          '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <InsertLocationV2 xmlns="http://Craft.WS/">
      <ClientID>${globals.user.id}</ClientID>
      <Title>${title.text}</Title>
      <Addresstxt>${address.text}</Addresstxt>
      <Addressval>${pickPlace.geometry.location.lat},${pickPlace.geometry.location.lng}</Addressval>
      <City>${city.text}</City>
      <Zipcode>${zip.text}</Zipcode>
      <Country>${country.text}</Country>
      <Phone>${phone.text}</Phone>
      <neighbourhood>${neighbourhood.text}</neighbourhood>
      <ISOCode>$isoCode</ISOCode>

          </InsertLocationV2>
  </soap:Body>
</soap:Envelope>''';
                                                      http.Response
                                                          responseUpdate =
                                                          await http
                                                              .post(
                                                                  'https://craftapp.net/services/CraftWebService.asmx',
                                                                  headers: {
                                                                    "SOAPAction":
                                                                        "http://Craft.WS/InsertLocationV2",
                                                                    "Content-Type":
                                                                        "text/xml;charset=UTF-8",
                                                                  },
                                                                  body: utf8
                                                                      .encode(
                                                                          soap),
                                                                  encoding: Encoding
                                                                      .getByName(
                                                                          "UTF-8"))
                                                              .then((onValue) {
                                                        return onValue;
                                                      });
                                                      String json = parse(
                                                              responseUpdate
                                                                  .body)
                                                          .getElementsByTagName(
                                                              'InsertLocationV2Result')[0]
                                                          .text;
                                                      final decoded =
                                                          jsonDecode(json);
                                                      print(
                                                          responseUpdate.body);
                                                      setState(() {
                                                        load = false;
                                                        if (decoded['Flag'] ==
                                                            '-1')
                                                          sms = decoded["SMS"];
                                                        else {
                                                          Navigator.pop(
                                                              context);
                                                          if (widget.from ==
                                                              "0") {
                                                            Navigator.pushReplacement(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Addresses()));
                                                          } else {
                                                            Navigator
                                                                .pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            CheckoutOne(
                                                                              name: widget.name,
                                                                              email: widget.email,
                                                                            )));
                                                          }
                                                        }
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
