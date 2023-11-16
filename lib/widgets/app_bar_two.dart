import 'package:crafts/core/color.dart';
import 'package:flutter/material.dart';

typedef void VoidCallback();

class AppBarTwo extends StatefulWidget {
  final String text;
  final VoidCallback press;
  AppBarTwo({@required this.text, @required this.press});
  @override
  _AppBarTwoState createState() => _AppBarTwoState();
}

class _AppBarTwoState extends State<AppBarTwo> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 15, 20, 40),
            decoration: BoxDecoration(
              color: yellow,
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                      MediaQuery.of(context).size.width, 100.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 GestureDetector(
                  onTap: () {
                    widget.press();
                  },
                  child: Container(
                      decoration: BoxDecoration(),
                      child: Icon(Icons.arrow_back)),
                ),
                SizedBox(width: 20), 
                Text(
                  widget.text,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 15,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
