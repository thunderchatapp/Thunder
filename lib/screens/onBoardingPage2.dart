import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      //color: Colors.green[100],
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
              "Secure Messaging",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Lottie.asset(
              'assets\\encryption-animation.json',
              height: 200,
            ),
            const SizedBox(height: 10),
            const Text(
              "Thunder uses the Elliptic Curve Diffie-Hellman (ECDH) key exchange protocol combined with an AES-256 GCM encryption scheme to provide end-to-end data encryption.",
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
