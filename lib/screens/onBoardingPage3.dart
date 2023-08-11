import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      //color: Colors.blue[100],
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Image.asset(
              'assets\\thunder_logo.png',
              height: 100,
            ),
            const SizedBox(height: 50),
            const Text(
              "User Privacy",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Lottie.asset(
              'assets\\privacy-animation.json',
              height: 150,
            ),
            const SizedBox(height: 40),
            const Text(
              "Thunder does not collect any user data and does not share it with third-party companies, ensuring that user privacy is protected. ",
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
