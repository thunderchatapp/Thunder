import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder_chat/appconfig.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:thunder_chat/helpers/crypto.dart';
import 'package:thunder_chat/helpers/web3Helper.dart';
import 'package:thunder_chat/models/chatMessage.dart';
import 'package:thunder_chat/models/friendProfile.dart';
import 'package:thunder_chat/models/lastReadModal.dart';
import 'package:web3dart/web3dart.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChatMessageController extends ChangeNotifier {
  late List<ChatMessage> chatMessages;

  final config = AppConfig();
  late Web3Helper web3Helper;

  ChatMessageController(Web3Helper _web3Helper) {
    init(_web3Helper);
  }

  init(Web3Helper _web3Helper) async {
    web3Helper = _web3Helper;
    chatMessages = [];
  }

  AudioPlayer _audioPlayer = AudioPlayer();

  // Function to play the "sent" sound
  Future<void> _playSentSound() async {
    // Replace 'sent_sound.mp3' with the name of your audio file
    await _audioPlayer.play(AssetSource('audio/pop.mp3'));
  }

  // Function to play the "sent" sound
  Future<void> _playReceiveSound() async {
    // Replace 'sent_sound.mp3' with the name of your audio file
    await _audioPlayer.play(AssetSource('audio/receive.mp3'));
  }

  // Add this method to convert chat messages to JSON
  List<Map<String, dynamic>> messagesToJson() {
    return chatMessages.map((message) => message.toJson()).toList();
  }

  List<ChatMessage> decodeChatMessages(String messagesJson) {
    List<dynamic> messagesData = jsonDecode(messagesJson);

    return messagesData.map((data) => ChatMessage.fromJson(data)).toList();
  }

  Future<List<ChatMessage>> getAllChatMessages(EthereumAddress addr) async {
    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('thunderPrivateKey');

    List<dynamic> result = await web3Helper.client.call(
        contract: web3Helper.thunderChatMessageContract,
        function: web3Helper.getAllMessagesFunction,
        params: [addr]);

    List<dynamic> chats = result[0];

    chatMessages = chats.map((item) {
      if (addr == item[0]) {
        item[2] = decrypt(privateKey, item[2]);
      } else {
        item[3] = decrypt(privateKey, item[3]);
      }

      return ChatMessage(
        sender: item[0],
        receiver: item[1],
        senderContent: item[2],
        receiverContent: item[3],
        created: DateTime.fromMillisecondsSinceEpoch(
            int.parse(item[4].toString()) * 1000),
      );
    }).toList();

    return chatMessages;
  }

  Future<List<ChatMessage>> getChatMessages(
      EthereumAddress addr, DateTime from) async {
    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('thunderPrivateKey');
    debugPrint("LastMessageDate: " + from.toIso8601String());
    debugPrint("Address: ${addr.hexEip55}");
    debugPrint(
        "dateTimeToUnixTimestampSeconds: ${dateTimeToUnixTimestampSeconds(from)}");
    List<dynamic> result = await web3Helper.client.call(
      contract: web3Helper.thunderChatMessageContract,
      function: web3Helper.getMessagesFunctionFrom,
      params: [addr, dateTimeToUnixTimestampSeconds(from)],
    );

    List<dynamic> chats = result[0];

    List<ChatMessage> newMessages = chats.map((item) {
      if (addr == item[0]) {
        item[2] = decrypt(privateKey, item[2]);
      } else {
        item[3] = decrypt(privateKey, item[3]);
      }
      return ChatMessage(
        sender: item[0],
        receiver: item[1],
        senderContent: item[2],
        receiverContent: item[3],
        created: DateTime.fromMillisecondsSinceEpoch(
          int.parse(item[4].toString()) * 1000,
        ),
      );
    }).toList();
    for (var message in newMessages) {
      debugPrint("Sender: ${message.sender.hexEip55}");
      debugPrint("Receiver: ${message.receiver.hexEip55}");
      debugPrint("Sender Content: ${message.senderContent}");
      debugPrint("Receiver Content: ${message.receiverContent}");
      debugPrint("Created: ${message.created.toIso8601String()}");
    }
    return newMessages;
  }

  Queue<ChatMessage> messageQueue = Queue();
  bool processingQueue =
      false; // Add this variable to track the queue processing status

  Future<void> sendMessage(
    String message,
    EthereumAddress myAddress,
    EthereumAddress friendAddress,
    String senderPublicKey,
    String receiverPublicKey,
    ChatProfileController chatProfileController,
  ) async {
    try {
      ChatMessage sentMessage = ChatMessage(
        sender: myAddress,
        receiver: friendAddress,
        senderContent: message, // The message content that will be sent
        receiverContent: message, // Empty content for the receiver
        created: DateTime.now(), // Use the current date and time
        isRequestSending: true,
      );
      // Add the message to the queue
      messageQueue.add(sentMessage);

      //sentMessage.receiverContent = encrypt(receiverPublicKey, message);

      chatMessages.add(sentMessage);
      chatProfileController.setLastMessage(
          friendAddress, sentMessage.senderContent, sentMessage.created, 0);
      // Play the "sent" sound
      _playSentSound();

      notifyListeners();

      // Process the queue only if it's not being processed
      if (!processingQueue) {
        processingQueue = true; // Acquire the lock
        await processMessageQueue(
          myAddress,
          senderPublicKey,
          receiverPublicKey,
          chatProfileController,
        );
        processingQueue = false; // Release the lock
      }

      debugPrint('sendMessage: Message added to the queue.');
    } catch (e) {
      debugPrint('sendMessage: Error occurred: $e');
    }
  }

  Future<void> processMessageQueue(
    EthereumAddress myAddress,
    String senderPublicKey,
    String receiverPublicKey,
    ChatProfileController chatProfileController,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('thunderPrivateKey');

    while (messageQueue.isNotEmpty) {
      ChatMessage sentMessage = messageQueue.first;
      bool isMessageSent = false;
      String currentNonce = "0";
      String encodedSendMessage;

      currentNonce = await web3Helper.getNouce(myAddress.hexEip55);
      debugPrint("currentNonce: $currentNonce");

      String encryptedSenderMessage =
          encrypt(senderPublicKey, sentMessage.senderContent);
      String encryptedReceiverMessage =
          encrypt(receiverPublicKey, sentMessage.receiverContent);

      encodedSendMessage = web3Helper.getEncodedSendMessageData(
        sentMessage.receiver,
        encryptedSenderMessage,
        encryptedReceiverMessage,
      );

      String json = web3Helper.getDataToSign(
        currentNonce,
        myAddress.hexEip55,
        encodedSendMessage,
        config.chatMessageProxyAddress,
      );

      String signature = web3Helper.signData(privateKey!, json);

      String requestEnvelope = web3Helper.getRequestEnveope(
        signature,
        currentNonce,
        myAddress.hexEip55,
        encodedSendMessage,
        config.chatMessageProxyAddress,
      );

      var txHash = await web3Helper.sendToAutoTask(
          requestEnvelope, config.messageAutoTaskURL);

      debugPrint("txHash" + txHash);

      debugPrint('processMessageQueue: Trying to removed from the queue.');
      // If the message was successfully sent, remove it from the queue
      messageQueue.removeFirst();
      debugPrint('processMessageQueue: Message removed from the queue.');

      // Update the message status and set isRequestSending to false
      sentMessage.isRequestSending = false;
      chatProfileController.setLastMessage(sentMessage.receiver,
          sentMessage.senderContent, sentMessage.created, 0);

      final directory = await getApplicationDocumentsDirectory();
      final fileProfile = File('${directory.path}/myProfile.json');
      final fileChat = File('${directory.path}/chatMessage.json');

      final myProfileJson =
          jsonEncode(chatProfileController.myProfile.toJson());
      final chatMessagesJson = jsonEncode(messagesToJson());

      await fileProfile.writeAsString(myProfileJson);
      await fileChat.writeAsString(chatMessagesJson);
    }
  }

  ChatMessage? getLatestMessageForAddress(EthereumAddress addr) {
    // Filter messages based on the provided address as sender or receiver
    List<ChatMessage> filteredMessages = chatMessages.where((message) {
      return message.sender == addr || message.receiver == addr;
    }).toList();

    // Sort the filtered messages by their created timestamp in descending order
    filteredMessages.sort((a, b) => b.created.compareTo(a.created));

    if (filteredMessages.isNotEmpty) {
      ChatMessage c = filteredMessages.first;

      return c;
    } else {
      return null;
    }
  }

  List<ChatMessage> getFriendMessages(EthereumAddress friendAddress) {
    // Filter messages based on the provided friend's address as sender or receiver
    List<ChatMessage> filteredMessages = chatMessages.where((message) {
      return message.sender == friendAddress ||
          message.receiver == friendAddress;
    }).toList();

    // Sort the filtered messages by their created timestamp in descending order
    filteredMessages.sort((b, a) => b.created.compareTo(a.created));

    return filteredMessages;
  }

  Future<void> getChatMessagesWhileOffline(
      ChatProfileController chatProfileController) async {
    // Get the latest created date from chatMessages
    DateTime latestCreatedDate =
        DateTime(2000); // A default value in case there are no messages

    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('thunderPrivateKey');

    if (chatMessages.isNotEmpty) {
      // Sort the chatMessages list by created timestamp in descending order
      chatMessages.sort((a, b) => b.created.compareTo(a.created));
      // Get the first message with the latest created timestamp
      latestCreatedDate = chatMessages.first.created;
    }

    // Call the web3Helper method to get new chat messages since the latest created date
    List<ChatMessage> newMessages = await getChatMessages(
        chatProfileController.myProfile.walletAddress, latestCreatedDate);

    debugPrint("Number of messages while offline: ${newMessages.length}");

    // for (var message in newMessages) {
    //   if (message.sender == chatProfileController.myProfile.walletAddress) {
    //     //message.senderContent = decrypt(privateKey, message.senderContent);
    //   } else {
    //     message.receiverContent = decrypt(privateKey, message.receiverContent);
    //   }
    // }

    // Group new messages by address
    Map<EthereumAddress, List<ChatMessage>> messagesByAddress = {};
    for (var message in newMessages) {
      messagesByAddress[message.sender] = [message];
    }

    // Update the latest message for each address in chatProfileController
    for (var address in messagesByAddress.keys) {
      if (address != chatProfileController.myProfile.walletAddress) {
        chatProfileController.setLastMessage(
          address,
          messagesByAddress[address]!.last.receiverContent,
          messagesByAddress[address]!.last.created,
          messagesByAddress[address]!.length,
        );
      }
    }

    // Append new messages to the existing chatMessages list
    chatMessages.addAll(newMessages);

    //notifyListeners();
  }

  startListener(ChatProfileController chatProfileController) async {
    print("Start Listening to Messages");

    FilterOptions options = FilterOptions(
      address: EthereumAddress.fromHex(config.chatMessageProxyAddress),
      fromBlock: BlockNum.current(),
      toBlock: BlockNum.current(),
      topics: [
        ["0x61148a3261ace8855b6a9c7e58a7c87e79c67a50a720460f71b71fa37577f074"]
      ],
    );
    var event = web3Helper.client.events(options);

    event.listen((e) async {
      final prefs = await SharedPreferences.getInstance();
      final String? privateKey = prefs.getString('thunderPrivateKey');

      // 1. Get the data from the event
      // Assuming your event has a data field that contains the message content
      dynamic eventData = e.data;
      //String messageContent = eventData["messageContent"];
      ChatMessage chatMessage = web3Helper.getDecodedSendMessageData(eventData);

      if (chatMessage.receiver ==
          chatProfileController.myProfile.walletAddress) {
        chatMessage.receiverContent =
            decrypt(privateKey, chatMessage.receiverContent);
        bool isExistingMessage = chatMessages.any((message) =>
            message.sender == chatMessage.sender &&
            message.receiver == chatMessage.receiver &&
            message.senderContent == chatMessage.senderContent &&
            message.receiverContent == chatMessage.receiverContent &&
            message.created == chatMessage.created);

        // 3. Add the chatMessage to the list if it doesn't exist
        if (!isExistingMessage) {
          _playReceiveSound();
          chatMessages.add(chatMessage);
          chatProfileController.setLastMessage(chatMessage.sender,
              chatMessage.receiverContent, chatMessage.created, 1);
        }

        // 4. Notify listeners
        notifyListeners();
      } else if (chatMessage.sender ==
          chatProfileController.myProfile.walletAddress) {
        chatMessage.senderContent =
            decrypt(privateKey, chatMessage.senderContent);

        // Check and update isRequestSending flag
        for (var message in chatMessages) {
          if (message.sender == chatProfileController.myProfile.walletAddress &&
              message.senderContent == chatMessage.senderContent &&
              message.isRequestSending) {
            message.isRequestSending = false;
            message.created = chatMessage.created;
            break; // Break after updating the first matching message
          }
        }

        // Notify listeners
        notifyListeners();
      }
      // 2. Check if the chatMessage already exists in the list
    });
  }

  BigInt dateTimeToUnixTimestampSeconds(DateTime dateTime) {
    return BigInt.from(dateTime.millisecondsSinceEpoch ~/ 1000);
  }

  int countUnreadMessages(FriendProfile friendProfile, DateTime lastRead) {
    int unreadMessages = 0;

    // Filter chat messages for the given friendProfile.walletAddress
    List<ChatMessage> friendMessages = chatMessages.where((message) {
      return (message.sender == friendProfile.walletAddress ||
          message.receiver == friendProfile.walletAddress);
    }).toList();

    // Count the number of messages with a timestamp greater than lastMessageRead
    for (var message in friendMessages) {
      if (message.created.isAfter(lastRead)) {
        unreadMessages++;
      }
    }

    return unreadMessages;
  }
}
