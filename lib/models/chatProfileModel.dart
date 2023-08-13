import 'package:flutter/cupertino.dart';
import 'package:thunder_chat/models/friendProfile.dart';
import 'package:web3dart/web3dart.dart';

class ChatProfile {
  EthereumAddress walletAddress;
  String userId;
  String name;
  String description;
  String photoURL;
  String referrerCode;
  String referredBy;
  String publicKey;
  String fcmToken;
  DateTime created;

  bool isRequestSending;
  List<FriendProfile> friendList = [];

  ChatProfile(
      {required this.walletAddress,
      required this.userId,
      required this.name,
      required this.description,
      required this.photoURL,
      required this.referrerCode,
      required this.referredBy,
      required this.publicKey,
      required this.fcmToken,
      required this.created,
      this.isRequestSending = false});

  ChatProfile.fromJson(Map<String, dynamic> json)
      : walletAddress = EthereumAddress.fromHex(json['walletAddress']),
        userId = json['userId'],
        name = json['name'],
        description = json['description'],
        photoURL = json['photoURL'],
        referrerCode = json['referrerCode'],
        referredBy = json['referredBy'],
        publicKey = json['publicKey'],
        fcmToken = json['fcmToken'],
        created = DateTime.parse(json['created']),
        isRequestSending = json['isRequestSending'],
        friendList = List<FriendProfile>.from((json['friendList'] ?? [])
            .map((friendJson) => FriendProfile.fromJson(friendJson)));

  Map<String, dynamic> toJson() => {
        "walletAddress": walletAddress.hexEip55,
        "userId": userId,
        "name": name,
        "description": description,
        "photoURL": photoURL,
        "referrerCode": referrerCode,
        "referredBy": referredBy,
        "publicKey": publicKey,
        "fcmToken": fcmToken,
        'created': created.toIso8601String(), // Convert DateTime to string
        "isRequestSending": isRequestSending,
        'friendList': friendList.map((friend) => friend.toJson()).toList(),
      };
}
