import 'package:auto_size_text/auto_size_text.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/screens/checkout_complete.dart';
import 'package:crafts/screens/checkout_error.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/product_details.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:crafts/screens/category_item_list.dart';
import 'package:crafts/helpers/size_config.dart';

import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/notifications.dart';

class FrontPage extends StatefulWidget {
  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> with TickerProviderStateMixin {
  AnimationController _ColorAnimationController;
  Animation _colorTween;
  List<RecommendWidget> recWid = <RecommendWidget>[];
  List<BannerGroup> banWid = <BannerGroup>[];
  List<Banner> subby = <Banner>[];

  String footer = "";

    final _splashDelay = 3000;
  double _height = 10.0;
  AnimationController _animationController;

  bool loading = false;
  void loadData() async {
    setState(() {
      loading = true;
    });
    await getAllBanner();
    //  await getRecommend();
    // await getFooter();
    setState(() {
      loading = false;
    });
  }

  Future<void> getAllBanner() async {
    banWid = [];

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetBannerGroup xmlns="http://Craft.WS/">
    <CustomerID>${globals.user.id != '0' ? globals.user.id : globals.loc}</CustomerID>
    </GetBannerGroup>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetBannerGroup",
              "Content-Type": "text/xml;charset=UTF-8",
            },
            body: utf8.encode(soap),
            encoding: Encoding.getByName("UTF-8"))
        .then((onValue) {
      return onValue;
    });
    print(response.body);
    String json = parse(response.body)
        .getElementsByTagName('GetBannerGroupResult')[0]
        .text;
    final decoded = jsonDecode(json);
    footer = decoded["Footer"];
    for (int i = 0; i < decoded["Banners"].length; i++) {
      subby = [];

      for (int j = 0; j < decoded["Banners"][i]["Subbanner"].length; j++) {
        final sub = decoded["Banners"][i]["Subbanner"][j];
        subby.add(Banner(
          id: sub["ID"],
          referance: sub["Type"],
          photo: sub["Photo"],
          title: sub["Title"],
          catnavigation: sub["Navigation"],
        ));
      }

      banWid
          .add(BannerGroup(type: decoded["Banners"][i]["Type"], subby: subby));
    }

    for (int i = 0; i < decoded["Recommended"].length; i++) {
      recWid.add(RecommendWidget(
        id: decoded["Recommended"][i]['ID'],
        title: decoded["Recommended"][i]['Title'],
        image: decoded["Recommended"][i]['Photo'],
        brand: decoded["Recommended"][i]['Brand'],
        by: decoded["Recommended"][i]['By'],
        price: decoded["Recommended"][i]['Price'],
        fav: decoded["Recommended"][i]['favflag'],
      ));
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _loadWidget() async {
    var _duration = Duration(milliseconds: _splashDelay);
    
  }

  @override
  void initState() {
    super.initState();
       _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animationController.forward();

    _ColorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween = ColorTween(begin: Colors.transparent, end: yellow)
        .animate(_ColorAnimationController);
    loadData();

        _loadWidget();
  }


  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      _ColorAnimationController.animateTo(scrollInfo.metrics.pixels / 350);

      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: loading
          ? Align(
                                    alignment: Alignment.center,
            child: Container(
                width: MediaQuery.of(context).size.width *0.75,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _animationController,
                      child: Image.asset('assets/craftapp.png',),
                    ),
                   
                   /*  CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(yellow),
                    ) */
                  ],
                ),
              ),
          )
          : NotificationListener<ScrollNotification>(
              onNotification: _scrollListener,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Container(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top + 50),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 25,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    globals.loc == 'en'
                                        ? 'Hello, ${globals.user.name}'
                                        : 'مرحبا، ${globals.user.name}',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) =>
                                      banWid[index],
                                  itemCount: banWid.length,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          globals.loc == 'en'
                                              ? 'Recommended for you'
                                              : 'قد يعجبك أيضا',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 400,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return new GestureDetector(
                                          //You need to make my child interactive
                                          onTap: () {
                                            String fav = recWid[index].fav;
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetails(
                                                          favChange: (val) {
                                                            setState(() {
                                                              fav = val;
                                                            });
                                                          },
                                                          favflag: fav,
                                                          productID:
                                                              recWid[index].id,
                                                        )));
                                          },
                                          child: new Container(
                                              //I am the clickable child
                                              child: recWid[index]));
                                    },
                                    itemCount: recWid.length,
                                  ),
                                ),
                                SizedBox(height: 10),
                                !footer.contains('http')
                                    ? Container()
                                    : Container(
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ClipRRect(
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  footer,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent
                                                              loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Container(
                                                      height: 200,
                                                      width:
                                                          MediaQuery.of(context)
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
                                                  },
                                                  fit: BoxFit.fill,
                                                  /*  fit: BoxFit.fill, */
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedBuilder(
                        animation: _ColorAnimationController,
                        builder: (context, child) => Container(
                              color: Colors.white.withOpacity(0.85),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: 20,
                                    left: 20,
                                    bottom: 17.5,
                                    top: MediaQuery.of(context).padding.top +
                                        17.5),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Account()));
                                        /*  if (globals.user.type == '0') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Account()));
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LandingPage()));
                                   
                                  } */
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(),
                                        child: RotatedBox(
                                          quarterTurns: 0,
                                          child: Icon(
                                            CupertinoIcons.person_alt_circle,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(),
                                      child: Icon(
                                        CupertinoIcons.search,
                                        size: 26,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    Spacer(),
                                    globals.loc == 'en'
                                        ? RichText(
                                            text: new TextSpan(
                                              // Note: Styles for TextSpans must be explicitly defined.
                                              // Child text spans will inherit styles from parent
                                              style: new TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: 'CRAFTAPP',
                                                    style: new TextStyle(
                                                      letterSpacing: 2.0,
                                                    )),
                                                new TextSpan(
                                                    text: '.',
                                                    style: new TextStyle(
                                                      color: yellow,
                                                      fontSize: 28,
                                                    )),
                                              ],
                                            ),
                                          )
                                        : RichText(
                                            text: new TextSpan(
                                              // Note: Styles for TextSpans must be explicitly defined.
                                              // Child text spans will inherit styles from parent
                                              style: new TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: '.',
                                                    style: new TextStyle(
                                                      color: yellow,
                                                      fontSize: 28,
                                                    )),
                                                new TextSpan(
                                                    text: 'CRAFTAPP',
                                                    style: new TextStyle(
                                                      letterSpacing: 2.0,
                                                    )),
                                              ],
                                            ),
                                          ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Search(subID: '0')));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(),
                                        child: Icon(
                                          CupertinoIcons.search,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                                 Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Notifications())); 
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(),
                                          child: Icon(CupertinoIcons.bell,
                                              size: 26)),
                                    )
                                  ],
                                ),
                              ),
                            )),
                  ),
                ],
              ),
            ),
    );
  }
}

class RecommendWidget extends StatefulWidget {
  final String brand;
  final String title;
  final String id;
  final String price;
  final String image;
  final String by;
  final String fav;
  RecommendWidget(
      {@required this.image,
      @required this.fav,
      @required this.id,
      @required this.brand,
      @required this.title,
      @required this.price,
      @required this.by});
  @override
  _RecommendWidgetState createState() => _RecommendWidgetState();
}

class _RecommendWidgetState extends State<RecommendWidget> {
  String fav;
  @override
  void initState() {
    fav = widget.fav;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(),
        margin: EdgeInsets.symmetric(horizontal: 10),
        height: 310,
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
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: getProportionateScreenWidth(17)),
            ),
            SizedBox(
              height: 7.5,
            ),
            Text(widget.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getProportionateScreenWidth(18)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(
              widget.by + '\n',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: yellow,
                  fontSize: getProportionateScreenWidth(16)),
              maxLines: 2,
            ),
            SizedBox(
              height: 2,
            ),
            AutoSizeText(
              '${widget.price} SAR',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: getProportionateScreenWidth(17)),
            )
          ],
        ),
      ),
    );
  }
}

class BannerGroup extends StatefulWidget {
  List<Banner> subby = <Banner>[];
  final String type;

  BannerGroup({@required this.type, @required this.subby});
  @override
  _BannerGroupState createState() => _BannerGroupState();
}

class _BannerGroupState extends State<BannerGroup> {
  ScrollController controller = new ScrollController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(seconds: 5),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.type == '2'
              ? SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                          widget.subby.length,
                          (index) => Container(
                              child: GestureDetector(
                                  onTap: () {},
                                  child: SpecialOfferCard2(
                                      image: widget.subby[index].photo,
                                      category: widget.subby[index].referance,
                                      itemID: widget.subby[index].id,
                                      title: widget.subby[index].title,
                                      catnavigation:
                                          widget.subby[index].catnavigation)))),
                    ),
                  ))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 7.5),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: GestureDetector(
                        onTap: () {},
                        child: widget.type == '1'
                            ? SpecialOfferCard(
                                image: widget.subby[index].photo,
                                category: widget.subby[index].referance,
                                itemID: widget.subby[index].id,
                                title: widget.subby[index].title,
                                catnavigation:
                                    widget.subby[index].catnavigation)
                            : widget.type == '3'
                                ? SpecialOfferCard3(
                                    image: widget.subby[index].photo,
                                    category: widget.subby[index].referance,
                                    itemID: widget.subby[index].id,
                                    title: widget.subby[index].title,
                                    catnavigation:
                                        widget.subby[index].catnavigation)
                                : widget.type == '4'
                                    ? SpecialOfferCard4(
                                        image: widget.subby[index].photo,
                                        category: widget.subby[index].referance,
                                        itemID: widget.subby[index].id,
                                        title: widget.subby[index].title,
                                        catnavigation:
                                            widget.subby[index].catnavigation)
                                    : Container(),
                      ),
                    );
                  },
                  itemCount: widget.subby.length,
                )
        ],
      ),
    );
  }
}

class Banner {
  final String id;
  final String referance;
  final String photo;
  final String title;
  final String catnavigation;

  Banner(
      {this.id,
      this.referance,
      @required this.photo,
      @required this.title,
      @required this.catnavigation});
}

class SpecialOfferCard extends StatelessWidget {
  const SpecialOfferCard({
    @required this.category,
    @required this.image,
    @required this.itemID,
    @required this.title,
    @required this.catnavigation,
  });

  final String category, image, title;
  final String itemID, catnavigation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: getProportionateScreenWidth(20),
          right: getProportionateScreenWidth(20)),
      child: GestureDetector(
        onTap: () {
          if (catnavigation == "0") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryItemList(
                        byName: title,
                        byID: '0',
                        mainID: itemID,
                        type: category,
                        filter: '0',
                        bylist: null,
                        from: '',
                        to: '',
                        sortSelected: '',
                        sub1: null,
                        sub2: null,
                        tagList: null,
                        mainCat: null,
                        may: '0',)));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: Home(
                          index: 1,
                          activeId: itemID,
                        ))));
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: getProportionateScreenWidth(100),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpecialOfferCard3 extends StatelessWidget {
  const SpecialOfferCard3({
    @required this.category,
    @required this.image,
    @required this.itemID,
    @required this.title,
    @required this.catnavigation,
  });

  final String category, image, title;
  final String itemID, catnavigation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: getProportionateScreenWidth(20),
          right: getProportionateScreenWidth(20)),
      child: GestureDetector(
        onTap: () {
          if (catnavigation == "0") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryItemList(
                        byName: title,
                        byID: '0',
                        mainID: itemID,
                        type: category,
                        filter: '0',
                        bylist: null,
                        from: '',
                        to: '',
                        sortSelected: '',
                        sub1: null,
                        sub2: null,
                        tagList: null,
                        mainCat: null
                        , may: '0')));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: Home(
                          index: 1,
                          activeId: itemID,
                        ))));
          }
        },
        child: SizedBox(
          width: double.infinity,
          height: getProportionateScreenWidth(300),
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
                  fit: BoxFit.cover,
                  /*  fit: BoxFit.fill, */

                  height: double.infinity,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpecialOfferCard4 extends StatelessWidget {
  const SpecialOfferCard4({
    @required this.category,
    @required this.image,
    @required this.itemID,
    @required this.title,
    @required this.catnavigation,
  });

  final String category, image, title, catnavigation;
  final String itemID;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 0),
      child: GestureDetector(
        onTap: () {
          if (catnavigation == "0") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryItemList(
                        byName: title,
                        byID: '0',
                        mainID: itemID,
                        type: category,
                        filter: '0',
                        bylist: null,
                        from: '',
                        to: '',
                        sortSelected: '',
                        sub1: null,
                        sub2: null,
                        tagList: null,
                        mainCat: null,
                         may: '0')));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: Home(
                          index: 1,
                          activeId: itemID,
                        ))));
          }
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: SizedBox(
            width: double.infinity,
            height: getProportionateScreenWidth(550),
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
                    fit: BoxFit.cover,
                    /*  fit: BoxFit.fill, */

                    height: double.infinity,
                    width: double.infinity,
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

class SpecialOfferCard2 extends StatelessWidget {
  const SpecialOfferCard2({
    @required this.category,
    @required this.image,
    @required this.itemID,
    @required this.title,
    @required this.catnavigation,
  });

  final String category, image, title, catnavigation;
  final String itemID;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(20)),
      child: GestureDetector(
        onTap: () {
          if (catnavigation == "0") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CategoryItemList(
                        byName: title,
                        byID: '0',
                        mainID: itemID,
                        type: category,
                        filter: '0',
                        bylist: null,
                        from: '',
                        to: '',
                        sortSelected: '',
                        sub1: null,
                        sub2: null,
                        tagList: null,
                        mainCat: null,
                         may: '0')));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: Home(
                          index: 1,
                          activeId: itemID,
                        ))));
          }
        },
        child: SizedBox(
          width: getProportionateScreenWidth(100),
          height: getProportionateScreenWidth(170),
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
                  fit: BoxFit.cover,
                  /*  fit: BoxFit.fill, */

                  height: double.infinity,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
