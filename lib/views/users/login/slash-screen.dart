import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../sizes_helpers.dart';
import '../../../utility/colors.dart';
import 'login.dart';

class Slash_Screen extends StatefulWidget {
  @override
  _Slash_ScreenState createState() => _Slash_ScreenState();
}

class _Slash_ScreenState extends State<Slash_Screen> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final size = MediaQuery.of(context).size;
    final textScaleFactor = size.width / 375; // Base scale on standard device width

    return Material(
      child: Container(
        color: TColors.white,
        width: displaySize(context).width,
        height: displaySize(context).height,
        child: Column(
          children: <Widget>[
            // Top image container
            Container(
              width: displaySize(context).width,
              height: displaySize(context).height * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/lywing-slash-screen.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Skip button
                  SafeArea(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 16,
                        right: 16,
                      ),
                      width: displaySize(context).width,
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            color: TColors.white,
                            fontSize: 18 * textScaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Title container
                  Container(
                    width: displaySize(context).width * 0.8,
                    margin: EdgeInsets.only(
                      top: displaySize(context).height * 0.26,
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: AutoSizeText(
                            'title1',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: TColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            presetFontSizes: [28, 24, 20, 18],
                            maxLines: 1,
                          ),
                        ),
                        Center(
                          child: AutoSizeText(
                            'title2',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: TColors.white,
                            ),
                            presetFontSizes: [18, 16, 14, 12],
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Container(
              margin: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Email input field
                    Material(
                      elevation: 10,
                      shadowColor: TColors.white,
                      borderRadius: BorderRadius.circular(15),
                      child: TextField(
                        style: TextStyle(fontSize: 16 * textScaleFactor),
                        decoration: InputDecoration(
                          labelText: 'enterYourEmail',
                          labelStyle: TextStyle(
                            fontSize: 16 * textScaleFactor,
                            color: TColors.grey,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.white, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: TColors.secondary, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                
                    // Login button
                    Container(
                      margin: EdgeInsets.only(
                        top: 20,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.secondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          minimumSize: Size(
                            double.infinity,
                            50, // Fixed height for button
                          ),
                        ),
                        child: AutoSizeText(
                          'login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18 * textScaleFactor,
                            fontWeight: FontWeight.bold,
                            color: TColors.white,
                          ),
                          minFontSize: 14,
                        ),
                      ),
                    ),
                
                    // Register button
                    Container(
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 0.5,
                              color: TColors.grey,
                            ),
                          ),
                          elevation: 0,
                          minimumSize: Size(
                            double.infinity,
                            50, // Fixed height for button
                          ),
                        ),
                        child: Text(
                          'registerNewAccount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16 * textScaleFactor,
                            fontWeight: FontWeight.bold,
                            color: TColors.black,
                          ),
                        ),
                      ),
                    ),
                
                    // Google signup button
                    Container(
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 0.5,
                              color: TColors.grey,
                            ),
                          ),
                          elevation: 0,
                          minimumSize: Size(
                            double.infinity,
                            50, // Fixed height for button
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              ('assets/images/google.svg'),
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'signUpWithGoogle',
                              style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                color: TColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                
                    // Facebook login button
                    Container(
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              width: 0.5,
                              color: TColors.grey,
                            ),
                          ),
                          elevation: 0,
                          minimumSize: Size(
                            double.infinity,
                            50, // Fixed height for button
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              ('assets/images/facebook.svg'),
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'loginWithFacebook',
                              style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                color: TColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                
                    // Already have account link
                    Container(
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'alreadyHaveAnAccount?',
                            style: TextStyle(
                              fontSize: 16 * textScaleFactor,
                              color: TColors.grey,
                            ),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {},
                            child: AutoSizeText(
                              'login',
                              style: TextStyle(
                                color: TColors.secondary,
                                fontSize: 16 * textScaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                              minFontSize: 14,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}