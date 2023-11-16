import 'package:flutter/material.dart';

typedef void VoidCallback();

class AppBarOne extends StatefulWidget {
  final bool implyLeading;
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final VoidCallback press;
  AppBarOne(
      {@required this.backgroundColor,
      @required this.implyLeading,
      @required this.press,
      @required this.text,
      @required this.textColor});
  @override
  _AppBarOneState createState() => _AppBarOneState();
}

class _AppBarOneState extends State<AppBarOne> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
      ),
      padding: EdgeInsets.fromLTRB(
          15, 15, 15, 15),
      child: Row(
        children: [
          widget.implyLeading
              ? GestureDetector(
                  onTap: () {
                    widget.press();
                  },
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Icon(
                      Icons.arrow_back,
                      color: widget.textColor,
                    ),
                  ),
                )
              : Container(height: 0, width: 0),
          Expanded(
            child: Text(
              widget.text,
              style: TextStyle(
                  color: widget.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 25,
          )
        ],
      ),
    );
  }
}
