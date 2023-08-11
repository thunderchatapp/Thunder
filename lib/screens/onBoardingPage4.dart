import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      //color: Colors.grey[100],
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
              "Account Abstraction",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Lottie.asset(
              'assets\\aa-animation.json',
              height: 150,
            ),
            const SizedBox(height: 40),
            const Text(
              "Users do not need to go through the hassle of understanding and securing seed phrases to interact with the blockchain. The smooth chatting experience makes it such that users do not even know they are interacting via the blockchain.",
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
