import 'package:flutter/cupertino.dart';
import 'package:thunder_chat/helpers/crypto.dart';
import 'package:web3dart/web3dart.dart';

class ChatMessage {
  EthereumAddress sender;
  EthereumAddress receiver;
  String senderContent;
  String receiverContent;
  DateTime created;
  bool isRequestSending = false;

  ChatMessage({
    required this.sender,
    required this.receiver,
    required this.senderContent,
    required this.receiverContent,
    required this.created,
    this.isRequestSending = false,
  });

  String getDecodedSenderContent(String privateKey) {
    return decrypt(privateKey, senderContent);
  }

  String getDecodedReceiverContent(String privateKey) {
    return decrypt(privateKey, receiverContent);
  }

  ChatMessage.fromJson(Map<String, dynamic> json)
      : sender = EthereumAddress.fromHex(json['sender']),
        receiver = EthereumAddress.fromHex(json['receiver']),
        senderContent = json['senderContent'],
        receiverContent = json['receiverContent'],
        isRequestSending = json['isRequestSending'],
        created = DateTime.parse(json['created']);

  Map<String, dynamic> toJson() => {
        "sender": sender.hexEip55,
        "receiver": receiver.hexEip55,
        "senderContent": senderContent,
        "receiverContent": receiverContent,
        "isRequestSending": isRequestSending,
        "created": created.toIso8601String(),
      };
}

List<ChatMessage> chatMessages = [];
