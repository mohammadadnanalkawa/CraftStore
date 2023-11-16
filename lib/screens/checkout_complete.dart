import 'package:crafts/core/color.dart';
import 'package:crafts/screens/orders.dart';
import 'package:crafts/widgets/app_bar_one.dart';
import 'package:crafts/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'home.dart';
import 'package:intl/intl.dart' as INTL;
import 'package:flutter/cupertino.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/search.dart';
import 'package:crafts/screens/notifications.dart';

class CheckoutComplete extends StatefulWidget {
  final String orderID;
  final String total;
  final String isorder;

  CheckoutComplete(
      {@required this.orderID, @required this.total, @required this.isorder});
  @override
  _CheckoutCompleteState createState() => _CheckoutCompleteState();
}

class _CheckoutCompleteState extends State<CheckoutComplete> {
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WillPopScope(
                      onWillPop: () async => false,
                      child: Home(
                        index: 0,
                      ),
                    )));
        return true;
      },
      child: Directionality(
        textDirection:
            globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + 10,
            ),
            Header(),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBarOne(
                        implyLeading: false,
                        text: globals.loc == 'en' ? 'Checkout' : 'الدفع',
                        press: () {
                          Navigator.pop(context);
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
                                  color: yellow,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.credit_card,
                              color: yellow,
                              size: 28,
                            ),
                            Text(
                              '•' * 12,
                              style: TextStyle(
                                  color: yellow,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: yellow,
                              size: 28,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            globals.loc == 'en' ? 'Thank you' : 'شكرا',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      widget.isorder == '0'
                          ? Container()
                          : Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  globals.loc == 'en'
                                      ? 'Your order has been submitted successfully'
                                      : 'تم ارسال طلبك بنجاح',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                      SizedBox(height: 25),
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/check.png',
                          height: 125,
                          width: 125,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(height: 35),
                      widget.isorder == '0'
                          ? Align(
                              alignment: Alignment.center,
                              child: Text(
                                globals.loc == 'en'
                                    ? 'Your Payment Details'
                                    : 'تفاصيل الدفع',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : Align(
                              alignment: Alignment.center,
                              child: Text(
                                globals.loc == 'en'
                                    ? 'Your Order Details'
                                    : 'تفاصيل الطلب',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                      SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                ),
                                child: Column(
                                  children: [
                              widget.isorder== '0'? Container():     Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          globals.loc == 'en'
                                              ? 'Order ID'
                                              : 'رقم الطلب',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(widget.orderID,
                                            style: TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            globals.loc == 'en'
                                                ? 'Date'
                                                : 'التاريخ',
                                            style: TextStyle(fontSize: 16)),
                                        Text(
                                            INTL.DateFormat('dd-MM-yyyy')
                                                .format(DateTime.now()),
                                            style: TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.white,
                                      thickness: 1.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            globals.loc == 'en'
                                                ? 'Grand Total'
                                                : 'المبلغ الاجمالي',
                                            style: TextStyle(fontSize: 18)),
                                        Text(
                                          '${widget.total} SAR',
                                          style: TextStyle(fontSize: 18),
                                          textDirection: TextDirection.ltr,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
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
                                        ? 'My Orders'
                                        : 'طلباتي',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 17),
                                  ),
                                  onPressed: () async {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Orders()));
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
                                        ? 'Home'
                                        : 'الصفحة الرئيسية',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => WillPopScope(
                                                  onWillPop: () async => false,
                                                  child: Home(
                                                    index: 0,
                                                  ),
                                                )));
                                  }),
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
      ),
    );
  }
}
