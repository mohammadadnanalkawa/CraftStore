import 'package:crafts/screens/contact_us.dart';
import 'package:flutter/material.dart';

typedef void VoidCallback();

class AppBarOrder extends StatefulWidget {
  final bool implyLeading;
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final VoidCallback press;
  AppBarOrder(
      {@required this.backgroundColor,
      @required this.implyLeading,
      @required this.press,
      @required this.text,
      @required this.textColor});
  @override
  _AppBarOrderState createState() => _AppBarOrderState();
}

class _AppBarOrderState extends State<AppBarOrder> {
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
                  onTap: () {
                     Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                     ContactUs()));
                  },
                  child: Container(
                    decoration: BoxDecoration(),
                    child:Image.asset(
                    'assets/callus.png',
              height: 32,
              width: 32,
                  ),
                  
                  ),
                ),
             
        
        ],
      ),
   
    );
  }
}
