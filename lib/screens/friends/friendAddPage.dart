import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:thunder_chat/helpers/notificationHelper.dart';
import 'package:thunder_chat/helpers/web3Helper.dart';
import 'package:thunder_chat/models/chatProfileModel.dart';
import 'package:web3dart/web3dart.dart';

class FriendAddPage extends StatefulWidget {
  @override
  _FriendAddPageState createState() => _FriendAddPageState();
}

class _FriendAddPageState extends State<FriendAddPage> {
  late ChatProfileController chatProfileController;

  bool _isFriendRequestSent = false;
  bool isSearched = false;

  String searchQuery = '';
  List<ChatProfile> friendList = [];

  filterFriendList(String query) async {
    setState(() {
      _isFriendRequestSent = true;
      isSearched = true;
    });
    debugPrint("query: $query");
    await chatProfileController
        .searchProfile(query)
        .then((List<ChatProfile> filteredFriendList) {
      debugPrint("filteredFriendList: $filteredFriendList");
      setState(() {
        _isFriendRequestSent = false;
        friendList = filteredFriendList;
      });
    });
  }

  void sendFriendRequest(
      EthereumAddress walletAddress, String fcmToken, int index) async {
    setState(() {
      friendList[index].isRequestSending = true;
    });

    try {
      await chatProfileController.addToFriend(walletAddress);

      setState(() {
        friendList[index].isRequestSending = false;
        friendList.removeAt(index);
      });

      Fluttertoast.showToast(
        msg: "Friend request sent",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Send a notification to the specified FCM token
      FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      await firebaseMessaging.requestPermission();
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      NotificationHelper notificationHelper = NotificationHelper();
      notificationHelper.sendNotification(fcmToken, "Friend Request",
          "${chatProfileController.myProfile.name} wants to add you as friend");
    } catch (e) {
      setState(() {
        friendList[index].isRequestSending = false;
      });

      // Handle the error case here.
      Fluttertoast.showToast(
        msg: "Failed to send friend request",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    chatProfileController = Provider.of<ChatProfileController>(context);

    final loadingIndicator = Padding(
      padding: EdgeInsets.only(top: 16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

    final noRecordFoundText = Padding(
      padding: EdgeInsets.only(top: 16),
      child: Center(
        child: Text('No record found.'),
      ),
    );

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
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Add Friend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.account_circle_sharp,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: EdgeInsets.all(8),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: searchQuery.isNotEmpty
                          ? () {
                              filterFriendList(searchQuery);
                            }
                          : null,
                      child: Text('Search'),
                    ),
                  ],
                ),
              ),
              isSearched && friendList.isEmpty && _isFriendRequestSent == false
                  ? noRecordFoundText
                  : ListView.builder(
                      itemCount: friendList.length > 0 ? friendList.length : 1,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 16),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (friendList.length > 0) {
                          return GestureDetector(
                            onTap: () {
                              sendFriendRequest(friendList[index].walletAddress,
                                  friendList[index].fcmToken, index);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(friendList[index].photoURL),
                              ),
                              title: Text(friendList[index].name),
                              subtitle: Text(friendList[index].description),
                              trailing: friendList[index].isRequestSending
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.person_add),
                            ),
                          );
                        } else {
                          // Display a message when no record is found
                          return ListTile(
                            title: Text(''),
                          );
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
