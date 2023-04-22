import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/chatProfileModel.dart';
import 'package:flutter_app/widgets/conversationList.dart';
import 'package:flutter_app/controllers/chatMessage_controller.dart';
import 'package:flutter_app/screens/addFriendByQRScan.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

import 'SignUpPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ChatMessageController chatMessageController;

  VoidCallback _logout() {
    return () async {
      try {
        final prefs = await SharedPreferences.getInstance();

        await prefs.remove('privateKey');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpScreen()),
        );
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    chatMessageController = Provider.of<ChatMessageController>(context);

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Thunder",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50, bottom: 16),
                child: Text(
                  chatMessageController.chatProfile.name,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: Center(
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage(chatMessageController.chatProfile.pic),
                  maxRadius: 80,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50, bottom: 16),
                child: Text(
                  chatMessageController.chatProfile.description,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: QrImage(
                  data:
                      chatMessageController.chatProfile.walletAddress.hexEip55,
                  version: QrVersions.auto,
                  size: 150.0,
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600] // This is what you need!
                      ),
                  onPressed: _logout(),
                  child: Column(
                    children: const [
                      Text('Logout'),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
