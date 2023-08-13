import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

class FriendProfile {
  EthereumAddress walletAddress;
  String userId;
  String name;
  String description;
  String photoURL;
  String publicKey;
  String referrerCode;
  String referredBy;
  String fcmToken;
  DateTime created;
  bool isApproved;
  String lastMessage;
  DateTime lastMessageSent;
  DateTime added;
  bool isRequester;

  FriendProfile(
      {required this.walletAddress,
      required this.userId,
      required this.name,
      required this.description,
      required this.photoURL,
      required this.publicKey,
      required this.referrerCode,
      required this.referredBy,
      required this.fcmToken,
      required this.created,
      required this.isApproved,
      required this.added,
      required this.isRequester,
      required this.lastMessageSent,
      this.lastMessage = ""});

  FriendProfile.fromJson(Map<String, dynamic> json)
      : walletAddress = EthereumAddress.fromHex(json['walletAddress']),
        userId = json['userId'],
        name = json['name'],
        description = json['description'],
        photoURL = json['photoURL'],
        publicKey = json['publicKey'],
        referrerCode = json['referrerCode'],
        referredBy = json['referredBy'],
        fcmToken = json['fcmToken'],
        created = DateTime.parse(json['created']),
        isApproved = json['isApproved'],
        added = DateTime.parse(json['added']),
        isRequester = json['isRequester'],
        lastMessageSent = DateTime.parse(json['lastMessageSent']),
        lastMessage = json['lastMessage'];

  Map<String, dynamic> toJson() => {
        "walletAddress": walletAddress.hexEip55,
        "userId": userId,
        "name": name,
        "description": description,
        "photoURL": photoURL,
        "publicKey": publicKey,
        "referrerCode": referrerCode,
        "referredBy": referredBy,
        "fcmToken": fcmToken,
        "created": created.toIso8601String(),
        "isApproved": isApproved,
        "added": added.toIso8601String(),
        "isRequester": isRequester,
        "lastMessageSent": lastMessageSent.toIso8601String(),
        "lastMessage": lastMessage,
      };
}
