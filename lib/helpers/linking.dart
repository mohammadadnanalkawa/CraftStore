import 'package:crafts/screens/product_details.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class DynamicLinkService {
  Future<Uri> createDynamicLink(String id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://craftapp.page.link',
      link: Uri.parse('https://craftapp.page.link.com/products/?id=$id'),
      androidParameters: AndroidParameters(
        packageName: 'com.codino.crafts',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.codino.crafts',
        minimumVersion: '1',
        appStoreId: '1585417957',
      ),
    );
    var dynamicUrl = await parameters.buildShortLink();
    final Uri shortUrl = dynamicUrl.shortUrl;
    return shortUrl;
  }

  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      if (data != null) {
        final Uri deepLink = data.link;

        if (deepLink != null) {
          if (deepLink.queryParameters.containsKey('id')) {
            String id = deepLink.queryParameters['id'];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductDetails(
                          favChange: (_) {},
                          favflag: '0',
                          productID: id,
                        )));
          }
        }
      }
      FirebaseDynamicLinks.instance.onLink(
          onSuccess: (PendingDynamicLinkData dynamicLink) async {
        final Uri deepLinkk = dynamicLink.link;

        if (deepLinkk != null) {
          if (deepLinkk.queryParameters.containsKey('id')) {
            String id = deepLinkk.queryParameters['id'];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductDetails(
                          favChange: (_) {},
                          favflag: '0',
                          productID: id,
                        )));
          }
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
