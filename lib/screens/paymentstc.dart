import 'package:crafts/core/color.dart';
import 'package:crafts/screens/checkout_error.dart';
import 'package:crafts/screens/home.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'checkout_complete.dart';

class PaymentStc extends StatefulWidget {
  final String orderID;
  final String amount;
  final String street;
  final String city;
  final String postcode;
      final String username;
  final String email;
  final String isorder;
  

  const PaymentStc(
      {Key key,
      @required this.amount,
      @required this.orderID,
      @required this.street,
      @required this.city,
      @required this.postcode,
       @required this.username,
        @required this.email,
         @required this.isorder})
      : super(key: key);

  @override
  _PaymentStcState createState() => _PaymentStcState();
}

class _PaymentStcState extends State<PaymentStc> {
  bool isLoading = false;
  String id;
  WebViewController _webViewController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    loadRequest();
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

  void loadRequest() async {
    setState(() {
      isLoading = true;
    });
    var headers = {
      'Authorization':
          'Bearer OGFjZGE0Y2E3YmU4NThmNjAxN2JmZDljY2EyMTQzZGN8bW01UHhja25EZQ==',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie':
          'ak_bmsc=C19285FEC3E9A212B393CB465EC43D5F~000000000000000000000000000000~YAAQbkZYaArYWSh7AQAAAcffbQx9BX3E9ut8z65tXpxwp/pubB3s/BNOaYd3VxP6PyYbZ9wuqZ7IXYr7FB/LvwL3xh3nOi0RXeYYc9GKxonahVatMOyXuGqk4++heLh3UQlnvB7ZT5YGbgAYf2TC2wfoITLXL84XDsJzYLUYJHHHmTqer0YZ3uNWl6BVYgygHkVO0WlYq/bPca07VyhieulgvLDGYTzaMAAHoOoJNUKbTPIXs2+pWQeO4FPnQtWpAYlvKLkOQRtVK4vkWxyxcKMdyk6YXjT3tSijUSCckiAoTFsOYT/KSVbRYQWTjAbWG9POqgi+4r2RahWxQqpwAXTlMIBMmFr8aQC3TTZ7Fp8DU7+lKtNieUAc4PI=; bm_sv=500E59A08A7078190479D673798D8FB5~CkRAUDsUOtuCqy69l5/78uJlvwn3/AMsnj3EXbaDLaLv9LYs0VLIKfizgAoy/4CftCIYmi26vJJBWhd3+LkXUSHOe8Qit3UHEq9Dv15aXmeJQWoPev/JUa3w6fzPma3bK9fBZOYBKmcvk6VvjDeJZeKIre5/Ib3pWUPulJoYtZs='
    };
    var request = http.Request(
        'POST', Uri.parse('https://oppwa.com/v1/checkouts'));
    request.bodyFields = {
      'entityId': '8acda4ca7be858f6017bfd9f88f643ed',
      'amount': '${widget.amount}',
      'currency': 'SAR',
      'paymentType': 'DB',
      'merchantTransactionId': '${widget.orderID}',
      'customer.email': '${globals.user.email == '' ? widget.email :globals.user.email }',
      'billing.street1': '${widget.street}',
      'billing.city': '${widget.city}',
      'billing.state': '${widget.city}',
      'billing.postcode': '${widget.postcode}',
      'customer.surname': '${globals.user.name == '' ? widget.username :globals.user.name}',
      'customer.givenName': '${globals.user.name == '' ? widget.username :globals.user.name}',
      'billing.country': 'SA',
      

    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String json;
    if (response.statusCode == 200) {
      json = await response.stream.bytesToString();
    } else {
      print(response.reasonPhrase);
    }
    final decoded = jsonDecode(json);
    print(decoded);
    setState(() {
      id = decoded['id'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection:
            globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          body: SafeArea(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(yellow),
                      ),
                    )
                  : Container(
                      child: Column(children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top + 10,
                        ),
                        Header(),
                        Divider(),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: WebView(
                            initialUrl: '',
                            javascriptMode: JavascriptMode.unrestricted,
                            onWebViewCreated: (webViewController) async {
                              _webViewController = webViewController;
                              String kNavigationPage =
                                  '''
                                <!DOCTYPE html>
                                <html>
                                <div>
                                <script src="https://oppwa.com/v1/paymentWidgets.js?checkoutId=$id"></script>
                                <form action="https://sites.google.com/view/craftsapp/home" class="paymentWidgets" data-brands="STC_PAY"></form>
                                </div>
                                </html>
                                ''';
                              final String contentBase64 = base64Encode(
                                  const Utf8Encoder().convert(kNavigationPage));
                              await _webViewController.loadUrl(
                                  'data:text/html;base64,$contentBase64');
                            },
                            navigationDelegate:
                                (NavigationRequest request) async {
                              print(request.url);
                              print(request.toString());
                              if (request.url.startsWith(
                                  'https://sites.google.com/view/craftsapp/home')) {
                                var headers = {
                                  'Authorization':
                                      'Bearer OGFjZGE0Y2E3YmU4NThmNjAxN2JmZDljY2EyMTQzZGN8bW01UHhja25EZQ==',
                                  'Cookie':
                                      'ak_bmsc=9F01A4B7085637DE3B05061F2DFD53CF~000000000000000000000000000000~YAAQF+scuBMenJ16AQAADUm3cQyumPt4zBOsXlGB2LDQqXA/GODYSndAPHKra8NCEwPlRdYF7Jk1Cml1M48Nj6ey3reLFu+TTNryvGY9Rd4Tsgxx5XmK4Qcyxdff0h0gsfPjVKe7Dl3n591yIzzPszOGk5j28lCSOL2Z/GfPX7kdVdyUtKVNkbnVsnu4akENE4+xK5kex8FSVutm7fPxr0K+3sIr4MH0t7Bpha8GjIRzrFxrFR432W6uLcJezBqqzxadeF0o9wVnGHswXu7x9K0aDcCoW7ed6IqPlTt/QFyWPmZRvmPdE4ZD0FIYIyzlZU6ZuajyP3UYwBSIh6WlJJpH8a8VAD2/YIFG4TtWtZsk0D3KYoEGv4ivew==; bm_sv=B989EB900290E3E4C14C4F9936C42CE9~vN4XcwPB42EGfB6BYIsACkvmM1praH4dK9gRjFdl5ELUy2gSs7j89ScdRXeov6jFdS/l+Ks2P4JsDlitr43bI0QwBbHI4N+Cog4XJyvd/K8D+G97jGYaeI4LJOLIDWUJbSn3YlMVeP5ThC+kS8gK/+3MbPaTrm9KxejpCk2KHXQ='
                                };
                                var request = http.Request(
                                    'GET',
                                    Uri.parse(
                                        'https://oppwa.com/v1/checkouts/$id/payment?entityId=8acda4ca7be858f6017bfd9f88f643ed'));

                                request.headers.addAll(headers);

                                http.StreamedResponse response =
                                    await request.send();

                                String json;
                                json = await response.stream.bytesToString();

                                print(json);
                                final decoded = jsonDecode(json);

         
                                setState(() {
                                  isLoading = true;
                                });
                                String soap =
                                    '''<?xml version="1.0" encoding="utf-8"?>
                                <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
                                      <soap:Body>

                                       <PayLevel2 xmlns="http://Craft.WS/">
                        <OrderID>${widget.orderID}</OrderID>
                        <PaymentType>3</PaymentType>
                        <CreditNumber></CreditNumber>
                        <ExpDate></ExpDate>
                        <CreditHolder></CreditHolder>
                        <CustomerID>${globals.user.id}</CustomerID>
                        <CVV></CVV>
                        <billid>$id</billid>
                        <billdesc>${decoded['result']['description']}</billdesc>
                        <billcode>${decoded['result']['code']}</billcode>

                      </PayLevel2>


                                      </soap:Body>
                                </soap:Envelope>''';
                                http.Response response2 = await http
                                    .post(
                                        'https://craftapp.net/services/CraftWebService.asmx',
                                        headers: {
                                          "SOAPAction":
                                              "http://Craft.WS/PayLevel2",
                                          "Content-Type":
                                              "text/xml;charset=UTF-8",
                                        },
                                        body: utf8.encode(soap),
                                        encoding: Encoding.getByName("UTF-8"))
                                    .then((onValue) {
                                  return onValue;
                                });
                                setState(() {
                                  isLoading = false;
                                });
                                String json2 = parse(response2.body)
                                    .getElementsByTagName('PayLevel2Result')[0]
                                    .text;
                                final decoded2 = jsonDecode(json2);

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

                                if (regExp
                                        .hasMatch(decoded['result']['code']) ||
                                    regExp2
                                        .hasMatch(decoded['result']['code'])) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CheckoutComplete(
                                                orderID: widget.orderID,
                                                total: widget.amount,
                                                isorder: widget.isorder,
                                              )));
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CheckoutError(
                                                orderID: widget.orderID,
                                                error: decoded['result']
                                                    ['description'],
                                              )));
                                }
                              } else {}

                              return NavigationDecision.navigate;
                            },
                          ),
                        ),
                      ]),
                    )),
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
