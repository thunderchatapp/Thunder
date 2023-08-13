import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:thunder_chat/helpers/notificationHelper.dart';
import 'package:thunder_chat/models/chatProfileModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:thunder_chat/models/chatMessage.dart';
import 'package:thunder_chat/controllers/message_controller.dart';
import 'package:provider/provider.dart';
import 'package:thunder_chat/models/friendProfile.dart';
import 'package:thunder_chat/models/lastReadModal.dart';
import 'package:share/share.dart';

class ChatDetailPage extends StatefulWidget {
  late FriendProfile friendProfile;

  // Method to update the lastRead datetime to the current time

  ChatDetailPage(FriendProfile receiverProfile) {
    friendProfile = receiverProfile;
  }

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState(friendProfile);
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late ChatMessageController chatMessageController;
  late ChatProfileController chatProfileController;
  late TextEditingController messageCtrl;
  late FriendProfile friendProfile;
  bool isSendButtonEnabled = false;
  final _longPressGestureRecognizer = LongPressGestureRecognizer();
  // Store the position of the tapped message bubble
  Offset? _tappedPosition;
  OverlayEntry? _overlayEntry;
  String strSelectedTextMessage = "";
  @override
  void dispose() {
    // Call the method to update the lastRead datetime when the ChatDetailPage is disposed or exited

    _longPressGestureRecognizer.dispose();
    _hideMessageOptions();
    updateLastRead();
    super.dispose();
  }

  Future<void> updateLastRead() async {
    LastReadModal lastReadModal = LastReadModal(
      walletAddress: friendProfile.walletAddress,
      lastMessageRead: DateTime.now(),
    );
    await chatProfileController.updateLastRead(lastReadModal);

    debugPrint(chatProfileController.lastReadList.toString());
  }

  _ChatDetailPageState(FriendProfile receiverProfile) {
    friendProfile = receiverProfile;
  }

  @override
  void initState() {
    super.initState();
    messageCtrl = TextEditingController(text: "");
    messageCtrl.addListener(_updateSendButtonState);
    _longPressGestureRecognizer.onLongPress = _handleLongPress;
  }

  void _updateSendButtonState() {
    setState(() {
      isSendButtonEnabled = messageCtrl.text.trim().isNotEmpty;
    });
  }

  handleSendMessage() async {
    var message = messageCtrl.text;
    messageCtrl.text = "";

    await chatMessageController.sendMessage(
        message,
        chatProfileController.myProfile.walletAddress,
        friendProfile.walletAddress,
        chatProfileController.myProfile.publicKey,
        friendProfile.publicKey,
        chatProfileController);
    NotificationHelper notificationHelper = NotificationHelper();
    notificationHelper.sendNotification(friendProfile.fcmToken, "New message",
        "${chatProfileController.myProfile.name} has sent you an encrypted message.");
  }

  @override
  Widget build(BuildContext context) {
    chatProfileController = Provider.of<ChatProfileController>(context);
    chatMessageController = Provider.of<ChatMessageController>(context);
    //chatMessageController.getAllChatMessages(friendProfile.);
    List<ChatMessage> friendMessages =
        chatMessageController.getFriendMessages(friendProfile.walletAddress);

    // Group messages by date
    Map<String, List<ChatMessage>> groupedMessages = {};
    for (var message in friendMessages) {
      String dateKey =
          DateFormat('dd/MM/yy').format(message.created); // Format the date
      if (groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey]!.add(message);
      } else {
        groupedMessages[dateKey] = [message];
      }
    }

    // Sort messages by date (oldest on top)
    List<String> sortedDates = groupedMessages.keys.toList();
    sortedDates.sort((b, a) => DateFormat('dd/MM/yy')
        .parse(a)
        .compareTo(DateFormat('dd/MM/yy').parse(b)));

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
                  SizedBox(
                    width: 2,
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(friendProfile.photoURL),
                    maxRadius: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          friendProfile.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        // SizedBox(
                        //   height: 6,
                        // ),
                        // Text(
                        //   "Online",
                        //   style: TextStyle(
                        //       color: Colors.grey.shade600, fontSize: 13),
                        // ),
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
        body: GestureDetector(
          onTap: () {
            // Hide the menu when tapped outside
            _hideMessageOptions();
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  reverse: true, // To display latest messages at the bottom
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    String dateKey = sortedDates[
                        index]; // Use sortedDates instead of groupedMessages.keys.elementAt(index)
                    List<ChatMessage> messages = groupedMessages[dateKey]!;

                    return Column(
                      children: [
                        // Group header showing the date
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.grey.shade200,
                          child: Text(
                            dateKey,
                            style: TextStyle(
                              fontSize: 14, // Customize the font size
                              fontWeight: FontWeight.bold,
                              color: Colors.grey, // Use grey text color
                            ),
                          ),
                        ),
                        // Messages for the current date group
                        ListView.builder(
                          itemCount: messages.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          // Inside the ListView.builder where you display messages
                          // Inside the ListView.builder where you display messages
                          itemBuilder: (context, index) {
                            final chatMessage = messages[index];
                            final isReceiver = chatMessage.receiver ==
                                chatProfileController.myProfile.walletAddress;

                            return GestureDetector(
                                onLongPressStart: (details) {
                                  setState(() {
                                    _tappedPosition = details.globalPosition;
                                    strSelectedTextMessage = isReceiver
                                        ? chatMessage.receiverContent
                                        : chatMessage.senderContent;
                                  });
                                  _handleLongPress();
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    left: 14,
                                    right: 14,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: Align(
                                    alignment: isReceiver
                                        ? Alignment.topLeft
                                        : Alignment.topRight,
                                    child: Stack(
                                      children: [
                                        // Message bubble with sent time inside
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: isReceiver
                                                ? Colors.grey.shade200
                                                : Colors.blue[200],
                                          ),
                                          padding: EdgeInsets.fromLTRB(
                                              16, 15, 45, 15),
                                          child: Stack(
                                            children: [
                                              Text(
                                                isReceiver
                                                    ? chatMessage
                                                        .receiverContent
                                                    : chatMessage.senderContent,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (chatMessage
                                            .isRequestSending) // Show timer icon if isRequestSending is true
                                          Positioned(
                                            top:
                                                4, // Adjust the vertical position
                                            right:
                                                4, // Adjust the horizontal position
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              // decoration: BoxDecoration(
                                              //   color: Colors
                                              //       .orangeAccent, // Customize the color of the icon background
                                              //   shape: BoxShape.circle,
                                              // ),
                                              child: Icon(
                                                Icons.local_activity,
                                                size: 16,
                                                color: Colors
                                                    .black26, // Customize the color of the icon
                                              ),
                                            ),
                                          ),

                                        // Message sent time at the bottom right
                                        Positioned(
                                          bottom:
                                              4, // Adjust the vertical position
                                          right:
                                              4, // Adjust the horizontal position
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 6), // Add padding
                                            child: Text(
                                              DateFormat('HH:mm')
                                                  .format(chatMessage.created),
                                              style: TextStyle(
                                                fontSize:
                                                    12, // Use a smaller font size
                                                color: Colors.grey
                                                    .shade800, // Use white text color
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 8), // Separator between groups
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageCtrl,
                          decoration: InputDecoration(
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      FloatingActionButton(
                        onPressed:
                            isSendButtonEnabled ? handleSendMessage : null,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        backgroundColor: isSendButtonEnabled
                            ? Colors.blue
                            : Colors
                                .grey, // Change the button color based on its enabled state
                        elevation: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _handleLongPress() {
    // Show the message options menu
    if (_tappedPosition != null) {
      _showMessageOptions(context, _tappedPosition!);
    }
  }

  void _showMessageOptions(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final menu = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Option 1: Copy message
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(
                text:
                    strSelectedTextMessage)); // Copy the message to the clipboard
            _hideMessageOptions(); // Close the menu
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.content_copy), // Copy icon
                SizedBox(width: 8),
                Text('Copy'), // Text for the option
              ],
            ),
          ),
        ),
        // Option 2: Share message
        GestureDetector(
          onTap: () {
            _shareMessage(strSelectedTextMessage); // Share the message
            _hideMessageOptions(); // Close the menu
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.share), // Share icon
                SizedBox(width: 8),
                Text('Share'), // Text for the option
              ],
            ),
          ),
        ),
        // Add more options as needed
      ],
    );

    // Calculate the correct position for the menu
    final overlayEntry = OverlayEntry(
      builder: (context) {
        final overlayBox = overlay.localToGlobal(Offset.zero);
        final tappedOffset = overlayBox.translate(position.dx, position.dy);

        // Get the width of the menu
        final menuWidth = MediaQuery.of(context).size.width * 0.35;

        // Calculate the left position to prevent overflow
        double left = tappedOffset.dx - (menuWidth + 20);
        if (left < 0) {
          left = 0; // Set a minimum value to prevent going off the left edge
        }

        return Positioned(
          left: left,
          top: tappedOffset.dy - 10, // Adjust the vertical position as needed
          child: Material(
            color: Color.fromARGB(
                255, 253, 241, 225), // Light background color for the
            borderRadius: BorderRadius.circular(12),
            elevation: 4, // Add a slight elevation to the menu
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: menu,
            ),
          ),
        );
      },
    );

    _hideMessageOptions(); // Hide any previously shown menu
    _overlayEntry = overlayEntry;
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _hideMessageOptions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _shareMessage(String message) {
    Share.share(message);
  }
}
