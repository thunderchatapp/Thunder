import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:thunder_chat/screens/profile/profilePage.dart';
import 'package:thunder_chat/screens/settings/referFriend.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:thunder_chat/screens//signUpPage.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ChatProfileController chatProfileController;
  bool _isNotificationsEnabled = true;

  VoidCallback _logout() {
    return () async {
      try {
        final prefs = await SharedPreferences.getInstance();

        await prefs.remove('thunderPrivateKey');

        final directory = await getApplicationDocumentsDirectory();
        final fileProfile = File('${directory.path}/myProfile.json');
        final fileChat = File('${directory.path}/chatMessage.json');

        if (await fileProfile.exists()) {
          await fileProfile.delete();
        }

        if (await fileChat.exists()) {
          await fileChat.delete();
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
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
    chatProfileController = Provider.of<ChatProfileController>(context);
    final List<Map<String, dynamic>> myList = [
      {
        'title': chatProfileController.myProfile.name,
        'subtitle': chatProfileController.myProfile.description,
        'iconUrl': chatProfileController.myProfile.photoURL
      },
      {'title': 'Starred messages', 'icon': Icons.star},
      {'title': 'Notifications', 'icon': Icons.notifications, 'isToggle': true},
      {
        'title': 'Refer friends',
        'icon': Icons.share,
        'page': ReferFriendPage()
      },
    ];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '           Settings',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: myList.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(myList[index]['iconUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      myList[index]['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(myList[index]['subtitle']),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  );
                } else if (index == 1) {
                  return ListTile(
                    leading: Icon(myList[index]['icon']),
                    title: Text(myList[index]['title']),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: "Starred messages - Coming soon!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                      );
                    },
                  );
                } else if (index == 2) {
                  return ListTile(
                    leading: Icon(myList[index]['icon']),
                    title: Text(myList[index]['title']),
                    trailing: Switch(
                      value: _isNotificationsEnabled,
                      onChanged: (newValue) {
                        setState(() {
                          _isNotificationsEnabled = newValue;
                          // Update notification setting with the new value
                        });
                      },
                    ),
                  );
                } else {
                  return ListTile(
                    leading: Icon(myList[index]['icon']),
                    title: Text(myList[index]['title']),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => myList[index]['page']),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Text(
            'App Version: 1.0.0 beta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Container(
            height: 50,
            width: double.infinity,
            margin: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ElevatedButton(
                onPressed: _logout(),
                child: Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
