import 'package:flutter/material.dart';
import 'package:flutter_app/screens/signUpPage.dart';
import 'package:provider/provider.dart';
import 'controllers/chatMessage_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatMessageController(),
      child: MaterialApp(
        title: 'Thunder',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        //home: HomePage(),
        home: SignUpScreen(),
      ),
    );
  }
}
