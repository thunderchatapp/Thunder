import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      //color: Colors.yellow[100],
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
              "Blockchain Technology",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Lottie.asset(
              'assets\\blockchain-animation.json',
              height: 200,
            ),
            const SizedBox(height: 10),
            const Text(
              "Thunder stores user data on the blockchain, ensuring that it is immutable and cannot be tampered with. This means that user data is not stored on centralized servers, which are vulnerable to attacks and data breaches.",
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
