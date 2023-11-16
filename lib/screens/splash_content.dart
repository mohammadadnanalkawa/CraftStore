import 'package:crafts/core/globals.dart';
import 'package:flutter/material.dart';
import 'package:crafts/helpers/size_config.dart';
import 'package:crafts/core/color.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({
    Key key,
    this.text,
    this.image,
    this.fit,
    this.color,
    this.textar,
    this.title,
    this.titlear,
    this.sort,
  }) : super(key: key);
  final String text, image, fit, color, textar, title, titlear, sort;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ClipPath(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color == "yellow"
                        ? new Color.fromARGB(255, 244, 184, 0)
                        : Color.fromARGB(255, 109, 109, 113),
                    gradient: color == "yellow"
                        ? LinearGradient(
                            colors: [
                                Color.fromARGB(255, 244, 184, 0),
                                Color.fromARGB(255, 244, 184, 0)
                              ],
                            begin: Alignment.centerRight,
                            end: new Alignment(-1.0, -1.0))
                        : LinearGradient(
                            colors: [
                                Color.fromARGB(255, 109, 109, 113),
                                Color.fromARGB(255, 109, 109, 113)
                              ],
                            begin: Alignment.centerRight,
                            end: new Alignment(-1.0, -1.0)),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: sort != "3"
                          ? const EdgeInsets.only(
                              top: 20.0,
                              right: 10,
                              left: 10,
                            )
                          : const EdgeInsets.only(
                              top: 20.0, right: 20, left: 20, bottom: 10),
                      child: Image.asset(
                        image,
                        fit: BoxFit.fill,
                        height: sort == "3"
                            ? MediaQuery.of(context).size.height * 0.35
                            : MediaQuery.of(context).size.height * 0.4,

                      ),
                    )
                  ],
                )
              ],
            ),
            clipper: HeaderColor(),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Text(
            loc == "en" ? title : titlear,
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 32,
               fontFamily: 'MainFont',
              color: Color.fromARGB(255, 128, 128, 131),
            ),
          ),
        ),
        SizedBox(height: 10,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Text(loc == "en" ? text : textar,
              textAlign: TextAlign.center,
              style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 24,
                  color: Color.fromARGB(255, 128, 128, 131),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'MainFont')),
        ),
        SizedBox(height: 15,),
        sort == "2"
            ? Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Image.asset(
                  "assets/payimg.png",
                  fit: BoxFit.fill,
                ),
              )
            : Container()
      ]),
    );
  }
}

class HeaderColor extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height - 100);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
