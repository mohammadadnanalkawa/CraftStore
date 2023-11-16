import 'package:auto_size_text/auto_size_text.dart';
import 'package:crafts/core/color.dart';
import 'package:crafts/screens/product_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:crafts/core/globals.dart' as globals;

class ItemListTwo extends StatefulWidget {
  @override
  _ItemListTwoState createState() => _ItemListTwoState();
}

class _ItemListTwoState extends State<ItemListTwo> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + 30,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(),
                        child: Icon(
                          Icons.arrow_back,
                          size: 26,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Bags',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.search,
                      size: 26,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Icon(CupertinoIcons.heart, size: 26)
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.slider_horizontal_3),
                          SizedBox(width: 10),
                          Text(globals.loc == 'en' ? 'FILTER' : 'فلترة')
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.sort_down),
                          SizedBox(width: 10),
                          Text(globals.loc == 'en' ? 'SORT' : 'ترتيب')
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  globals.loc == 'en'
                      ? 'Showing 421 results'
                      : 'تظهر 421 نتيجة',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: sliverGridWidget(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget sliverGridWidget(BuildContext context) {
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(8.0),
      crossAxisCount: 2,
      itemCount: 8, //staticData.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => ProductDetails()));
          },
          child: Container(
            decoration: BoxDecoration(),
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/landing.png',
                          fit: BoxFit.fill,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 7.5, top: 7.5),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Icon(CupertinoIcons.heart),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 7.5,
                ),
                AutoSizeText(
                  'GUCCI',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                SizedBox(
                  height: 7.5,
                ),
                AutoSizeText(
                  'Mini Arabian Glow Marble Candle, 50g',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                AutoSizeText(
                  'by Fatimah Essa, Designer',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: yellow, fontSize: 12),
                ),
                SizedBox(
                  height: 7.5,
                ),
                AutoSizeText(
                  '1759 SAR',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            ),
          ),
        );
      },
      staggeredTileBuilder: (index) => StaggeredTile.count(1, 1.8),
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
    );
  }
}
