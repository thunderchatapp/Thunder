import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:thunder_chat/models/chatProfileModel.dart';
import 'package:thunder_chat/models/friendProfile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RequestList extends StatefulWidget {
  final FriendProfile receiverProfile;

  RequestList({
    required this.receiverProfile,
  });

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  late ChatProfileController chatProfileController;
  bool _isFriendRequestSent = false;

  void _cancelFriendRequest() async {
    if (!_isFriendRequestSent) {
      setState(() {
        _isFriendRequestSent = true;
      });

      try {
        await chatProfileController
            .deleteFriend(widget.receiverProfile.walletAddress);
      } catch (e) {
        debugPrint(e.toString());
        Fluttertoast.showToast(
          msg: "Error. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      setState(() {
        _isFriendRequestSent = false;
      });
    }
  }

  void _approveFriendRequest() async {
    if (!_isFriendRequestSent) {
      setState(() {
        _isFriendRequestSent = true;
      });

      try {
        await chatProfileController
            .approveFriend(widget.receiverProfile.walletAddress);
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      setState(() {
        _isFriendRequestSent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    chatProfileController = Provider.of<ChatProfileController>(context);

    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ChatDetailPage(receiverProfile),
        //   ),
        // );
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverProfile.photoURL),
              maxRadius: 30,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.receiverProfile.name,
                    style: TextStyle(fontSize: 16),
                  ),
                  if (!widget.receiverProfile.isApproved)
                    if (widget.receiverProfile.isRequester)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Waiting for approval",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: _cancelFriendRequest,
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue.shade400,
                                minimumSize: Size(double.infinity, 0),
                                fixedSize: Size.fromHeight(30),
                              ),
                              child: _isFriendRequestSent
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ))
                                  : Text('Cancel'),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Requested: ${DateFormat('dd-MMM-yyyy – kk:mm').format(widget.receiverProfile.added)}",
                            // style: TextStyle(
                            //   fontSize: 13,
                            //   color: Colors.grey.shade400,
                            //   fontWeight: widget.receiverProfile.isMessageRead
                            //       ? FontWeight.bold
                            //       : FontWeight.normal,
                            // ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: _approveFriendRequest,
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green.shade400,
                                    minimumSize: Size(double.infinity, 0),
                                    fixedSize: Size.fromHeight(30),
                                  ),
                                  child: _isFriendRequestSent
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ))
                                      : Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: _cancelFriendRequest,
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red.shade400,
                                    minimumSize: Size(double.infinity, 0),
                                    fixedSize: Size.fromHeight(30),
                                  ),
                                  child: _isFriendRequestSent
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ))
                                      : Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  Text(
                    widget.receiverProfile.lastMessage,
                    // style: TextStyle(
                    //   fontSize: 13,
                    //   color: Colors.grey.shade600,
                    //   fontWeight: widget.receiverProfile.isMessageRead
                    //       ? FontWeight.bold
                    //       : FontWeight.normal,
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
}
