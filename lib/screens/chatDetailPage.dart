import 'dart:convert';
import 'package:flutter_app/models/chatProfileModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_app/models/chatMessage.dart';
import 'package:flutter_app/controllers/chatMessage_controller.dart';
import 'package:provider/provider.dart';

class ChatDetailPage extends StatefulWidget {
  late ChatProfile friendProfile;
  ChatDetailPage(ChatProfile receiverProfile) {
    friendProfile = receiverProfile;
  }

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState(friendProfile);
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late ChatMessageController chatMessageController;
  late TextEditingController messageCtrl;
  late ChatProfile friendProfile;

  _ChatDetailPageState(ChatProfile receiverProfile) {
    friendProfile = receiverProfile;
  }

  @override
  void initState() {
    super.initState();
    messageCtrl = TextEditingController(text: "");
  }

  handleSendMessage() async {
    var message = messageCtrl.text;
    messageCtrl.text = "";
    await chatMessageController.sendMessage(message, friendProfile);
  }

  @override
  Widget build(BuildContext context) {
    chatMessageController = Provider.of<ChatMessageController>(context);
    chatMessageController.getMessages(friendProfile);
    chatMessageController.chatMessages
        .sort((a, b) => a.created.compareTo(b.created));
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
                  backgroundImage: NetworkImage(friendProfile.pic),
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
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
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
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.only(bottom: 50),
              child: Column(children: <Widget>[
                ListView.builder(
                  itemCount: chatMessageController.chatMessages.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment:
                            (chatMessageController.chatMessages[index].type ==
                                    "received"
                                ? Alignment.topLeft
                                : Alignment.topRight),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: (chatMessageController
                                        .chatMessages[index].type ==
                                    "received"
                                ? Colors.grey.shade200
                                : Colors.blue[200]),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            chatMessageController.chatMessages[index].content,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    );
                  },
                )
              ])),
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
                    onPressed: () {
                      handleSendMessage();
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
