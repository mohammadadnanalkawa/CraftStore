import 'package:crafts/core/color.dart';
import 'package:crafts/core/globals.dart';
import 'package:flutter/material.dart';
import 'package:crafts/screens/account.dart';
import 'package:crafts/screens/notifications.dart';
import 'package:crafts/screens/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/style.dart';

typedef void VoidCallback();

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header>   {



  @override
  Widget build(BuildContext context) {
    return
     Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Account()));
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
        loc == 'en'?  RichText(
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(
                  fontSize: 22,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
              children: <TextSpan>[
                new TextSpan(text: 'CRAFTAPP', style: new TextStyle(letterSpacing: 2.0,)),
                new TextSpan(text: '.', style: new TextStyle(color: yellow,  fontSize: 28,)),

              ],
            ),
          ):
            RichText(
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(
                  fontSize: 22,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
              children: <TextSpan>[
                new TextSpan(text: '.', style: new TextStyle(color: yellow,  fontSize: 28,)),
                new TextSpan(text: 'CRAFTAPP', style: new TextStyle(letterSpacing: 2.0,)),

              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Search(subID: '0')));
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Notifications()));
            },
            child: Container(
                decoration: BoxDecoration(),
                child: Icon(CupertinoIcons.bell, size: 26)),
          )
        ],
      ),
    );
  }
}
