import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

class ChatMessage {
  final EthereumAddress sender;
  final String content;
  final String type;
  final DateTime created;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.type,
    required this.created,
  });

  ChatMessage.fromJson(Map<String, dynamic> json)
      : sender = json['sender'],
        content = json['content'],
        type = json['type'],
        created = json['created'];

  Map<String, dynamic> toJson() => {
        "sender": sender,
        "content": content,
        "type": type,
        "created": created,
      };
}

List<ChatMessage> chatMessages = [];
