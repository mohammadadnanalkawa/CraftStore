import 'package:auto_size_text/auto_size_text.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/screens/checkout_complete.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/screens/returncheckout.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';

class ReturnDetails extends StatefulWidget {
  final String id;
  ReturnDetails({@required this.id});
  @override
  _ReturnDetailsState createState() => _ReturnDetailsState();
}

class _ReturnDetailsState extends State<ReturnDetails> {
  String title;
  String date;
  String count;
  String status;
  String reason;
  String returntype;
  String address;
  String addresstxt;
  String phone;
  String bill;
  String amount;


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

  bool loading = false;
  List<ItemWidget> items = <ItemWidget>[];
  void loadData() async {
    setState(() {
      loading = true;
    });
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetRequestByID xmlns="http://Craft.WS/">
      <RequestID>${widget.id}</RequestID>
    </GetRequestByID>
  </soap:Body>
</soap:Envelope>''';
    http.Response response = await http
        .post('https://craftapp.net/services/CraftWebService.asmx',
            headers: {
              "SOAPAction": "http://Craft.WS/GetRequestByID",
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
          .getElementsByTagName('GetRequestByIDResult')[0]
          .text;
      var decoded = jsonDecode(json);
      print(decoded);
      title = decoded['Title'];
      date = decoded['Date'];
      count = decoded['ItemCounter'];
      status = decoded['Status'];
      reason = decoded['Reason'];
      returntype = decoded['ReturnType'];
      address = decoded['LocationTitle'];
      addresstxt = decoded['Location'];
      phone = decoded['phone'];
      bill = decoded['EnableBill'];
      amount = decoded['Amount'];


      decoded = decoded['ProductList'];
      for (int i = 0; i < decoded.length; i++) {
        items.add(ItemWidget(
            brand: decoded[i]['Brand'],
            by: decoded[i]['By'],
            title: decoded[i]['Title'],
            id: decoded[i]['ReturnID'],
            price: decoded[i]['Price'],
            image: decoded[i]['Photo'],
            status: decoded[i]['Status'],
            type:  decoded[i]['type'],
            reason:  decoded[i]['reason'],));
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
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
            :    Column(children: [
       SizedBox(
                                         height: MediaQuery.of(context).padding.top + 10,

                ),
                Header(),
                Divider(),
            Expanded(
              child:
               Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBarOne(
                      implyLeading: true,
                      text: title,
                      press: () {
                        Navigator.pop(context);
                      },
                      textColor: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    globals.loc == 'en'
                                        ? 'Date: $date'
                                        : 'التاريخ: $date',
                                    style: TextStyle(
                                        fontSize: 19, color: Colors.grey[700])),
                                SizedBox(height: 5),
                                 SizedBox(height: 5),
                                Text(
                                    globals.loc == 'en'
                                           ? 'Pickup Location:'
                                                            : 'موقع الاستلام',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black, )),
                               
                                Text(address, style: TextStyle(fontSize: 19)) ,
                                SizedBox(height: 5),
                                
                                Text(addresstxt, style: TextStyle(fontSize: 19)) ,
                                  Text(
                                    globals.loc == 'en'
                                        ? 'Return Type: $returntype'
                                        : 'طريقة الارجاع : $returntype',
                                    style: TextStyle(fontSize: 19)),
                                SizedBox(height: 5),
                                bill != '0'? Divider(): Container(),

                                bill != '0'?
                                Row(children: [
                                  Text(globals.loc == 'en' ? 
                                  'Please pay the shipping fees to complete the process':
                                  'يرجى تسديد مصاريف الشحن لاتمام العملية', style: TextStyle(fontSize: 20),),
                                 SizedBox(width: 10,),
                                 
                                   Expanded(
                                                child: RaisedButton(
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(),
                                                    color: Colors.grey[800],
                                                   
                                                    child: Text(
                                                      globals.loc == 'en'
                                                         ? 'Pay Now'
                                                          : 'ادفع الان',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white, fontSize: 18),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ReturnCheckout(total: amount,reqID: widget.id,)));
                                                    }),
                                              ),
                                ],):
                                 Container(),
                                
                              /*   Text(
                                    globals.loc == 'en'
                                        ? 'Return Type: $returntype'
                                        : 'طريقة الارجاع : $returntype',
                                    style: TextStyle(fontSize: 19)),
                                SizedBox(height: 5),
                                Text(
                                    globals.loc == 'en'
                                        ? 'Return Reason : '
                                        : 'سبب الارجاع: ',
                                    style: TextStyle(
                                        fontSize: 19, color: Colors.grey[700])),
                                SizedBox(height: 5),
                                Text(reason, style: TextStyle(fontSize: 19)) */
                              ],
                            ),
                          ),
                    /*       SizedBox(width: 20),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 7.5),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.yellow[700])),
                            child: Text(
                              status,
                              style: TextStyle(color: Colors.yellow[700], fontSize: 19),
                            ),
                          )
                      */   ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(globals.loc == 'en' ? 'Products' : 'المنتجات',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) => items[index],
                      ),
                    )
                  ],
                ),
              ),
            )]),
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

class ItemWidget extends StatefulWidget {
  final String by;
  final String brand;
  final String title;
  final String id;
  final String price;
  final String image;
  final String status;
  final String type;
  final String reason;


  ItemWidget({
    @required this.brand,
    @required this.by,
    @required this.title,
    @required this.id,
    @required this.price,
    @required this.image,
    @required this.status,
    @required this.type,
    @required this.reason

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
          Row(children: [
            Text(widget.type + ': '+ widget.reason, style: TextStyle(fontSize: 20),)
          ],),
          SizedBox(height: 10,),
          Row(
            children: [
              SizedBox(
                 height: 120,
                      width: 80,
                child: ClipRRect(
                    
                    child:  widget.image == '' ? Container(): Image.network(
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
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      widget.brand,
                      style: TextStyle(color: Colors.grey[700], fontSize: 18),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    AutoSizeText(
                      widget.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                   /*  AutoSizeText(
                      widget.by,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: yellow,
                          fontSize: 18),
                    ),
                    SizedBox(
                      height: 3,
                    ), */
                    AutoSizeText(
                      '${widget.price} SAR',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                      SizedBox(width: 20),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 1, horizontal: 5),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.yellow[700])),
                            child: Text(
                              widget.status,
                              style: TextStyle(color: Colors.yellow[700], fontSize: 19),
                            ),
                          )
                     
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
         Divider()
        ],
      ),
    );
  }
}
