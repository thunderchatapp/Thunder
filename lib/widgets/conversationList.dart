import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thunder_chat/controllers/message_controller.dart';
import 'package:thunder_chat/models/chatProfileModel.dart';
import 'package:thunder_chat/models/friendProfile.dart';
import 'package:thunder_chat/screens/chats/chatDetailPage.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:intl/intl.dart';

class ConversationList extends StatefulWidget {
  FriendProfile receiverProfile;
  ConversationList({required this.receiverProfile});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  late ChatMessageController chatMessageController;
  late ChatProfileController chatProfileController;

  // Maximum length of the displayed last message
  static const int maxLastMessageLength = 60;

  @override
  Widget build(BuildContext context) {
    chatMessageController = Provider.of<ChatMessageController>(context);
    chatProfileController = Provider.of<ChatProfileController>(context);
    // Format lastMessageSent based on conditions
    String formattedLastMessageSent =
        formatLastMessageSent(widget.receiverProfile.lastMessageSent);

    int unreadMessages = chatMessageController.countUnreadMessages(
        widget.receiverProfile,
        chatProfileController
            .getDateFromLastReadList(widget.receiverProfile.walletAddress));
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatDetailPage(widget.receiverProfile);
        }));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverProfile.photoURL),
              maxRadius: 30,
            ),
            SizedBox(width: 16),
            Flexible(
              // Use Flexible instead of Expanded
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    // Create a new row for name and formattedLastMessageSent
                    children: [
                      Text(
                        widget.receiverProfile.name,
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      if (unreadMessages > 0) // Display unread messages count
                        Container(
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            unreadMessages.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 7,
                      ), // Add Spacer to push the Text widget to the right end
                      Text(
                        formattedLastMessageSent,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  if (widget.receiverProfile.lastMessage.isNotEmpty)
                    Text(
                      widget.receiverProfile.lastMessage,
                      overflow: TextOverflow.ellipsis, // Truncate with "..."
                      // style: TextStyle(
                      //   fontSize: 13,
                      //   color: Colors.grey.shade600,
                      //   fontWeight: widget.receiverProfile.isMessageRead
                      //       ? FontWeight.normal
                      //       : FontWeight.bold,
                      // ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format date based on conditions
  String formatLastMessageSent(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // Today: Display only time (HH:mm)
      return DateFormat('HH:mm').format(dateTime);
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      // Yesterday: Display 'Yesterday'
      return 'Yesterday';
    } else {
      // Before yesterday: Display date (dd/MMM/yy)
      return DateFormat('dd/MMM/yy').format(dateTime);
    }
  }
}
