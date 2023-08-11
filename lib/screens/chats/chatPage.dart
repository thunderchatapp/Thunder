import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:thunder_chat/models/chatProfileModel.dart';
import 'package:thunder_chat/models/friendProfile.dart';
import 'package:thunder_chat/screens/friends/friendAddPage.dart';
import 'package:thunder_chat/widgets/conversationList.dart';
import 'package:thunder_chat/widgets/requestList.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatProfileController chatProfileController;

  void _openAddFriendScreen() {
    Future(
      () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => FriendAddPage()),
      ),
    );
  }

  void _showNewConversationPopup() async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx + button.size.width,
        buttonPosition.dy + button.size.height - 150,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 0,
          child: Consumer<ChatProfileController>(
            builder: (context, chatProfileController, _) {
              int pendingRequestsCount = chatProfileController
                  .myProfile.friendList
                  .where((friendProfile) => !friendProfile.isApproved)
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
                    child: Text(
                      'Pending Requests',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...chatProfileController.myProfile.friendList
                      .where((friendProfile) => !friendProfile.isApproved)
                      .map((friendProfile) {
                    return RequestList(
                      receiverProfile: friendProfile,
                    );
                  }).toList(),
                  ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.person_add),
                      ],
                    ),
                    title: Text('Add Friend'),
                    onTap: () {
                      _openAddFriendScreen();
                      Navigator.pop(context); // Hide the popup
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    chatProfileController = Provider.of<ChatProfileController>(context);
    int pendingRequestsCount = chatProfileController.myProfile.friendList
        .where((friendProfile) => !friendProfile.isApproved)
        .length;

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 15),
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
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
                  child: Text(
                    'Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: chatProfileController.myProfile.friendList.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 16),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (chatProfileController
                        .myProfile.friendList[index].isApproved) {
                      return ConversationList(
                        receiverProfile:
                            chatProfileController.myProfile.friendList[index],
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: _showNewConversationPopup,
            child: Icon(Icons.add),
            backgroundColor: Colors.orange,
          ),
          if (pendingRequestsCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  pendingRequestsCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
