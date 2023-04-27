import 'package:flutter/material.dart';
import 'package:flutter_app/screens/signUpPage.dart';
import 'package:flutter_app/screens/homePage.dart';
import 'package:flutter_app/screens/splashPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        home: Builder(builder: (context) => CheckLogin()),
      ),
    );
  }
}

class CheckLogin extends StatefulWidget {
  @override
  _CheckLoginState createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  bool loading = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('privateKey');

    if (privateKey != null) {
      setState(() {
        loading = false;
        loggedIn = true;
      });
    } else {
      setState(() {
        loading = false;
        loggedIn = false;
      });
    }
  }

  late ChatMessageController chatMessageController;
  @override
  Widget build(BuildContext context) {
    chatMessageController = Provider.of<ChatMessageController>(context);
    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      if (loggedIn) {
        return SplashPage();
      } else {
        return SignUpScreen();
      }
    }
  }
}
