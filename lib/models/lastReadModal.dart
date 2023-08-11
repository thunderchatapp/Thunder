import 'package:flutter/cupertino.dart';
import 'package:web3dart/web3dart.dart';

class LastReadModal {
  EthereumAddress walletAddress;
  DateTime lastMessageRead;

  LastReadModal({required this.walletAddress, required this.lastMessageRead});

  LastReadModal.fromJson(Map<String, dynamic> json)
      : walletAddress = EthereumAddress.fromHex(json['walletAddress']),
        lastMessageRead = DateTime.parse(json['lastMessageRead']);

  Map<String, dynamic> toJson() => {
        "walletAddress": walletAddress.hexEip55,
        "lastMessageRead": lastMessageRead.toIso8601String(),
      };
}

List<LastReadModal> lastReadList = [];
