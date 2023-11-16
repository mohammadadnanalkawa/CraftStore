import 'package:crafts/core/color.dart';
import 'package:crafts/screens/by.dart';
import 'package:crafts/screens/categories.dart';
import 'package:crafts/screens/front_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'bag.dart';
import 'package:crafts/core/globals.dart' as globals;

class Home extends StatefulWidget {
  final int index;
  final String activeId;

  Home({@required this.index, this.activeId});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String id = "0";
  List<Widget> _pages;
  int _currentIndex = 0;
  void onTabTapped(int index) {
    _pages = [
      FrontPage(),
      Categories(
        activeid: id,
      ),
      By(),
      Bag(),
    ];
    setState(() {
      _currentIndex = index;
      id = '0';
    });
  }

  @override
  void initState() {
    super.initState();
    id = widget.activeId != null ? widget.activeId : '0';
    _pages = [
      FrontPage(),
      Categories(
        activeid: id,
      ),
      By(),
      Bag(),
    ];

    if (widget.index != null) {
      _currentIndex = widget.index;
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          key: _scaffoldKey,
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            elevation: 10,
            selectedItemColor: yellow,
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Colors.grey[100],
            showUnselectedLabels: true,
            iconSize: 30,
            onTap: onTabTapped, // new
            currentIndex: _currentIndex, // new
            items: [
              new BottomNavigationBarItem(
                  icon: Image.asset(
                   _currentIndex == 0 ? 'assets/craftfill.png' : 'assets/craft.png',
                    scale: 2,
                  ),
                  label: globals.loc == 'en' ? "HOME" : 'الرئيسية'),
              new BottomNavigationBarItem(
                  icon: Image.asset(
                     _currentIndex == 1 ? 'assets/catfill.png' : 'assets/cat.png',
                     scale: 2,
                  ),
                  label: globals.loc == 'en' ? "CATEGORIES" : 'التصنيفات'),
              new BottomNavigationBarItem(
                  icon: Image.asset(
                     _currentIndex == 2 ? 'assets/byfill.png' : 'assets/byicon.png',
                    scale: 2,
                  ),
                  label: globals.loc == 'en' ? "BY" : 'بواسطة'),
              new BottomNavigationBarItem(
                  icon: Image.asset(
                _currentIndex == 3 ? 'assets/cartfill.png' : 'assets/cart.png',
                   scale: 2,
                  ),
                  label: globals.loc == 'en' ? "BAG" : 'الحقيبة'),
            ],
          )),
    );
  }
}
