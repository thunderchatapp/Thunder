import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder_chat/controllers/message_controller.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:thunder_chat/screens/apps/appPage.dart';
import 'package:thunder_chat/screens/profile/profilePage.dart';
import 'package:thunder_chat/screens/signUpPage.dart';
import 'package:thunder_chat/screens/settings/settingPage.dart';
import 'package:thunder_chat/screens/chats/chatPage.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ChatProfileController chatProfileController;
  late ChatMessageController chatMessageController;
  @override
  int _currentIndex = 0;
  final List<Widget> _screens = [
    ChatPage(),
    AppPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chatProfileController = Provider.of<ChatProfileController>(context);
    chatMessageController = Provider.of<ChatMessageController>(context);
    chatProfileController.startListener();

    // }
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Apps',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image(
                  image: NetworkImage(chatProfileController.myProfile
                      .photoURL), // Replace with your network image URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
