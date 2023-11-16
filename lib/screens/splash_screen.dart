import 'package:crafts/core/color.dart';
import 'package:crafts/core/globals.dart';
import 'package:crafts/screens/default_button.dart';
import 'package:crafts/screens/landing_page.dart';
import 'package:crafts/screens/splash_content.dart';
import 'package:crafts/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:crafts/helpers/size_config.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;

  final kAnimationDuration = Duration(milliseconds: 200);

  List<Banner> subby = <Banner>[];

  void loadData() async {
    setState(() {});
    await getAllBanner();

    setState(() {});
  }

  Future<void> getAllBanner() async {
    subby = [];
    subby.add(Banner(
        image: "assets/intro1.png",
        text:
            "With our highest quality standard and seamless experience, Craftapp is the platform that provides your needs, while enjoying products’ diversity, You can shop easaily with a variety of options and categories.",
        color: "yellow",
        fit: "BoxFit.fitHeight",
        textAR:
            "مع أعلى معايير الجودة لدينا، كرافتاب هي المنصة التي توفر احتياجاتك، بينما تستمتع بالتسوق بسهولة مع مجموعة متنوعة من الخيارات والفئات",
        title: "Choose The Products",
        titlear: "اختر منتجات",
        sort: "1"));

    subby.add(Banner(
        image: "assets/intro2.png",
        text: "Safe payment methods",
        color: "Colors.grey",
        fit: "BoxFit.contain",
        textAR: "بطرق متعددة بسهولة ، أمان",
        title: "Pay",
        titlear: "الدفع",
        sort: "2"));

    subby.add(Banner(
        image: "assets/intro3.png",
        text:
            "With Several modern products by fancy  Saudi boutiques , Special selections and out special service where you can customize the product you like and add your  own touches.",
        color: "yellow",
        fit: "BoxFit.fitHeight",
        textAR:
            "بمنتجات حصرية للبوتيكات والمصممين السعوديين، ومختارات مميزه بالإضافة الى امكانية التعديل على المنتجات حسب رغبتك واضافة لمساتك الخاصة.",
        title: "Enjoy!",
        titlear: "استمتع!",
        sort: "3"));
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.85,
                width: MediaQuery.of(context).size.width,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: subby.length,
                  itemBuilder: (context, index) => SplashContent(
                    image: subby[index].image,
                    text: subby[index].text,
                    color: subby[index].color,
                    fit: subby[index].fit,
                    textar: subby[index].textAR,
                    title: subby[index].title,
                    titlear: subby[index].titlear,
                    sort: subby[index].sort,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20)),
                  child: Column(
                    children: <Widget>[
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          subby.length,
                          (index) => buildDot(index: index),
                        ),
                      ),
                      Spacer(flex: 3),
                      DefaultButton(
                        text: loc == "en" ? "Skip" : "تخطي",
                        press: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LandingPage()));
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? yellow : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class Banner {
  final String image;
  final String text;
  final String color;
  final String fit;
  final String textAR;
  final String title;
  final String titlear;
  final String sort;

  Banner(
      {@required this.image,
      @required this.text,
      @required this.color,
      @required this.fit,
      @required this.textAR,
      @required this.title,
      @required this.titlear,
      @required this.sort});
}
