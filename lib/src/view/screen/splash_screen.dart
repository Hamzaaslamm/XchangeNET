import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget{
  @override
  Widget  build(BuildContext context){


    const colorizeColors = [
      Colors.black,
      Colors.white,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 50.0,
      fontFamily: 'Horizon',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(image: AssetImage(
                'assets/images/icon.png'),
              width: 350,
              height: 250,
              // color: Colors.white,
            ),
            SizedBox(height: 10,),

            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'XchangeNET',
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                ),
              ],
              isRepeatingAnimation: true,
              onTap: () {
                print("Tap Event");
              },
            ),

          ],
        ),
      ),
      // Center(child: Text("Loading"),),
    );
  }
}