import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/chatMessage_controller.dart';
import 'homePage.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityTween;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _opacityTween = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late ChatMessageController chatMessageController;
  @override
  Widget build(BuildContext context) {
    chatMessageController = Provider.of<ChatMessageController>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Opacity(
          opacity: _opacityTween.value,
          child: Text(
            'Stay Connected. Stay Private.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
