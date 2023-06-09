import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

class ChatProfile {
  final EthereumAddress walletAddress;
  final EthereumAddress chatAddress;
  final String name;
  final String description;
  final String pic;
  final String publicKey;
  final DateTime created;
  final bool isMessageRead;
  late String lastMessage;

  String get getLastMessage => lastMessage;

  set setLastMessage(String value) {
    lastMessage = value;
  }

  ChatProfile(
      {required this.walletAddress,
      required this.chatAddress,
      required this.name,
      required this.description,
      required this.pic,
      required this.publicKey,
      required this.created,
      this.isMessageRead = true,
      this.lastMessage = ""});

  ChatProfile.fromJson(Map<String, dynamic> json)
      : walletAddress = json['walletAddress'],
        chatAddress = json['chatAddress'],
        name = json['name'],
        description = json['description'],
        pic = json['pic'],
        publicKey = json['publicKey'],
        created = json['created'],
        isMessageRead = json['isMessageRead'],
        lastMessage = json['lastMessage'];

  Map<String, dynamic> toJson() => {
        "walletAddress": walletAddress,
        "chatAddress": chatAddress,
        "name": name,
        "description": description,
        "pic": pic,
        "publicKey": publicKey,
        "created": created,
        "isMessageRead": isMessageRead,
        "lastMessage": lastMessage,
      };
}
