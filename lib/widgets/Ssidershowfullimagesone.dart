import 'package:crafts/core/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafts/core/globals.dart' as globals;
import 'package:flutter_html/image_render.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:crafts/helpers/banner.dart' as bannercc;

class SliderShowFullimages2 extends StatefulWidget {
  final String url;
  final int current;
  final List<bannercc.Banner> galleryItems;

  const SliderShowFullimages2(
      {Key key, this.url, this.current, this.galleryItems})
      : super(key: key);
  @override
  _SliderShowFullimages2State createState() => _SliderShowFullimages2State();
}


class _SliderShowFullimages2State extends State<SliderShowFullimages2> {
  int _current = 0;
  bool _stateChange = false;
  @override
  void initState() {
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    _current = (_stateChange == false) ? widget.current : _current;
    return Directionality(
      textDirection:
          globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: new Container(
        color: Colors.transparent,
        child: new Scaffold(
            backgroundColor: Colors.transparent,
            body:  SingleChildScrollView(
              child: Padding(
                     padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
                child: Column(children: [
                  SizedBox(height: 30,),
                  Align(
                    alignment: globals.loc == 'en'
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(),
                          child: Text(globals.loc == 'en' ? 'Close' : 'اغلاق',
                              style: TextStyle(
                                  fontSize: 22,
                                  decoration: TextDecoration.underline,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    width: MediaQuery.of(context).size.width,
                      child:
                       PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(widget.galleryItems[index].image),
                        initialScale: PhotoViewComputedScale.contained * 0.8,
                        heroAttributes: PhotoViewHeroAttributes(
                            tag: widget.galleryItems[index].atIndex),
                      );
                    },
                    itemCount: widget.galleryItems.length,
                    loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.orange,
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                  ),
              
                ),
                        ),
              
                    /*     backgroundDecoration: widget.backgroundDecoration,
                    pageController: widget.pageController,
                    onPageChanged: onPageChanged, */
                     onPageChanged: (int index) {
                        setState(() {
                          _stateChange = true;
                          _current = index;
                        });
                      },
                  )),
                        SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.center,
                                  child: Directionality(
                                    textDirection:
                        globals.loc == 'en' ? TextDirection.ltr : TextDirection.rtl,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: widget.galleryItems.map((e) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2.5),
                                            height: _current == e.atIndex ? 6 : 12,
                                            width: _current == e.atIndex ? 15 : 12,
                                            decoration: BoxDecoration(
                                                color: _current == e.atIndex
                                                    ? yellow
                                                    : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                        
                
                ]),
              ),
            )),
      ),
    );
  }
}
