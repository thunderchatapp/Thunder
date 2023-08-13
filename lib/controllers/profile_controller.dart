import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder_chat/controllers/message_controller.dart';

import 'package:thunder_chat/helpers/web3Helper.dart';
import 'package:thunder_chat/models/chatMessage.dart';
import 'package:thunder_chat/models/chatProfileModel.dart';
import 'package:thunder_chat/models/friendProfile.dart';
import 'package:thunder_chat/models/lastReadModal.dart';
import 'package:thunder_chat/screens/friends/friendAddPage.dart';
import 'package:thunder_chat/screens/profile/profilePage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:thunder_chat/appconfig.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ChatProfileController extends ChangeNotifier {
  late ChatProfile myProfile;
  final config = AppConfig();
  late Web3Helper web3Helper;
  late List<LastReadModal> lastReadList;

  String lastEventData = "";

  ChatProfileController(Web3Helper _web3Helper) {
    init(_web3Helper);
  }

  init(Web3Helper _web3Helper) async {
    web3Helper = _web3Helper;
    lastReadList = [];
    myProfile = ChatProfile(
        walletAddress: EthereumAddress.fromHex(
            "0x0000000000000000000000000000000000000000"),
        userId: "",
        name: "",
        description: "",
        photoURL: "",
        publicKey: "",
        referrerCode: "",
        referredBy: "",
        fcmToken: "",
        created: DateTime.now());
  }

  Future<ChatProfile> getProfileWithFriendList(EthereumAddress myAddress,
      ChatMessageController? messageController) async {
    List<dynamic> result = await web3Helper.client.call(
      contract: web3Helper.thunderChatProfileContract,
      function: web3Helper.getProfileWithFriendListFunction,
      params: [myAddress],
    );

    if (result[0][1] == "") {
      throw Exception("Profile not found");
    }

    myProfile = ChatProfile(
      walletAddress: result[0][0],
      userId: result[0][1],
      name: result[0][2],
      description: result[0][3],
      photoURL: result[0][4],
      publicKey: result[0][5],
      referrerCode: result[0][6],
      referredBy: result[0][7],
      fcmToken: result[0][8],
      created: DateTime.fromMillisecondsSinceEpoch(
        int.parse(result[0][9].toString()) * 1000,
      ),
    );

    List<dynamic> friends = result[0][10];
    List<FriendProfile> friendList = friends.map((item) {
      ChatMessage? lastChat;
      String lastMessage = "";
      DateTime lastSentMessage = DateTime.now();

      // Check if the friend's address is in the lastReadList
      bool foundInLastReadList = false;
      if (messageController != null) {
        for (var lastRead in lastReadList) {
          if (lastRead.walletAddress == item[0]) {
            foundInLastReadList = true;
            break;
          }
        }
      }

      // If friend address not found in lastReadList, add an entry with lastread date 1 year before current date
      if (!foundInLastReadList) {
        DateTime lastReadDate = DateTime.now().subtract(Duration(days: 365));
        lastReadList.add(LastReadModal(
          walletAddress: item[0],
          lastMessageRead: lastReadDate,
        ));
      }

      if (messageController != null) {
        lastChat = messageController.getLatestMessageForAddress(item[0]);
        if (lastChat != null) {
          if (item[0] != lastChat.sender) {
            lastMessage = lastChat.senderContent;
          } else {
            lastMessage = lastChat.receiverContent;
          }
          lastSentMessage = lastChat.created;
        }
      }

      return FriendProfile(
        walletAddress: item[0],
        userId: item[1],
        name: item[2],
        description: item[3],
        photoURL: item[4],
        publicKey: item[5],
        referrerCode: item[6],
        referredBy: item[7],
        fcmToken: item[8],
        created: DateTime.fromMillisecondsSinceEpoch(
            int.parse(item[9].toString()) * 1000),
        isApproved: item[10],
        isRequester: item[11],
        added: DateTime.now(),
        lastMessage: lastMessage,
        lastMessageSent: lastSentMessage,
      );
    }).toList();

    myProfile.friendList = friendList;

    return myProfile;
  }

  Future<List<ChatProfile>> getAllProfile() async {
    List<ChatProfile> profileList = [];

    List<dynamic> result = await web3Helper.client.call(
        contract: web3Helper.thunderChatProfileContract,
        function: web3Helper.getAllProfileFunction,
        params: []);

    // Cast the result to profileList
    for (dynamic item in result[0]) {
      // Assuming ChatProfile constructor takes appropriate arguments
      ChatProfile profile = ChatProfile(
        walletAddress: item[0],
        userId: item[1],
        name: item[2],
        description: item[3],
        photoURL: item[4],
        publicKey: item[5],
        referrerCode: item[6],
        referredBy: item[7],
        fcmToken: item[8],
        created: DateTime.fromMillisecondsSinceEpoch(
          int.parse(result[0][9].toString()) * 1000,
        ),
      );

      profileList.add(profile);
    }

    return profileList;
  }

  Future<bool> checkUserNameExits(userName) async {
    List<dynamic> result = await web3Helper.client.call(
        contract: web3Helper.thunderChatProfileContract,
        function: web3Helper.isUserNameExist,
        params: [userName]);

    return result[0];
  }

  Future<bool> checkUserIdExits(String userId) async {
    List<dynamic> result = await web3Helper.client.call(
        contract: web3Helper.thunderChatProfileContract,
        function: web3Helper.isUserIdExist,
        params: [userId]);

    return result[0];
  }

  Future<List<ChatProfile>> searchProfile(String strSearch) async {
    List<ChatProfile> profileList = [];

    List<dynamic> result = await web3Helper.client.call(
        contract: web3Helper.thunderChatProfileContract,
        function: web3Helper.searchProfileFunction,
        params: [strSearch, myProfile.walletAddress]);
    // Cast the result to profileList
    for (dynamic item in result[0]) {
      // Assuming ChatProfile constructor takes appropriate arguments
      if (item[1] != "") {
        ChatProfile profile = ChatProfile(
          walletAddress: item[0],
          userId: item[1],
          name: item[2],
          description: item[3],
          photoURL: item[4],
          publicKey: item[5],
          referrerCode: item[6],
          referredBy: item[7],
          fcmToken: item[8],
          created: DateTime.fromMillisecondsSinceEpoch(
            int.parse(item[9].toString()) * 1000,
          ),
        );

        profileList.add(profile);
      }
    }

    return profileList;
  }

  Future<void> updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('thunderPrivateKey');

    String currentNonce = "0";
    String encodedUpdateProfile;

    String myAddress = myProfile.walletAddress.hexEip55;

    try {
      currentNonce = await web3Helper.getNouce(myAddress);
      debugPrint("currentNonce: $currentNonce");

      encodedUpdateProfile = web3Helper.getEncodedUpdateProfileData(
          myProfile.name, myProfile.description, myProfile.photoURL);

      String json = web3Helper.getDataToSign(currentNonce, myAddress,
          encodedUpdateProfile, config.chatProfileProxyAddress);

      String signature = web3Helper.signData(privateKey!, json);

      String requestEnvelope = web3Helper.getRequestEnveope(
          signature,
          currentNonce,
          myAddress,
          encodedUpdateProfile,
          config.chatProfileProxyAddress);

      await web3Helper.sendToAutoTask(requestEnvelope, config.autoTaskURL);

      debugPrint('Transaction is confirmed.');
    } catch (e) {
      debugPrint('Update Profile: Error occurred: $e');
    }
  }

  Future<void> addToFriend(EthereumAddress friendAddress) async {
    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('thunderPrivateKey');

    String currentNonce = "0";
    String encodedAddFriend;

    String myAddress = myProfile.walletAddress.hexEip55;

    try {
      currentNonce = await web3Helper.getNouce(myAddress);
      debugPrint("currentNonce: $currentNonce");

      encodedAddFriend = web3Helper.getEncodedAddFriendData(friendAddress);

      String json = web3Helper.getDataToSign(currentNonce, myAddress,
          encodedAddFriend, config.chatProfileProxyAddress);

      String signature = web3Helper.signData(privateKey!, json);

      String requestEnvelope = web3Helper.getRequestEnveope(
          signature,
          currentNonce,
          myAddress,
          encodedAddFriend,
          config.chatProfileProxyAddress);

      await web3Helper.sendToAutoTask(requestEnvelope, config.autoTaskURL);

      debugPrint('Transaction is confirmed.');
    } catch (e) {
      debugPrint('addToFriend: Error occurred: $e');
    }
  }

  Future<void> approveFriend(EthereumAddress friendAddress) async {
    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('thunderPrivateKey');

    String currentNonce = "0";
    String encodedApproveFriend;

    String myAddress = myProfile.walletAddress.hexEip55;

    try {
      currentNonce = await web3Helper.getNouce(myAddress);
      debugPrint("currentNonce: $currentNonce");

      encodedApproveFriend =
          web3Helper.getEncodedApproveFriendData(friendAddress);

      String json = web3Helper.getDataToSign(currentNonce, myAddress,
          encodedApproveFriend, config.chatProfileProxyAddress);

      String signature = web3Helper.signData(privateKey!, json);

      String requestEnvelope = web3Helper.getRequestEnveope(
          signature,
          currentNonce,
          myAddress,
          encodedApproveFriend,
          config.chatProfileProxyAddress);

      await web3Helper.sendToAutoTask(requestEnvelope, config.autoTaskURL);

      notifyListeners();

      debugPrint('Transaction is confirmed.');
    } catch (e) {
      debugPrint('approveFriend: Error occurred: $e');
    }
  }

  Future<void> deleteFriend(EthereumAddress friendAddress) async {
    final prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('thunderPrivateKey');

    String currentNonce = "0";
    String encodedDeleteFriend;

    String myAddress = myProfile.walletAddress.hexEip55;

    try {
      currentNonce = await web3Helper.getNouce(myAddress);
      debugPrint("currentNonce: $currentNonce");

      encodedDeleteFriend =
          web3Helper.getEncodedDeleteFriendData(friendAddress);

      String json = web3Helper.getDataToSign(currentNonce, myAddress,
          encodedDeleteFriend, config.chatProfileProxyAddress);

      String signature = web3Helper.signData(privateKey!, json);

      String requestEnvelope = web3Helper.getRequestEnveope(
          signature,
          currentNonce,
          myAddress,
          encodedDeleteFriend,
          config.chatProfileProxyAddress);

      await web3Helper.sendToAutoTask(requestEnvelope, config.autoTaskURL);

      debugPrint('Transaction is confirmed.');
    } catch (e) {
      debugPrint('deleteFriend: Error occurred: $e');
    }
  }

  createProfile(
      String userId,
      String name,
      String photoURL,
      String publicKey,
      String myAddress,
      String referredBy,
      String myPrivateKey,
      String fcmToken) async {
    String currentNonce = "0";
    String encodedCreateProfile;
    String requestEnveope = "";

    currentNonce = await web3Helper.getNouce(myAddress);
    debugPrint("currentNonce: $currentNonce");

    encodedCreateProfile = web3Helper.getEncodedCreateProfileData(
        userId, name, photoURL, referredBy, publicKey, fcmToken);

    String json = web3Helper.getDataToSign(currentNonce, myAddress,
        encodedCreateProfile, config.chatProfileProxyAddress);
    debugPrint("json: $json");

    String signature = web3Helper.signData(myPrivateKey, json);

    requestEnveope = web3Helper.getRequestEnveope(signature, currentNonce,
        myAddress, encodedCreateProfile, config.chatProfileProxyAddress);

    debugPrint("requestEnveope: $requestEnveope");

    // web3Helper.getNouce(myAddress).then((String value) async {
    //   currentNonce = value;
    //   debugPrint("currentNonce: $currentNonce");

    //   encodedCreateProfile = web3Helper.getEncodedCreateProfileData(
    //       userId, name, description, photoURL, referredBy, publicKey);

    //   String json = web3Helper.getDataToSign(currentNonce, myAddress,
    //       encodedCreateProfile, config.chatProfileProxyAddress);
    //   debugPrint("json: $json");

    //   String signature = web3Helper.signData(myPrivateKey, json);

    //   requestEnveope = web3Helper.getRequestEnveope(signature, currentNonce,
    //       myAddress, encodedCreateProfile, config.chatProfileProxyAddress);

    //   debugPrint("requestEnveope: $requestEnveope");
    // });

    await web3Helper.sendToAutoTask(requestEnveope, config.autoTaskURL);
  }

  startListener() {
    print("Start Listening to Profile");

    // delete friend 0xd928e5eaee8782e317467d0706f20a6f9c413f7834988a93b8cfd2be2cb08222
    // request friend 0xa78ae4450b1041552aeed00b140f3e0d7800b105d8d886dcf18bfe436a1c482e
    // create profile 0x65411b039719f2a8fc6399652492756dbdeda636b31d17ec654ba1d20d86aaef
    // approve friend 0xedc97f617c669ea0b99886c655bda01b80c0ff14aea5b91f57b385dad2b0d076
    FilterOptions options = FilterOptions(
      address: EthereumAddress.fromHex(config.chatProfileProxyAddress),
      fromBlock: BlockNum.current(),
      toBlock: BlockNum.current(),
      topics: [
        [
          "0xd928e5eaee8782e317467d0706f20a6f9c413f7834988a93b8cfd2be2cb08222",
          "0xa78ae4450b1041552aeed00b140f3e0d7800b105d8d886dcf18bfe436a1c482e",
          "0xedc97f617c669ea0b99886c655bda01b80c0ff14aea5b91f57b385dad2b0d076"
        ],
      ],
    );
    var event = web3Helper.client.events(options);

    event.listen((e) async {
      dynamic eventData = e.data;

      if (lastEventData != eventData.toString()) {
        lastEventData = eventData.toString();

        debugPrint("Listener Triggered: data = " + lastEventData);

        if (eventData.toString().indexOf(myProfile.walletAddress.hexNo0x) > 0) {
          debugPrint("My address found.");
          // Fetch the profile with friend list and wait for the result

          var value =
              await getProfileWithFriendList(myProfile.walletAddress, null);

          // Update the profile and notify listeners
          myProfile = value;
          notifyListeners();
        }
      }
    });
  }

  Future<void> setLastMessage(EthereumAddress friendAddress, String lastMessage,
      DateTime lastMessageSent, int unreadMessages) async {
    // Find the corresponding friend in the friendList or use null if not found
    FriendProfile? friend = myProfile.friendList.firstWhere(
      (friend) => friend.walletAddress == friendAddress,
    );

    // If the friend exists, update the lastMessage and lastMessageSent
    if (friend != null) {
      friend.lastMessage =
          lastMessage; // Or chatMessage.receiverContent depending on the condition
      friend.lastMessageSent = lastMessageSent;
    }

    // Notify listeners that the friend's last message has been updated
    notifyListeners();
  }

  List<Map<String, dynamic>> lastReadToJson() {
    return lastReadList.map((lastRead) => lastRead.toJson()).toList();
  }

  DateTime getDateFromLastReadList(EthereumAddress address) {
    // Find the entry in lastReadList for the given address
    LastReadModal? lastReadModal =
        lastReadList.firstWhere((modal) => modal.walletAddress == address);

    // If the entry is found, return the lastMessageRead date
    if (lastReadModal != null) {
      return lastReadModal.lastMessageRead;
    }

    // If the entry is not found, return a default date (e.g., 1 year before current date)
    return DateTime.now().subtract(Duration(days: 365));
  }

  // Method to update the lastRead for the corresponding friend in the lastReadList
  Future<void> updateLastRead(LastReadModal lastReadModal) async {
    int index = lastReadList.indexWhere(
      (modal) => modal.walletAddress == lastReadModal.walletAddress,
    );
    if (index != -1) {
      lastReadList[index] = lastReadModal;
    } else {
      lastReadList.add(lastReadModal);
    }
    // You might want to persist the updated lastReadList in local storage or database here.
    // (e.g., using SharedPreferences or SQLite).
    final directory = await getApplicationDocumentsDirectory();

    final lastRead = File('${directory.path}/lastRead.json');

    final lastReadJson = jsonEncode(lastReadToJson());

    lastRead.writeAsString(lastReadJson);

    debugPrint(
        "lastReadModal: ${lastReadModal.lastMessageRead.toIso8601String()}");

    notifyListeners();
  }

  List<LastReadModal> decodeLastRead(String messagesJson) {
    List<dynamic> lastReadData = jsonDecode(messagesJson);
    return lastReadData.map((data) => LastReadModal.fromJson(data)).toList();
  }
}
