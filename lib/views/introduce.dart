import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/bottom_navbar.dart';
import '../sizes_helpers.dart';
import '../utility/colors.dart';
import 'users/login/slash-screen.dart';

class Introduce extends StatefulWidget {
  const Introduce({Key? key}) : super(key: key);

  @override
  _IntroduceState createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BottomNavbar()),
    );
  }

  Widget _buildImage(String assetName) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: SvgPicture.asset(
        'assets/introduce/$assetName',
        width: 280.0,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = deviceHeight(context);
    final double screenWidth = deviceWidth(context);

    // Responsive text sizes
    final double titleSize = screenWidth < 600 ? 24.0 : 28.0;
    final double bodySize = screenWidth < 600 ? 15.0 : 17.0;
    final double buttonTextSize = screenWidth < 600 ? 14.0 : 16.0;

    final bodyStyle = TextStyle(
      fontSize: bodySize,
      color: TColors.text,
      height: 1.5,
    );

    final titleStyle = TextStyle(
      fontSize: titleSize,
      color: TColors.primary,
      fontWeight: FontWeight.bold,
    );

    var pageDecoration = PageDecoration(
      titleTextStyle: titleStyle,
      bodyTextStyle: bodyStyle,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      pageColor: TColors.background,
      imagePadding: EdgeInsets.only(top: screenHeight * 0.05),
      titlePadding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
      footerPadding: EdgeInsets.only(top: screenHeight * 0.05),
      bodyAlignment: Alignment.center,
      imageAlignment: Alignment.center,
    );

    return Scaffold(
      backgroundColor: TColors.background,
      body: SafeArea(

        child: IntroductionScreen(
          key: introKey,
          pages: [
            PageViewModel(
              title: "Discover Flights",
              body: "Search and compare prices for flights around the world with ease and convenience.",
              image: _buildImage('Flight-Booking-pana.svg'),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Simple Booking",
              body: "Book a flight through simple steps and pay securely, all within minutes.",
              image: _buildImage('Flight-Booking-bro.svg'),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Price Alerts",
              body: "Save your search and get notifications when prices change for your favorite destinations.",
              footer: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  width: double.infinity/1.5,
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle notification permission
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: buttonTextSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              image: _buildImage('Subscriber-bro.svg'),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: true,
          skipOrBackFlex: 0,
          nextFlex: 0,
          showBackButton: false,
          back: const Icon(Icons.arrow_back, color: TColors.primary),
          skip: Text(
            'Skip',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: TColors.grey,
              fontSize: buttonTextSize,
            ),
          ),
          next: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: TColors.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: const Icon(Icons.arrow_forward, color: TColors.white),
          ),
          done: Text(
            'Get Started',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: TColors.primary,
              fontSize: buttonTextSize,
            ),
          ),
          curve: Curves.fastLinearToSlowEaseIn,
          controlsMargin: const EdgeInsets.all(16),
          controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          dotsDecorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            color: TColors.grey.withOpacity(0.5),
            activeColor: TColors.primary,
            activeSize: const Size(22.0, 10.0),
            activeShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          ),
          dotsContainerDecorator: const ShapeDecoration(
            color: TColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
      ),
    );
  }
}