import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/helpers/linking.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/category_item_list.dart';
import 'package:crafts/screens/checkout_one.dart';
import 'package:crafts/screens/filterpage.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/Ssidershowfullimagesone.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info/device_info.dart';
import 'package:crafts/helpers/user.dart';
import 'package:crafts/helpers/banner.dart' as bannercc;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clipboard/clipboard.dart';

typedef void VoidCallback(String val);

class ProductDetails extends StatefulWidget {
  final VoidCallback favChange;
  final String favflag;
  final String productID;

  ProductDetails(
      {@required this.favflag,
      @required this.productID,
      @required this.favChange});
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  ScrollController _scrollController = ScrollController();
  PersistentBottomSheetController _controller; // <------ Instance variable
  PersistentBottomSheetController
      _controllercustom; // <------ Instance variable
  String back = '0';
  String fav;
  int index = 0;
  List<bannercc.Banner> banners = [];
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  List<Property> properties = [];
  List<Attribute> attributes = <Attribute>[];
  List<Custom> custom = <Custom>[];
  bool loading = false;
  bool loadingcustom = false;
  int quantity = 1;
  int quantity2 = 1;
  int quantity3 = 1;
  int defquant = 1;
  int attquant = 1;

  String orderID;
  String name;
  String brand;
  String tag;
  String alert;
  String price;
  String waranty;
  String delivery;
  String vat;
  String tagcolor;
  String fontcolor;
  String bordercolor;
  String cat;

  String by;
  String productCode;
  String phone;
  String whatsapp;
  String email;
  String flag;
  String customPhoto;
  String ddl;
  String enablebag;
  String selectcolor;
  String selectsize;

  String sortSelect;
  String sortSelect2;
  String image = '';
  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';
  bool upload = false;
  StorageUploadTask task;
  String img =
      'https://firebasestorage.googleapis.com/v0/b/craftapp-ccfff.appspot.com/o/profiles%2F66-661092_png-file-upload-image-icon-png-transparent-png.png?alt=media&token=d92209e8-a724-474d-87be-11fb44472f43';

  final _formKey = GlobalKey<FormState>();
  List<MayWidget> mayWid = <MayWidget>[];
  bool load = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    fav = widget.favflag;
    super.initState();

    loadData();
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  Future<void> gustprocess() async {
    back = '1';
    String deviceId = await _getId();
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Signgust xmlns="http://Craft.WS/">
      <UUID>$deviceId</UUID>
    
    </Signgust>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/Signgust",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });

    if (response.statusCode == 200) {
      print(response.body);
      String json =
          parse(response.body).getElementsByTagName('SigngustResult')[0].text;
      final decoded = jsonDecode(json);
      print(decoded);
      if (decoded['ID'] == '-1') {
        setState(() {});
      } else {
        await addData(
            decoded['ID'].toString(),
            decoded['Name'],
            decoded['Phone'],
            decoded['Email'],
            decoded['Password'],
            decoded['Image'],
            '1');
      }
    }
  }

  addData(String id, String name, String phone, String email, String password,
      String image, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ID', id);
    prefs.setString('Name', name);
    prefs.setString('Phone', phone);
    prefs.setString('Email', email);
    prefs.setString('Password', password);
    prefs.setString('Image', image);
    prefs.setString('Type', type);

    User user = User(
      name: name,
      email: email,
      password: password,
      id: id,
      image: image,
      phone: phone,
      type: type,
    );

    if (user.id != null) {
      globals.user = user;
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
    if (globals.user == null) {
      await gustprocess();
    }
    await getProdById();
    await getMay();
    setState(() {
      loading = false;
    });
  }

  Future<void> getMay() async {
    mayWid = [];
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetMayLike xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id != '0' ? globals.user.id : globals.loc}</CustomerID>
      <ProductID>${widget.productID}</ProductID>
    </GetMayLike>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetMayLike",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json =
        parse(response.body).getElementsByTagName('GetMayLikeResult')[0].text;
    final decoded = jsonDecode(json);
    for (int i = 0; i < decoded.length; i++) {
      mayWid.add(MayWidget(
        id: decoded[i]['ID'],
        title: decoded[i]['Title'],
        image: decoded[i]['Photo'],
        brand: decoded[i]['Brand'],
        by: decoded[i]['By'],
        price: decoded[i]['Price'],
        fav: decoded[i]['favflag'],
      ));
    }
  }

  Future<void> getProdById() async {
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetProductByIDV3 xmlns="http://Craft.WS/">
      <CustomerID>${globals.user.id != '0' ? globals.user.id : globals.loc}</CustomerID>
      <ProductID>${widget.productID}</ProductID>
    </GetProductByIDV3>
  </soap:Body>
</soap:Envelope>''';
// <ProductID>${widget.productID}</ProductID>
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetProductByIDV3",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    String json = parse(response.body)
        .getElementsByTagName('GetProductByIDV3Result')[0]
        .text;
    final decoded = jsonDecode(json);
    ddl = decoded['DDlFlag'];
    orderID = decoded['ID'];
    name = decoded['Name'];
    brand = decoded['Brand'];
    tag = decoded['Tag'];
    alert = decoded['Alert'];
    price = decoded['Price'];
    by = decoded['By'];
    phone = decoded['Phone'];
    whatsapp = decoded['Whatsapp'];
    email = decoded['Email'];
    productCode = decoded['ProductCode'];
    waranty = decoded['waranty'];
    vat = decoded['vat'];
    delivery = decoded['delivery'];
    fontcolor = decoded['FontColor'];
    tagcolor = decoded['TagColor'];
    bordercolor = decoded['BorderColor'];
    cat = decoded['cat'];
    if (decoded['defaultquantity'] != "0")
      defquant = int.parse(decoded['defaultquantity']);

    if (decoded['attributequantity'] != "0")
      attquant = int.parse(decoded['attributequantity']);

    for (int j = 0; j < decoded['Photos'].length; j++) {
      banners.add(bannercc.Banner(decoded['Photos'][j]['Photo'], j));
    }
    for (int j = 0; j < decoded['PropertyList'].length; j++) {
      properties.add(Property(
          title: decoded['PropertyList'][j]['Title'],
          description: decoded['PropertyList'][j]['Description']));
    }
    print(decoded['EnableCustom']);
    for (int j = 0; j < decoded['AttrbuiteList'].length; j++) {
      List<DropList> drop = <DropList>[];
      for (int k = 0;
          k < decoded['AttrbuiteList'][j]['OptionsList'].length;
          k++) {
        drop.add(DropList(
          id: decoded['AttrbuiteList'][j]['OptionsList'][k]['ID'],
          option: decoded['AttrbuiteList'][j]['OptionsList'][k]['Option'],
          imagecolor: decoded['AttrbuiteList'][j]['OptionsList'][k]['Image'],
          quantity: decoded['AttrbuiteList'][j]['OptionsList'][k]['Quantity'],
        ));
      }
      attributes.add(Attribute(
          currentSelect: drop[0],
          id: decoded['AttrbuiteList'][j]['DropTitle'][0]['ID'],
          list: drop,
          title: decoded['AttrbuiteList'][j]['DropTitle'][0]['Title'],
          type: decoded['AttrbuiteList'][j]['DropTitle'][0]['Type']));

      if (decoded['AttrbuiteList'][j]['DropTitle'][0]['Type'] == '1') {
        selectcolor = drop[0].option;
      } else
        selectsize = drop[0].option;

      if (j == 0) {
        if (decoded['AttrbuiteList'][j]['DropTitle'][0]['Type'] == '1') {
          sortSelect = drop[0].id;
        } else
          sortSelect2 = drop[0].id;
      } else if (j == 1) {
        sortSelect2 = drop[0].id;
        selectsize = drop[0].option;
      }
    }
    flag = decoded['EnableCustom'];
    enablebag = decoded["enablebag"];
    if (price == '0') enablebag = '0';

    if (flag == '1') {
      for (int j = 0; j < decoded['CustomList'].length; j++) {
        List<SubCustom> subcustom = <SubCustom>[];

        for (int z = 0; z < decoded['CustomList'][j]['Subitem'].length; z++) {
          subcustom.add(SubCustom(
            id: decoded['CustomList'][j]['Subitem'][z]['ID'],
            title: decoded['CustomList'][j]['Subitem'][z]['Title'],
          ));
        }
        String selectddl = '0';
        if (decoded['CustomList'][j]['Subitem'].length > 0)
          selectddl = decoded['CustomList'][j]['Subitem'][0]['ID'];

        custom.add(Custom(
            controller: new TextEditingController(),
            id: decoded['CustomList'][j]['ID'],
            title: decoded['CustomList'][j]['Title'],
            type: decoded['CustomList'][j]['Type'],
            controller2: new TextEditingController(),
            subitems: subcustom,
            selectsubitem: selectddl));
      }
    }
    customPhoto = decoded['CustomPhoto'];
  }

  Future<void> getbannercolor(
      String attid, String attid2, String upsize) async {
    if (attid == null) attid = "0";
    if (attid2 == null) attid2 = "0";
//${widget.productID}
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetImageByColorv3 xmlns="http://Craft.WS/">
      <AttID>$attid</AttID>
      <AttID2>$attid2</AttID2>

      <ProductID>${widget.productID}</ProductID>
      <CustomerID>${globals.user.id}</CustomerID>
      <UpSize>$upsize</UpSize>

    </GetImageByColorv3>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetImageByColorv3",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    String json = parse(response.body)
        .getElementsByTagName('GetImageByColorv3Result')[0]
        .text;
    final decoded = jsonDecode(json);
    if (decoded['Photos'].length > 0) {
      banners = [];

      for (int j = 0; j < decoded['Photos'].length; j++) {
        banners.add(bannercc.Banner(decoded['Photos'][j]['Photo'], j));
      }
    }

    /* Start */
    if (decoded['Upsize'].length > 0) {
      List<DropList> drop = <DropList>[];
      for (int j = 0; j < decoded['Upsize'].length; j++) {
        drop.add(DropList(
          id: decoded['Upsize'][j]['ID'],
          option: decoded['Upsize'][j]['Option'],
          imagecolor: decoded['Upsize'][j]['Image'],
          quantity: decoded['Upsize'][j]['Quantity'],
        ));
        selectsize = drop[0].option;
      }

      attributes[1].list = drop;
      sortSelect2 = drop[0].id;
    }
    /* End */

    price = decoded['Price'];
    enablebag = decoded["enablebag"];
    if (decoded['quantity'] != "0") {
      attquant = int.parse(decoded['quantity']);
      if (quantity2 > attquant) quantity2 = attquant;
    }

    if (price == '0') enablebag = '0';

    setState(() {
      if (price == '0') enablebag = '0';
    });
    _controller.setState(() {
      if (price == '0') enablebag = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
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
              : Container(
                  child: Column(children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top + 10,
                    ),
                    Header(),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: CarouselSlider(
                                        options: CarouselOptions(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              1.5,
                                          aspectRatio: 16 / 9,
                                          viewportFraction: 1,
                                          initialPage: index,
                                          enableInfiniteScroll: true,
                                          reverse: false,
                                          autoPlay: false,
                                          autoPlayInterval:
                                              Duration(seconds: 3),
                                          autoPlayAnimationDuration:
                                              Duration(milliseconds: 800),
                                          autoPlayCurve: Curves.fastOutSlowIn,
                                          enlargeCenterPage: true,
                                          onPageChanged: callbackFunction,
                                          scrollDirection: Axis.horizontal,
                                        ),
                                        items: banners.map((image) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(),
                                                  child: ClipRRect(
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SliderShowFullimages2(
                                                                          url: image
                                                                              .image,
                                                                          current:
                                                                              image.atIndex,
                                                                          galleryItems:
                                                                              banners,
                                                                        )));
                                                      },
                                                      child: Image.network(
                                                          image.image,
                                                          fit: BoxFit.fill,
                                                          // fit: BoxFit.contain,
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent
                                                                      loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return Container(
                                                          height: 200,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
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
                                                      }),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList()),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (back == '0')
                                                Navigator.pop(context);
                                              else {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            WillPopScope(
                                                                onWillPop:
                                                                    () async =>
                                                                        false,
                                                                child: Home(
                                                                  index: 0,
                                                                ))));
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(),
                                              child: Icon(
                                                Icons.arrow_back,
                                                size: 26,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          globals.user.id != '0'
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (fav == '0') {
                                                        fav = '1';
                                                      } else {
                                                        fav = '0';
                                                      }
                                                    });
                                                    widget.favChange(fav);
                                                    String soapFav =
                                                        '''<?xml version="1.0" encoding="utf-8"?>
                                <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                                      <soap:Body>
                      <AddFavProduct xmlns="http://Craft.WS/">
                        <CustomerID>${globals.user.id}</CustomerID>
                        <Status>$fav</Status>
                        <ProductID>${widget.productID}</ProductID>
                      </AddFavProduct>
                                      </soap:Body>
                                </soap:Envelope>''';
                                                    http.post(
                                                        'https://craftapp.net/services/CraftWebService.asmx',
                                                        headers: {
                                                          "SOAPAction":
                                                              "http://Craft.WS/AddFavProduct",
                                                          "Content-Type":
                                                              "text/xml;charset=UTF-8",
                                                        },
                                                        body: utf8
                                                            .encode(soapFav),
                                                        encoding:
                                                            Encoding.getByName(
                                                                "UTF-8"));
                                                  },
                                                  child: Container(
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Icon(
                                                          fav == '0'
                                                              ? CupertinoIcons
                                                                  .heart
                                                              : CupertinoIcons
                                                                  .heart_fill,
                                                          size: 26)),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Align(
                                alignment: Alignment.center,
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: banners.map((e) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 2.5),
                                          height: index == e.atIndex ? 6 : 12,
                                          width: index == e.atIndex ? 15 : 12,
                                          decoration: BoxDecoration(
                                              color: index == e.atIndex
                                                  ? yellow
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: GestureDetector(
                                        onTap: () async {
                                          Uri uri = await _dynamicLinkService
                                              .createDynamicLink(
                                                  widget.productID);
                                          Share.share(uri.toString());
                                        },
                                        child: Icon(Icons.share, size: 26)),
                                  )),
                              SizedBox(height: 15),
                              tag == ''
                                  ? Container()
                                  : Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 7.5, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: HexColor(tagcolor),
                                        border: Border.all(
                                            color: HexColor(bordercolor)),
                                      ),
                                      child: AutoSizeText(tag,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: HexColor(fontcolor),
                                              fontSize: 16)),
                                    ),
                              SizedBox(
                                height: 7.5,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  brand,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 20),
                                ),
                              ),
                              SizedBox(
                                height: 7.5,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  by,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: yellow,
                                      fontSize: 18),
                                ),
                              ),
                              SizedBox(
                                height: 7.5,
                              ),
                              alert.isEmpty
                                  ? Container(
                                      height: 0,
                                      width: 0,
                                    )
                                  : Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        alert,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.red),
                                      ),
                                    ),
                              alert.isEmpty
                                  ? Container(
                                      height: 0,
                                      width: 0,
                                    )
                                  : SizedBox(
                                      height: 7.5,
                                    ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '$price SAR',
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 22),
                                ),
                              ),
                              vat != '0'
                                  ? SizedBox(
                                      height: 7.5,
                                    )
                                  : SizedBox(
                                      height: 0,
                                    ),
                              vat != '0'
                                  ? Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        globals.loc == 'en'
                                            ? 'VAT inclusive'
                                            : 'شامل ضريبة القيمة المضافة',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    )
                                  : Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                    ),
                              waranty != ''
                                  ? SizedBox(
                                      height: 7.5,
                                    )
                                  : Container(),
                              waranty != ''
                                  ? Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        globals.loc == 'en'
                                            ? 'Warranty ' + waranty
                                            : ' الضمان ' + waranty,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    )
                                  : Container(),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                      ),
                                      child: Text(
                                        '${globals.loc == 'en' ? 'Product Code:' : 'رمز المنتج:'} $productCode',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  bool expanded = false;
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Container(
                                        child: Column(children: [
                                          Theme(
                                            data: theme,
                                            child: ExpansionTile(
                                              onExpansionChanged: (value) {
                                                setState(() {
                                                  expanded = value;
                                                });
                                              },
                                              expandedCrossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              trailing: Icon(
                                                  expanded
                                                      ? CupertinoIcons
                                                          .chevron_up
                                                      : CupertinoIcons
                                                          .chevron_down,
                                                  size: 20),
                                              childrenPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 7.5),
                                              title: Text(
                                                properties[index].title,
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              children: [
                                                Align(
                                                    alignment: globals.loc ==
                                                            'en'
                                                        ? Alignment.centerLeft
                                                        : Alignment.centerRight,
                                                    child: Html(
                                                        data: properties[index]
                                                            .description)),
                                              ],
                                            ),
                                          ),
                                          Divider()
                                        ]),
                                      );
                                    },
                                  );
                                },
                                itemCount: properties.length,
                              ),
                              ddl == '1'
                                  ? sliverGridWidgetDrop1(context)
                                  : Container(height: 0, width: 0),
                              ddl == '0'
                                  ? Container(
                                      height: 0,
                                      width: 0,
                                    )
                                  : Divider(),
                              flag == '1'
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 50, vertical: 10),
                                            child: RaisedButton(
                                                elevation: 0,
                                                color: HexColor("#a8d6ed"),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                                child: Text(
                                                  globals.loc == 'en'
                                                      ? 'Custom Request'
                                                      : 'تخصيص الطلب ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 20),
                                                ),
                                                onPressed: () async {
                                                  dialogcustomize(context);
                                                }

                                                // }
                                                ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Container(),
                              flag == '1' ? Divider() : Container(),
                              ExpansionTile(
                                  childrenPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 7.5),
                                  children: [
                                    Align(
                                        alignment: globals.loc == 'en'
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () async {
                                            try {
                                              await launch("tel:$phone");
                                            } catch (e) {
                                              Fluttertoast.showToast(
                                                  msg: globals.loc == 'en'
                                                      ? 'Failed to open phone app'
                                                      : 'فشل في فتح تطبيق الهاتف',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      Colors.grey[800],
                                                  textColor: Colors.white,
                                                  fontSize: 14.0);
                                            }
                                          },
                                          child: Text(
                                              '${globals.loc == 'en' ? 'Phone:' : 'هاتف:'} $phone',
                                              style: TextStyle(fontSize: 16)),
                                        )),
                                    SizedBox(height: 7.5),
                                    Align(
                                        alignment: globals.loc == 'en'
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () async {
                                            try {
                                              await launch(
                                                  "whatsapp://send?phone=$whatsapp");
                                            } catch (e) {
                                              Fluttertoast.showToast(
                                                  msg: globals.loc == 'en'
                                                      ? 'Failed to open whatsapp'
                                                      : 'فشل في فتح واتساب',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      Colors.grey[800],
                                                  textColor: Colors.white,
                                                  fontSize: 14.0);
                                            }
                                          },
                                          child: Text(
                                              '${globals.loc == 'en' ? 'WhatsApp:' : 'الواتساب:'} $whatsapp',
                                              style: TextStyle(fontSize: 16)),
                                        )),
                                    SizedBox(height: 7.5),
                                    Align(
                                        alignment: globals.loc == 'en'
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () async {
                                            try {
                                              await launch("mailto:$email");
                                            } catch (e) {
                                              Fluttertoast.showToast(
                                                  msg: globals.loc == 'en'
                                                      ? 'Failed to open mail app'
                                                      : 'فشل فتح تطبيق البريد',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                      Colors.grey[800],
                                                  textColor: Colors.white,
                                                  fontSize: 14.0);
                                            }
                                          },
                                          child: Text(
                                              '${globals.loc == 'en' ? 'Email:' : 'البريد الإلكتروني:'} $email',
                                              style: TextStyle(fontSize: 16)),
                                        )),
                                  ],
                                  leading: Icon(Icons.help_outline, size: 24),
                                  trailing: Icon(
                                      globals.loc == 'en'
                                          ? Icons.chevron_right
                                          : Icons.chevron_left,
                                      size: 18),
                                  title: Text(
                                      globals.loc == 'en'
                                          ? 'Need help? Call, WhatsApp or Email us'
                                          : 'تحتاج مساعدة ؟ اتصل أو الواتساب أو راسلنا عبر البريد الإلكتروني',
                                      style: TextStyle(fontSize: 20))),
                              Divider(),
                              flag == '1'
                                  ? SizedBox(
                                      height: 0,
                                    )
                                  : SizedBox(
                                      height: 10,
                                    ),
                              flag == '1'
                                  ? Row()
                                  : Row(children: [
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: quantity <= 1
                                                    ? null
                                                    : () async {
                                                        setState(() {
                                                          quantity--;
                                                        });
                                                      },
                                                child: Container(
                                                  decoration: BoxDecoration(),
                                                  child: Icon(
                                                    Icons.remove_circle_outline,
                                                    color: yellow,
                                                    size: 32,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Text(
                                                quantity.toString(),
                                                style: TextStyle(fontSize: 32),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              GestureDetector(
                                                onTap: (quantity + 1) > defquant
                                                    ? null
                                                    : () async {
                                                        setState(() {
                                                          quantity++;
                                                        });

                                                        // widget.tap();
                                                      },
                                                child: Container(
                                                  decoration: BoxDecoration(),
                                                  child: Icon(
                                                    Icons.add_circle_outline,
                                                    color: yellow,
                                                    size: 32,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                              flag == '1'
                                  ? SizedBox(
                                      height: 0,
                                    )
                                  : SizedBox(
                                      height: 10,
                                    ),
                              flag == '1'
                                  ? Container()
                                  : load
                                      ? Align(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(yellow),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: RaisedButton(
                                                        elevation: 0,
                                                        color: Colors.grey[800],
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20,
                                                                horizontal: 15),
                                                        child: Text(
                                                          enablebag == '1'
                                                              ? globals.loc ==
                                                                      'en'
                                                                  ? 'Add to Bag'
                                                                  : 'اضف الى الحقيبة'
                                                              : globals.loc ==
                                                                      'en'
                                                                  ? 'Sorry! Product out of sold'
                                                                  : 'آسف! المنتج غير متوفر ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        ),
                                                        onPressed: () async {
                                                          if (enablebag ==
                                                              '1') {
                                                            //   if (_formKey.currentState.validate()) {
                                                            setState(() {
                                                              load = true;
                                                            });
                                                            String attr = '';
                                                            String cust = '';
                                                            for (int i = 0;
                                                                i <
                                                                    attributes
                                                                        .length;
                                                                i++) {
                                                              if (i == 0)
                                                                attr = attr +
                                                                    '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                             <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>
                                           </bagatt>''';
                                                              else if (i == 1)
                                                                attr = attr +
                                                                    '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                            }
                                                            for (int i = 0;
                                                                i <
                                                                    custom
                                                                        .length;
                                                                i++) {
                                                              String cus = custom[
                                                                              i]
                                                                          .type ==
                                                                      '2'
                                                                  ? custom[i]
                                                                      .controller
                                                                      .text
                                                                      .replaceAll(
                                                                          '&',
                                                                          '?and?')
                                                                  : custom[i]
                                                                      .controller
                                                                      .text;
                                                              cust = cust +
                                                                  '''<bagcustom>
                            <ID>${custom[i].id}</ID>
                            <ClientResponse>$cus</ClientResponse>
                          </bagcustom>''';
                                                            }
                                                            String soap =
                                                                '''<?xml version="1.0" encoding="utf-8"?>
                                <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                                      <soap:Body>
                      <AddToBagV2 xmlns="http://Craft.WS/">
                        <CustomerID>${globals.user.id}</CustomerID>
                        <ProductID>${widget.productID}</ProductID>
                        <UUID></UUID>
                                
                        <AttrbuiteList>
                          $attr
                        </AttrbuiteList>
                        <CustomList>
                          $cust
                        </CustomList>
                        <isbuy>0</isbuy>
                   <quantity>$quantity</quantity>

                      </AddToBagV2>
                                      </soap:Body>
                                </soap:Envelope>''';
                                                            http.Response
                                                                response =
                                                                await http
                                                                    .post(
                                                                        'https://craftapp.net/services/CraftWebService.asmx',
                                                                        headers: {
                                                                          "SOAPAction":
                                                                              "http://Craft.WS/AddToBagV2",
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
                                                                    response
                                                                        .body)
                                                                .getElementsByTagName(
                                                                    'AddToBagV2Result')[0]
                                                                .text;
                                                            //final decoded = jsonDecode(json);
                                                            setState(() {
                                                              load = false;
                                                            });
                                                            /*  Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        WillPopScope(
                                                                            onWillPop: () async =>
                                                                                false,
                                                                            child:
                                                                                Home(
                                                                              index: 3,
                                                                            )))); */

                                                          }
                                                        }

                                                        // }
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: RaisedButton(
                                                        elevation: 0,
                                                        color: yellow,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20,
                                                                horizontal: 15),
                                                        child: Text(
                                                          enablebag == '1'
                                                              ? globals.loc ==
                                                                      'en'
                                                                  ? 'Buy Now'
                                                                  : 'اشتري الآن'
                                                              : globals.loc ==
                                                                      'en'
                                                                  ? 'Sorry! Product out of sold'
                                                                  : 'آسف! المنتج غير متوفر ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        ),
                                                        onPressed: () async {
                                                          if (enablebag ==
                                                              '1') {
                                                            //   if (_formKey.currentState.validate()) {
                                                            setState(() {
                                                              load = true;
                                                            });
                                                            String attr = '';
                                                            String cust = '';
                                                            for (int i = 0;
                                                                i <
                                                                    attributes
                                                                        .length;
                                                                i++) {
                                                              if (i == 0)
                                                                attr = attr +
                                                                    '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
<ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                              else if (i == 1)
                                                                attr = attr +
                                                                    '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
<ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                            }
                                                            for (int i = 0;
                                                                i <
                                                                    custom
                                                                        .length;
                                                                i++) {
                                                              cust = cust +
                                                                  '''<bagcustom>
                            <ID>${custom[i].id}</ID>
                            <ClientResponse>${custom[i].controller.text}</ClientResponse>
                          </bagcustom>''';
                                                            }
                                                            String soap =
                                                                '''<?xml version="1.0" encoding="utf-8"?>
                                <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                                      <soap:Body>
                      <AddToBagV2 xmlns="http://Craft.WS/">
                        <CustomerID>${globals.user.id}</CustomerID>
                        <ProductID>${widget.productID}</ProductID>
                        <UUID></UUID>
                                
                        <AttrbuiteList>
                          $attr
                        </AttrbuiteList>
                        <CustomList>
                          $cust
                        </CustomList>
                        <isbuy>1</isbuy>
                   <quantity>$quantity</quantity>

                      </AddToBagV2>
                                      </soap:Body>
                                </soap:Envelope>''';
                                                            http.Response
                                                                response =
                                                                await http
                                                                    .post(
                                                                        'https://craftapp.net/services/CraftWebService.asmx',
                                                                        headers: {
                                                                          "SOAPAction":
                                                                              "http://Craft.WS/AddToBagV2",
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
                                                                    response
                                                                        .body)
                                                                .getElementsByTagName(
                                                                    'AddToBagV2Result')[0]
                                                                .text;
                                                            //final decoded = jsonDecode(json);
                                                            setState(() {
                                                              load = false;
                                                            });

                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CheckoutOne(
                                                                              name: '',
                                                                              email: '',
                                                                            )));
                                                          }
                                                        }

                                                        // }
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                              mayWid.length > 0
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              globals.loc == 'en'
                                                  ? 'You may also like'
                                                  : 'ربما يعجبك أيضا',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CategoryItemList(
                                                            byID: '',
                                                            byName: '',
                                                            mainID: '',
                                                            type: '',
                                                            filter: '1',
                                                            bylist: null,
                                                            from: '',
                                                            to: '',
                                                            sortSelected: '',
                                                            sub1: null,
                                                            sub2: null,
                                                            tagList: null,
                                                            mainCat: null,
                                                            may: cat,
                                                          )));
                                            },
                                            child: Text(
                                              globals.loc == 'en'
                                                  ? 'More'
                                                  : 'المزيد',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor: Colors.blue),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: 20,
                                    ),
                              mayWid.length > 0
                                  ? Container(
                                      alignment: globals.loc == "en"
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      height: 350,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) =>
                                            mayWid[index],
                                        itemCount: mayWid.length,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
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
        ));
  }

  Widget sliverGridWidgetDrop1(BuildContext context) {
    bool loadDropOne = false;
    bool loadDropTwo = false;
    return StaggeredGridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      crossAxisCount: 2, //staticData.length,
      children: [
        StatefulBuilder(
          builder: (context, settState) {
            return Container(
              decoration: BoxDecoration(),
              child: loadDropTwo
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(yellow),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        dialogoption(context);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            attributes[0].title,
                            style: TextStyle(fontSize: 22),
                          ),
                          Row(
                            children: [
                              Text(
                                attributes[0].type == '0'
                                    ? selectsize
                                    : selectcolor,
                                style: TextStyle(fontSize: 20),
                              ),
                              Icon(CupertinoIcons.chevron_down),
                            ],
                          )
                        ],
                      ),
                    ),
            );
          },
        ),
        attributes.length > 1
            ? StatefulBuilder(
                builder: (context, settState) {
                  return Container(
                      decoration: BoxDecoration(),
                      child: loadDropOne
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(yellow),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () {
                                dialogoption(context);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    attributes[1].title,
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        attributes[1].type == '0'
                                            ? selectsize
                                            : selectcolor,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Icon(CupertinoIcons.chevron_down),
                                    ],
                                  )
                                ],
                              ),
                            ));
                },
              )
            : Container(height: 0, width: 0)
      ],

      staggeredTiles: attributes.map((_) {
        return StaggeredTile.count(1, 0.4);
      }).toList(),
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 8.0,
    );
  }

  void dialogoption(BuildContext context) async {
    _scrollController.animateTo(0,
        duration: Duration(milliseconds: 10), curve: Curves.linear);

    bool loadDropOne = false;
    bool loadDropTwo = false;
    _controller = await _scaffoldKey.currentState.showBottomSheet((context) {
      return StatefulBuilder(builder: (
        context,
        setState,
      ) {
        return Directionality(
          textDirection:
              globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
          child: StatefulBuilder(builder: (context, setState) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                              globals.loc == 'en'
                                  ? 'Select Size / Colour'
                                  : 'اختر الحجم/اللون',
                              style: TextStyle(fontSize: 22))),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Align(
                            alignment: globals.loc == 'en'
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context, false);
                              },
                              child:
                                  Text(globals.loc == 'en' ? 'Done' : 'اغلاق',
                                      style: TextStyle(
                                        fontSize: 22,
                                        decoration: TextDecoration.underline,
                                      )),
                            )),
                      ),
                    ),
                  ]),
                  attributes[0].type == '1'
                      ? Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                          child: Row(children: [
                            Text(
                              globals.loc == 'en' ? ' Color: ' : 'اللون:   ',
                              style: TextStyle(fontSize: 22),
                            ),
                            Text(
                              '$selectcolor ',
                              style: TextStyle(fontSize: 22, color: yellow),
                            ),
                          ]))
                      : Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                          child: Text(
                            globals.loc == 'en'
                                ? ' Size: $selectsize'
                                : 'الحجم:  $selectsize ',
                            style: TextStyle(fontSize: 22),
                          )),
                  attributes[0].type == '1'
                      ? Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                          child: Container(
                              height: 180,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: List.generate(
                                          attributes[0].list.length,
                                          (index) => Container(
                                              child: GestureDetector(
                                                  onTap: () {},
                                                  child: Column(children: [
                                                    SpecialOfferCard2(
                                                      id: attributes[0]
                                                          .list[index]
                                                          .id,
                                                      image: attributes[0]
                                                          .list[index]
                                                          .imagecolor,
                                                      title: attributes[0]
                                                          .list[index]
                                                          .option,
                                                      quantity: attributes[0]
                                                          .list[index]
                                                          .quantity,
                                                      press: () {
                                                        setState(() {
                                                          selectcolor =
                                                              attributes[0]
                                                                  .list[index]
                                                                  .option;
                                                          sortSelect =
                                                              attributes[0]
                                                                  .list[index]
                                                                  .id;

                                                          setState(() {
                                                            getbannercolor(
                                                                sortSelect,
                                                                sortSelect2,
                                                                '1');
                                                          });
                                                        });
                                                      },
                                                      sortSelected: sortSelect,
                                                    ),
                                                    attributes[0]
                                                                .list[index]
                                                                .id ==
                                                            sortSelect
                                                        ? Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              attributes[0]
                                                                  .list[index]
                                                                  .option,
                                                              style: TextStyle(
                                                                  fontSize: 22,
                                                                  color:
                                                                      yellow),
                                                            ))
                                                        : Container(),
                                                  ])))),
                                    ),
                                  ))))
                      : Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                          child: Container(
                            height: 50,
                            child: ListView.builder(
                                itemCount: attributes[0].list.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectsize =
                                            attributes[0].list[index].option;
                                        sortSelect2 =
                                            attributes[0].list[index].id;
                                        sortSelect = "0";

                                        setState(() {
                                          getbannercolor(
                                              sortSelect, sortSelect2, '0');
                                        });
                                      });
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 7.5, horizontal: 7.5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: sortSelect2 ==
                                                        attributes[0]
                                                            .list[index]
                                                            .id
                                                    ? 3
                                                    : 0,
                                                color: sortSelect2 ==
                                                        attributes[0]
                                                            .list[index]
                                                            .id
                                                    ? yellow
                                                    : Colors.black)),
                                      ),
                                      child: Text(
                                        attributes[0].list[index].option,
                                        style: attributes[0]
                                                    .list[index]
                                                    .quantity ==
                                                '0'
                                            ? TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    HexColor('#d13c26'),
                                                decorationThickness: 2,
                                                fontSize: 22,
                                                color: sortSelect2 ==
                                                        attributes[0]
                                                            .list[index]
                                                            .id
                                                    ? yellow
                                                    : Colors.black)
                                            : TextStyle(
                                                fontSize: 22,
                                                color: sortSelect2 ==
                                                        attributes[0]
                                                            .list[index]
                                                            .id
                                                    ? yellow
                                                    : Colors.black),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                  attributes.length == 2
                      ? Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                          child: Text(
                            globals.loc == 'en' ? ' Size: ' : 'الحجم:  ',
                            style: TextStyle(fontSize: 22),
                          ))
                      : Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                        ),
                  attributes.length == 2
                      ? Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                          child: Container(
                            height: 50,
                            child: ListView.builder(
                                itemCount: attributes[1].list.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectsize =
                                            attributes[1].list[index].option;
                                        sortSelect2 =
                                            attributes[1].list[index].id;

                                        setState(() {
                                          getbannercolor(
                                              sortSelect, sortSelect2, '0');
                                        });
                                      });
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 7.5, horizontal: 7.5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: sortSelect2 ==
                                                        attributes[1]
                                                            .list[index]
                                                            .id
                                                    ? 3
                                                    : 0,
                                                color: sortSelect2 ==
                                                        attributes[1]
                                                            .list[index]
                                                            .id
                                                    ? yellow
                                                    : Colors.black)),
                                      ),
                                      child: Text(
                                        attributes[1].list[index].option,
                                        style: attributes[1]
                                                    .list[index]
                                                    .quantity ==
                                                '0'
                                            ? TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    HexColor('#d13c26'),
                                                decorationThickness: 2,
                                                fontSize: 22,
                                                color: sortSelect2 ==
                                                        attributes[1]
                                                            .list[index]
                                                            .id
                                                    ? yellow
                                                    : Colors.black)
                                            : TextStyle(
                                                fontSize: 22,
                                                color: sortSelect2 ==
                                                        attributes[1]
                                                            .list[index]
                                                            .id
                                                    ? yellow
                                                    : Colors.black),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        )
                      : Container(),
                  Row(children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: quantity2 <= 1
                                  ? null
                                  : () async {
                                      setState(() {
                                        quantity2--;
                                      });
                                    },
                              child: Container(
                                decoration: BoxDecoration(),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  color: yellow,
                                  size: 32,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              quantity2.toString(),
                              style: TextStyle(fontSize: 32),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: (quantity2 + 1) > attquant
                                  ? null
                                  : () async {
                                      setState(() {
                                        quantity2++;
                                      });

                                      // widget.tap();
                                    },
                              child: Container(
                                decoration: BoxDecoration(),
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: yellow,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  load
                      ? Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(yellow),
                          ),
                        )
                      : Container(
                          child: Column(
                            children: [
                              flag != '1'
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: RaisedButton(
                                                elevation: 0,
                                                color: Colors.grey[800],
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 15),
                                                child: Text(
                                                  enablebag == '1'
                                                      ? globals.loc == 'en'
                                                          ? 'Add to Bag'
                                                          : 'اضف الى الحقيبة'
                                                      : globals.loc == 'en'
                                                          ? 'Sorry! Product out of sold'
                                                          : 'آسف! المنتج غير متوفر ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                                onPressed: () async {
                                                  if (enablebag == '1') {
                                                    // if (_formKey.currentState.validate()) {
                                                    setState(() {
                                                      load = true;
                                                    });
                                                    String attr = '';
                                                    String cust = '';
                                                    for (int i = 0;
                                                        i < attributes.length;
                                                        i++) {
                                                      if (i == 0)
                                                        attr = attr +
                                                            '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                                                       <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                      else if (i == 1)
                                                        attr = attr +
                                                            '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                                                         <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                    }
                                                    for (int i = 0;
                                                        i < custom.length;
                                                        i++) {
                                                      String cus = custom[i]
                                                                  .type ==
                                                              '2'
                                                          ? custom[i]
                                                              .controller
                                                              .text
                                                              .replaceAll(
                                                                  '&', '?and?')
                                                          : custom[i].type ==
                                                                  '3'
                                                              ? custom[i]
                                                                  .selectsubitem
                                                              : custom[i]
                                                                  .controller
                                                                  .text;
                                                      cust = cust +
                                                          '''<bagcustom>
                      <ID>${custom[i].id}</ID>
                      <ClientResponse>$cus</ClientResponse>
                    </bagcustom>''';
                                                    }
                                                    String soap =
                                                        '''<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <AddToBagV2 xmlns="http://Craft.WS/">
                  <CustomerID>${globals.user.id}</CustomerID>
                  <ProductID>${widget.productID}</ProductID>
                  <UUID></UUID>
            
                  <AttrbuiteList>
                    $attr
                  </AttrbuiteList>
                  <CustomList>
                    $cust
                  </CustomList>
                        <isbuy>0</isbuy>
                   <quantity>$quantity2</quantity>

                </AddToBagV2>
              </soap:Body>
            </soap:Envelope>''';
                                                    http.Response response =
                                                        await http
                                                            .post(
                                                                'https://craftapp.net/services/CraftWebService.asmx',
                                                                headers: {
                                                                  "SOAPAction":
                                                                      "http://Craft.WS/AddToBagV2",
                                                                  "Content-Type":
                                                                      "text/xml;charset=UTF-8",
                                                                },
                                                                body:
                                                                    utf8.encode(
                                                                        soap),
                                                                encoding: Encoding
                                                                    .getByName(
                                                                        "UTF-8"))
                                                            .then((onValue) {
                                                      return onValue;
                                                    });
                                                    String json = parse(
                                                            response.body)
                                                        .getElementsByTagName(
                                                            'AddToBagV2Result')[0]
                                                        .text;
                                                    //final decoded = jsonDecode(json);
                                                    setState(() {
                                                      load = false;
                                                    });
                                                    Navigator.pop(context);
                                                  }
                                                }),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              flag != '1'
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: RaisedButton(
                                                elevation: 0,
                                                color: yellow,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 10),
                                                child: Text(
                                                  enablebag == '1'
                                                      ? globals.loc == 'en'
                                                          ? 'Buy Now'
                                                          : 'اشتري الآن'
                                                      : globals.loc == 'en'
                                                          ? 'Sorry! Product out of sold'
                                                          : 'آسف! المنتج غير متوفر ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                                onPressed: () async {
                                                  if (enablebag == '1') {
                                                    //   if (_formKey.currentState.validate()) {
                                                    setState(() {
                                                      load = true;
                                                    });
                                                    String attr = '';
                                                    String cust = '';
                                                    for (int i = 0;
                                                        i < attributes.length;
                                                        i++) {
                                                      if (i == 0)
                                                        attr = attr +
                                                            '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                                                       <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                      else if (i == 1)
                                                        attr = attr +
                                                            '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                                                         <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                    }
                                                    for (int i = 0;
                                                        i < custom.length;
                                                        i++) {
                                                      String cus = custom[i]
                                                                  .type ==
                                                              '2'
                                                          ? custom[i]
                                                              .controller
                                                              .text
                                                              .replaceAll(
                                                                  '&', '?and?')
                                                          : custom[i].type ==
                                                                  '3'
                                                              ? custom[i]
                                                                  .selectsubitem
                                                              : custom[i]
                                                                  .controller
                                                                  .text;
                                                      cust = cust +
                                                          '''<bagcustom>
                      <ID>${custom[i].id}</ID>
                      <ClientResponse>$cus</ClientResponse>
                    </bagcustom>''';
                                                    }
                                                    String soap =
                                                        '''<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <AddToBagV2 xmlns="http://Craft.WS/">
                  <CustomerID>${globals.user.id}</CustomerID>
                  <ProductID>${widget.productID}</ProductID>
                  <UUID></UUID>
            
                  <AttrbuiteList>
                    $attr
                  </AttrbuiteList>
                  <CustomList>
                    $cust
                  </CustomList>
                        <isbuy>1</isbuy>
                   <quantity>$quantity2</quantity>

                </AddToBagV2>
              </soap:Body>
            </soap:Envelope>''';
                                                    http.Response response =
                                                        await http
                                                            .post(
                                                                'https://craftapp.net/services/CraftWebService.asmx',
                                                                headers: {
                                                                  "SOAPAction":
                                                                      "http://Craft.WS/AddToBagV2",
                                                                  "Content-Type":
                                                                      "text/xml;charset=UTF-8",
                                                                },
                                                                body:
                                                                    utf8.encode(
                                                                        soap),
                                                                encoding: Encoding
                                                                    .getByName(
                                                                        "UTF-8"))
                                                            .then((onValue) {
                                                      return onValue;
                                                    });
                                                    String json = parse(
                                                            response.body)
                                                        .getElementsByTagName(
                                                            'AddToBagV2Result')[0]
                                                        .text;
                                                    //final decoded = jsonDecode(json);
                                                    setState(() {
                                                      load = false;
                                                    });

                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CheckoutOne(
                                                                    name: '',
                                                                    email:
                                                                        '')));
                                                  }
                                                }

                                                // }
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              flag == '1'
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: RaisedButton(
                                                elevation: 0,
                                                color: HexColor("#a8d6ed"),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 10),
                                                child: Text(
                                                  globals.loc == 'en'
                                                      ? 'Custom Request'
                                                      : 'تخصيص الطلب ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 20),
                                                ),
                                                onPressed: () async {
                                                  dialogcustomize(context);
                                                }

                                                // }
                                                ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        )
                ],
              ),
            );
          }),
        );
      });
    });
  }

  void dialogcustomize(BuildContext context) async {
    _controllercustom =
        await _scaffoldKey.currentState.showBottomSheet((context) {
      return StatefulBuilder(builder: (
        context,
        setState,
      ) {
        return Directionality(
            textDirection:
                globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
            child: Container(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top + 10,
                      ),
                      Header(),
                      Row(children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Align(
                                alignment: globals.loc == 'en'
                                    ? Alignment.topLeft
                                    : Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    Navigator.pop(context, false);
                                  },
                                  child: Text(
                                      globals.loc == 'en' ? 'Done' : 'اغلاق',
                                      style: TextStyle(
                                        fontSize: 22,
                                        decoration: TextDecoration.underline,
                                      )),
                                )),
                          ),
                        ),
                      ]),
                      flag == '0'
                          ? Container(
                              height: 0,
                              width: 0,
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.width * 1.5,
                                    decoration: BoxDecoration(
                                        //borderRadius: BorderRadius.circular(8)
                                        ),
                                    child: Image.network(customPhoto,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.fill,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                    }),
                                  ),
                                ),
                              ],
                            ),
                      Container(
                        height: 20,
                        width: 0,
                      ),
                      flag == '0'
                          ? Container(
                              height: 0,
                              width: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                right: 20,
                                left: 20,
                              ),
                              child: Text(
                                globals.loc == 'en'
                                    ? 'Custom Requests'
                                    : 'مواصفات اضافية',
                                style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      flag == '0'
                          ? Container(
                              height: 0,
                              width: 0,
                            )
                          : custom.length == 0
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(
                                    right: 20,
                                    left: 20,
                                  ),
                                  child: Text(
                                    globals.loc == 'en'
                                        ? 'Please fill all fields down to prepare your order'
                                        : 'يرجى تعبئة جميع الحقول لتجهيز طلبك',
                                    style: TextStyle(
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                      delivery != ''
                          ? Container(
                              height: 0,
                              width: 0,
                            )
                          : Container(),
                      delivery != ''
                          ? Padding(
                              padding: EdgeInsets.only(
                                right: 20,
                                left: 20,
                              ),
                              child: Text(
                                globals.loc == 'en'
                                    ? 'execution time ' + delivery
                                    : 'مدة التنفيذ ' + delivery,
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: HexColor('#e85d64')),
                              ),
                            )
                          : Container(),
                      Container(
                        height: 10,
                        width: 0,
                      ),
                      flag == '0'
                          ? Container(
                              height: 0,
                              width: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  right: 10, left: 10, bottom: 20, top: 10),
                              child: Form(
                                key: _formKey,
                                child: sliverGridWidgetCustom(context, img),
                              ),
                            ),
                      Row(children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: quantity3 <= 1
                                      ? null
                                      : () async {
                                          setState(() {
                                            quantity3--;
                                          });
                                        },
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: yellow,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(quantity3.toString(),
                                    style: TextStyle(fontSize: 32)),
                                SizedBox(
                                  width: 15,
                                ),
                                GestureDetector(
                                  onTap: (quantity3 + 1) > defquant
                                      ? null
                                      : () async {
                                          setState(() {
                                            quantity3++;
                                          });

                                          // widget.tap();
                                        },
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      color: yellow,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 10,
                      ),
                      load
                          ? Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor:
                                    new AlwaysStoppedAnimation<Color>(yellow),
                              ),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: RaisedButton(
                                            elevation: 0,
                                            color: Colors.grey[800],
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 15),
                                            child: Text(
                                              enablebag == '1'
                                                  ? globals.loc == 'en'
                                                      ? 'Add to Bag'
                                                      : 'اضف الى الحقيبة'
                                                  : globals.loc == 'en'
                                                      ? 'Sorry! Product out of sold'
                                                      : 'آسف! المنتج غير متوفر ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            onPressed: () async {
                                              if (enablebag == '1') {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  setState(() {
                                                    load = true;
                                                  });
                                                  String attr = '';
                                                  String cust = '';
                                                  for (int i = 0;
                                                      i < attributes.length;
                                                      i++) {
                                                    if (i == 0)
                                                      attr = attr +
                                                          '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                                                       <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                    else if (i == 1)
                                                      attr = attr +
                                                          '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                                                         <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                  }

                                                  for (int i = 0;
                                                      i < custom.length;
                                                      i++) {
                                                    String cus = custom[i]
                                                                .type ==
                                                            '2'
                                                        ? custom[i]
                                                            .controller
                                                            .text
                                                            .replaceAll(
                                                                '&', '?and?')
                                                        : custom[i].type == '3'
                                                            ? custom[i]
                                                                .selectsubitem
                                                            : custom[i]
                                                                .controller
                                                                .text;

                                                    cust = cust +
                                                        '''<bagcustom>
                      <ID>${custom[i].id}</ID>
                      <ClientResponse>$cus</ClientResponse>
                    </bagcustom>''';
                                                  }
                                                  String soap =
                                                      '''<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <AddToBagV2 xmlns="http://Craft.WS/">
                  <CustomerID>${globals.user.id}</CustomerID>
                  <ProductID>${widget.productID}</ProductID>
                  <UUID></UUID>
            
                  <AttrbuiteList>
                    $attr
                  </AttrbuiteList>
                  <CustomList>
                    $cust
                  </CustomList>
                        <isbuy>0</isbuy>
                   <quantity>$quantity3</quantity>

                </AddToBagV2>
              </soap:Body>
            </soap:Envelope>''';
                                                  http.Response response =
                                                      await http
                                                          .post(
                                                              'https://craftapp.net/services/CraftWebService.asmx',
                                                              headers: {
                                                                "SOAPAction":
                                                                    "http://Craft.WS/AddToBagV2",
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
                                                  String json = parse(
                                                          response.body)
                                                      .getElementsByTagName(
                                                          'AddToBagV2Result')[0]
                                                      .text;
                                                  //final decoded = jsonDecode(json);
                                                  setState(() {
                                                    load = false;
                                                  });
                                                  Navigator.pop(context);
                                                }
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: RaisedButton(
                                            elevation: 0,
                                            color: yellow,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 15),
                                            child: Text(
                                              enablebag == '1'
                                                  ? globals.loc == 'en'
                                                      ? 'Buy Now'
                                                      : 'اشتري الآن'
                                                  : globals.loc == 'en'
                                                      ? 'Sorry! Product out of sold'
                                                      : 'آسف! المنتج غير متوفر ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            onPressed: () async {
                                              if (enablebag == '1') {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  setState(() {
                                                    load = true;
                                                  });
                                                  String attr = '';
                                                  String cust = '';
                                                  for (int i = 0;
                                                      i < attributes.length;
                                                      i++) {
                                                    if (i == 0)
                                                      attr = attr +
                                                          '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                                                       <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                    else if (i == 1)
                                                      attr = attr +
                                                          '''<bagatt>
                                             <DropTitleID>${attributes[i].id}</DropTitleID>
                                                                                         <ClientSelectionID> ${attributes[i].type == '0' ? sortSelect2 : sortSelect}</ClientSelectionID>

                                           </bagatt>''';
                                                  }

                                                  for (int i = 0;
                                                      i < custom.length;
                                                      i++) {
                                                    String cus = custom[i]
                                                                .type ==
                                                            '2'
                                                        ? custom[i]
                                                            .controller
                                                            .text
                                                            .replaceAll(
                                                                '&', '?and?')
                                                        : custom[i].type == '3'
                                                            ? custom[i]
                                                                .selectsubitem
                                                            : custom[i]
                                                                .controller
                                                                .text;
                                                    cust = cust +
                                                        '''<bagcustom>
                      <ID>${custom[i].id}</ID>
                      <ClientResponse>$cus</ClientResponse>
                    </bagcustom>''';
                                                  }
                                                  String soap =
                                                      '''<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <AddToBagV2 xmlns="http://Craft.WS/">
                  <CustomerID>${globals.user.id}</CustomerID>
                  <ProductID>${widget.productID}</ProductID>
                  <UUID></UUID>
            
                  <AttrbuiteList>
                    $attr
                  </AttrbuiteList>
                  <CustomList>
                    $cust
                  </CustomList>
                        <isbuy>1</isbuy>
                   <quantity>$quantity3</quantity>
                </AddToBagV2>
              </soap:Body>
            </soap:Envelope>''';
                                                  http.Response response =
                                                      await http
                                                          .post(
                                                              'https://craftapp.net/services/CraftWebService.asmx',
                                                              headers: {
                                                                "SOAPAction":
                                                                    "http://Craft.WS/AddToBagV2",
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
                                                  String json = parse(
                                                          response.body)
                                                      .getElementsByTagName(
                                                          'AddToBagV2Result')[0]
                                                      .text;
                                                  //final decoded = jsonDecode(json);
                                                  setState(() {
                                                    load = false;
                                                  });

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CheckoutOne(
                                                                  name: '',
                                                                  email: '')));
                                                }
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
            ));
      });
    });
  }

  Widget sliverGridWidgetCustom(BuildContext context, String img) {
    return Container(
        child: ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10, right: 10, left: 10),
              child: Container(
                  decoration: BoxDecoration(),
                  // padding: EdgeInsets.symmetric(
                  //     horizontal: 20, vertical: 7.5),
                  child: Column(
                    children: [
                      Align(
                          alignment: globals.loc == 'en'
                              ? Alignment.topLeft
                              : Alignment.topRight,
                          child: Text(
                            custom[index].title,
                            style: TextStyle(fontSize: 24),
                          )),
                      Visibility(
                        visible: custom[index].type == '2' ? false : true,
                        child: custom[index].type != '3'
                            ? TextFormField(
                                keyboardType: custom[index].type == '0'
                                    ? TextInputType.text
                                    : TextInputType.number,
                                readOnly:
                                    custom[index].type == '2' ? true : false,
                                style: TextStyle(fontSize: 22),
                                controller: custom[index].controller,
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
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    labelStyle: TextStyle(
                                        color: Colors.black, fontSize: 30),
                                    isDense: true))
                            : Container(
                                constraints: BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: DropdownButtonFormField<SubCustom>(
                                  isDense: true,
                                  hint: Text(
                                      globals.loc == 'en'
                                          ? 'Please Select'
                                          : 'يرجى الاختيار',
                                      style: TextStyle(fontSize: 18)),
                                  onChanged: (value) {
                                    setState(() {
                                      custom[index].selectsubitem = value.id;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return globals.loc == 'en'
                                          ? 'Required'
                                          : 'مطلوب';
                                    } else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                      border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white))),
                                  // value: widget.selected,
                                  items: custom[index].subitems.map((e) {
                                    return DropdownMenuItem<SubCustom>(
                                      value: e,
                                      child: Align(
                                        alignment: globals.loc != 'en'
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          e.title,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                      custom[index].type == '2'
                          ? GestureDetector(
                              onTap: () async {
                                try {
                                  file = await FilePicker.getFile(
                                      type: FileType.image);

                                  if (file != null) {
                                    String fname = fileName +
                                        DateTime.now().toIso8601String();
                                    _controllercustom.setState(() {
                                      loadingcustom = true;
                                    });

                                    StorageReference storageReference;
                                    storageReference = FirebaseStorage.instance
                                        .ref()
                                        .child("custom/$fname");

                                    /* start */

                                    /*     var bytesdata = file.readAsBytes();
                                    var headers = {
                                      'Content-Type': 'text/plain'
                                    };
                                    var request = http.Request(
                                        'PUT',
                                        Uri.parse(
                                            'https://ynjulllfe5.execute-api.us-east-1.amazonaws.com/upimg/craftappimages/Custom/'+ fname));
                                    request.body = '$bytesdata';

                                    request.headers.addAll(headers);

                                    http.StreamedResponse response =
                                        await request.send();

                                    if (response.statusCode == 200) {
                                      print(await response.stream
                                          .bytesToString());
                                    } else {
                                      print(response.reasonPhrase);
                                    }

 */ /* end */
                                    task = storageReference.putFile(file);
                                    var dowurl = await (await task.onComplete)
                                        .ref
                                        .getDownloadURL();
                                    _controllercustom.setState(() {
                                      image = dowurl.toString();
                                      loadingcustom = false;

                                      custom[index].controller.text = image;
                                      img = image;
                                    });
                                  }
                                } on PlatformException catch (e) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Sorry...'),
                                          content:
                                              Text('Unsupported exception: $e'),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                }
                                _controllercustom.setState(() {});
                              },
                              child: Column(children: [
                                TextFormField(
                                    enabled: false,
                                    style: TextStyle(fontSize: 20),
                                    validator: (val) {
                                      if (custom[index].controller.text == '')
                                        return globals.loc == 'en'
                                            ? 'Required'
                                            : 'مطلوب';
                                      else
                                        return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.image, size: 22),
                                        hintStyle: TextStyle(
                                          fontSize: 20.0,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        isDense: true)),
                                custom[index].controller.text != ''
                                    ? SizedBox(
                                        height: 10,
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ),
                                loadingcustom
                                    ? Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(yellow),
                                          ),
                                        ),
                                      )
                                    : custom[index].controller.text != ''
                                        ? Align(
                                            alignment: globals.loc != 'en'
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: ClipRRect(
                                              /*  borderRadius: BorderRadius.circular(12), */
                                              child: Image.network(
                                                custom[index].controller.text,
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent
                                                            loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    height: 100,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(yellow),
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
                                                height: 100,
                                                width: 100,
                                                /* fit: BoxFit.fill, */
                                              ),
                                            ),
                                          )
                                        : Container(),
                              ]))
                          : Container(),
                    ],
                  )
                  /*      custom[index].type == "0" || custom[index].type == "1"
                    ?  */
                  ),
            );
          },
        );
      },
      itemCount: custom.length,
    ));
  }

  callbackFunction(int i, CarouselPageChangedReason reason) {
    setState(() {
      index = i;
    });
  }
}

class Property {
  final String title;
  final String description;
  Property({@required this.title, @required this.description});
}

class DropList {
  final String id;
  final String option;
  final String imagecolor;
  final String quantity;

  DropList(
      {@required this.id,
      @required this.option,
      @required this.imagecolor,
      @required this.quantity});
}

class Attribute {
  final String id;
  final String title;
  List<DropList> list;
  DropList currentSelect;
  final String type;

  Attribute(
      {@required this.id,
      @required this.list,
      @required this.title,
      @required this.currentSelect,
      @required this.type});
}

class Custom {
  final String id;
  final String title;
  String selectsubitem;

  TextEditingController controller;
  TextEditingController controller2;

  final String type;
  final List<SubCustom> subitems;

  Custom(
      {@required this.id,
      @required this.title,
      @required this.controller,
      @required this.type,
      @required this.controller2,
      @required this.subitems,
      @required this.selectsubitem});
}

class SubCustom {
  final String id;
  final String title;

  SubCustom({
    @required this.id,
    @required this.title,
  });
}

class MayWidget extends StatefulWidget {
  final String brand;
  final String title;
  final String id;
  final String price;
  final String image;
  final String by;
  final String fav;
  MayWidget(
      {@required this.image,
      @required this.fav,
      @required this.id,
      @required this.brand,
      @required this.title,
      @required this.price,
      @required this.by});
  @override
  _MayWidgetState createState() => _MayWidgetState();
}

class _MayWidgetState extends State<MayWidget> {
  String fav;
  @override
  void initState() {
    fav = widget.fav;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                      productID: widget.id,
                    )));
      },
      child: Container(
        decoration: BoxDecoration(),
        margin: EdgeInsets.symmetric(horizontal: 10),
        height: 300,
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    height: 225,
                    width: 150,
                    child: ClipRRect(
                      /*  borderRadius: BorderRadius.circular(12), */
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
                        fit: BoxFit.fill,
                        /* fit: BoxFit.fill, */
                      ),
                    ),
                  ),
                  globals.user.id != '0'
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(top: 7.5),
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
      <ProductID>${widget.id}</ProductID>
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
                          ),
                        )
                      : Align()
                ],
              ),
            ),
            SizedBox(
              height: 7.5,
            ),
            AutoSizeText(
              widget.brand,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            SizedBox(
              height: 7.5,
            ),
            AutoSizeText(widget.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            AutoSizeText(
              widget.by,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: yellow, fontSize: 14),
            ),
            SizedBox(
              height: 7.5,
            ),
            AutoSizeText(
              '${widget.price} SAR',
              textDirection: TextDirection.ltr,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }
}

class SpecialOfferCard2 extends StatelessWidget {
  const SpecialOfferCard2(
      {@required this.image,
      @required this.title,
      @required this.press,
      @required this.sortSelected,
      @required this.id,
      @required this.quantity});

  final String image, title, sortSelected, id, quantity;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: GestureDetector(
        onTap: press,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  width: sortSelected == id ? 3 : 0,
                  color:
                      sortSelected == id ? Colors.transparent : Colors.black),
              color:
                  sortSelected == id ? Color(0xFFE7BB1F) : Colors.transparent),
          child: SizedBox(
            width: 80,
            height: 120,
            child: ClipRRect(
              child: Stack(
                children: [
                  Image.network(
                    image,
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
                    fit: BoxFit.fill,
                    /*  fit: BoxFit.fill, */

                    height: double.infinity,
                    width: double.infinity,
                  ),
                  if (quantity == '0')
                    CustomPaint(
                      //                       <-- CustomPaint widget
                      size: Size(80, 120),
                      painter: MyPainter(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  //         <-- CustomPainter class
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(0, 0);
    final p2 = Offset(80, 120);
    final paint = Paint()
      ..color = HexColor('#d13c26')
      ..strokeWidth = 2;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
