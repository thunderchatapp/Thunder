import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:thunder_chat/helpers/crypto.dart';
import 'package:thunder_chat/models/chatMessage.dart';

import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:thunder_chat/appconfig.dart';
import 'package:http/http.dart'
    as http; // Import the 'http' package with an alias.

class Web3Helper extends ChangeNotifier {
  final config = AppConfig();
  late Web3Client client;
  late DeployedContract minimalForwarderContract;
  late DeployedContract thunderChatProfileContract;
  late DeployedContract thunderChatMessageContract;
  late Credentials credentials;
  late String minimalForwarderAddress;
  late String chatProfileProxyAddress;
  //late ContractFunction getProfileFunction;
  late ContractFunction getProfileWithFriendListFunction;
  late ContractFunction getAllProfileFunction;
  late ContractFunction searchProfileFunction;
  late ContractFunction getNouceFunction;
  late ContractFunction addToFriendFunction;
  late ContractFunction isUserNameExist;
  late ContractFunction isUserIdExist;
  late ContractFunction getAllMessagesFunction;
  late ContractFunction getMessagesFunctionFrom;
  late ContractFunction sendMessageFunction;

  late ContractEvent sendMessageEvent;

  Web3Helper() {
    init();
  }

  Future<void> init() async {
    client = Web3Client(config.rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(config.wsUrl).cast<String>();
    });

    await getDeployedContract();
    // await getCreadentials();
    // await getDeployedContract();
  }

  Future<void> getDeployedContract() async {
    var abiCode = await rootBundle
        .loadString("contracts/build/contracts/MinimalForwarder.json");

    var contractAbi = ContractAbi.fromJson(abiCode, "MinimalForwarder");

    minimalForwarderContract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(config.minimalForwarder));

    abiCode = await rootBundle.loadString(
        "contracts/build/contracts/ThunderChatProfileContract.json");

    contractAbi = ContractAbi.fromJson(abiCode, "ThunderChatProfileContract");

    thunderChatProfileContract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(config.chatProfileProxyAddress));

    abiCode = await rootBundle.loadString(
        "contracts/build/contracts/ThunderChatMessageContract.json");

    contractAbi = ContractAbi.fromJson(abiCode, "ThunderChatMessageContract");

    thunderChatMessageContract = DeployedContract(
        contractAbi, EthereumAddress.fromHex(config.chatMessageProxyAddress));

    minimalForwarderAddress = config.getAddress("minimalForwarder");
    chatProfileProxyAddress = config.getAddress("chatProfileProxyAddress");

    getProfileWithFriendListFunction =
        thunderChatProfileContract.function("getProfileWithFriendList");

    getAllProfileFunction =
        thunderChatProfileContract.function("getAllProfiles");

    searchProfileFunction =
        thunderChatProfileContract.function("searchProfiles");

    addToFriendFunction =
        thunderChatProfileContract.function("addToFriendRequestlist");

    getNouceFunction = minimalForwarderContract.function("getNonce");

    isUserNameExist = thunderChatProfileContract.function("isUserNameExist");

    isUserIdExist = thunderChatProfileContract.function("isUserIdExist");

    getAllMessagesFunction = thunderChatMessageContract.function("getMessage");

    sendMessageFunction = thunderChatMessageContract.function("sendMessage");

    getMessagesFunctionFrom =
        thunderChatMessageContract.function("getMessagesFunctionFrom");

    sendMessageEvent = thunderChatMessageContract.event("SendMessage");

    debugPrint("Web3Helper: Deployed contracts ready.");
  }

  String signData(String myPrivateKey, String json) {
    String signature = EthSigUtil.signTypedData(
        privateKey: myPrivateKey, jsonData: json, version: TypedDataVersion.V3);
    return signature;
  }

  Future<String> getNouce(String myAddress) async {
    String nouce;

    List result = await client.call(
      contract: minimalForwarderContract,
      function: getNouceFunction,
      params: [EthereumAddress.fromHex(myAddress)],
    );
    nouce = result[0].toString();

    return nouce;
  }

  String getEncodedCreateProfileData(String userId, String name,
      String photoURL, String referredBy, String publicKey, String fcmToken) {
    final encodedCreateProfileFunction =
        thunderChatProfileContract.abi.functions.firstWhere(
      (function) => function.name == 'addProfile',
      orElse: () => throw Exception('Function "addProfile" not found in ABI'),
    );
    debugPrint("0x");
    final encodeFunction = encodedCreateProfileFunction
        .encodeCall([userId, name, photoURL, referredBy, publicKey, fcmToken]);
    debugPrint("0x${hex.encode(encodeFunction)}");
    return "0x${hex.encode(encodeFunction)}";
  }

  // String getDecodeCreateProfileData(String data) {
  //   var encodeFunction =
  //       thunderChatProfileContract.abi.functions[1].decodeReturnValues(data);

  //   return encodeFunction;
  // }

  String getEncodedAddFriendData(EthereumAddress friendAddress) {
    final addToFriend = thunderChatProfileContract.abi.functions.firstWhere(
      (function) => function.name == 'addToFriendRequestlist',
      orElse: () =>
          throw Exception('Function "addToFriendRequestlist" not found in ABI'),
    );

    final encodeFunction = addToFriend.encodeCall([friendAddress]);

    return "0x${hex.encode(encodeFunction)}";
  }

  String getEncodedDeleteFriendData(EthereumAddress friendAddress) {
    final deleteFriendFunction =
        thunderChatProfileContract.abi.functions.firstWhere(
      (function) => function.name == 'deleteFriend',
      orElse: () => throw Exception('Function "deleteFriend" not found in ABI'),
    );

    final encodeFunction = deleteFriendFunction.encodeCall([friendAddress]);

    return "0x${hex.encode(encodeFunction)}";
  }

  String getEncodedUpdateProfileData(
      String name, String description, String photoURL) {
    final updateProfileFunction =
        thunderChatProfileContract.abi.functions.firstWhere(
      (function) => function.name == 'updateProfile',
      orElse: () =>
          throw Exception('Function "updateProfile" not found in ABI'),
    );

    final encodeFunction =
        updateProfileFunction.encodeCall([name, description, photoURL]);

    return "0x${hex.encode(encodeFunction)}";
  }

  String getEncodedApproveFriendData(EthereumAddress friendAddress) {
    final approveFriendFunction =
        thunderChatProfileContract.abi.functions.firstWhere(
      (function) => function.name == 'approveFriend',
      orElse: () =>
          throw Exception('Function "approveFriend" not found in ABI'),
    );

    final encodeFunction = approveFriendFunction.encodeCall([friendAddress]);
    debugPrint(approveFriendFunction.encodeName());

    return '0x${hex.encode(encodeFunction)}';
  }

  String getDataToSign(
      String nonce, String address, String encodedData, String destAddress) {
    String chainId = config.chainID.toString();
    String json = '''{
          "types": {
            "EIP712Domain": [
                  {"name": "name", "type": "string"},
                  {"name": "version", "type": "string"},
                  {"name": "chainId", "type": "uint256"},
                  {"name": "verifyingContract", "type": "address"}
                ],
            "ForwardRequest": [
                { "name": "from", "type": "address" },
                { "name": "to", "type": "address" },
                { "name": "value", "type": "uint256" },
                { "name": "gas", "type": "uint256" },
                { "name": "nonce", "type": "uint256" },
                { "name": "data", "type": "bytes" }
            ]
          },
          "domain": {
            "name": "MinimalForwarder",
            "version": "0.0.1",
            "chainId": "$chainId",
            "verifyingContract": "$minimalForwarderAddress"
          },
          "primaryType": "ForwardRequest",
          "message": {
            "value": 0,
            "gas": 1000000,
            "nonce": "$nonce",
            "to": "$destAddress",
            "from": "$address",
            "data": "$encodedData"
          }
        }''';

    return json;
  }

  String getRequestEnveope(String signature, String nonce, String address,
      String encodedData, String destAddress) {
    String json = '''{
          "signature": "$signature",
          "request": {
            "value": 0,
            "gas": 1000000,
            "nonce": "$nonce",
            "to": "$destAddress",
            "from": "$address",
            "data": "$encodedData"
          }
        }''';

    return json;
  }

  Future<String> sendToAutoTask(String requestEnvelope, String url) async {
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestEnvelope,
    );

    // Check if the request was successful (HTTP status code 200).
    if (response.statusCode == 200) {
      // Parse the response body to get the txHash.
      try {
        var responseBody = jsonDecode(response.body);
        var result = jsonDecode(responseBody["result"]);
        var txHash = result["txHash"] as String;

        return txHash;
      } catch (e) {
        debugPrint('Error occurred while parsing the response body: $e');
        return 'error';
      }
    } else {
      debugPrint(
          'Request to autoTask failed with status code: ${response.statusCode}');
      return 'error';
    }
  }

  String getEncodedSendMessageData(EthereumAddress friendAddress,
      String senderEncryptedMessage, String receiverEncryptedMessage) {
    final sendMessageFunction =
        thunderChatMessageContract.abi.functions.firstWhere(
      (function) => function.name == 'sendMessage',
      orElse: () => throw Exception('Function "sendMessage" not found in ABI'),
    );

    final encodeFunction = sendMessageFunction.encodeCall(
        [friendAddress, senderEncryptedMessage, receiverEncryptedMessage]);
    debugPrint(sendMessageFunction.encodeName());

    return '0x${hex.encode(encodeFunction)}';
  }

  ChatMessage getDecodedSendMessageData(String strReturnValues) {
    final sendMessageFunction =
        thunderChatMessageContract.abi.functions.firstWhere(
      (function) => function.name == 'sendMessage',
      orElse: () => throw Exception('Function "sendMessage" not found in ABI'),
    );

    List<dynamic> decodedData = sendMessageEvent.decodeResults(
        ["0x61148a3261ace8855b6a9c7e58a7c87e79c67a50a720460f71b71fa37577f074"],
        strReturnValues);

    EthereumAddress sender = decodedData[0] as EthereumAddress;
    EthereumAddress receiver = decodedData[1] as EthereumAddress;
    String senderMessage = decodedData[2] as String;
    String receiverMessage = decodedData[3] as String;
    BigInt timestamp = decodedData[4] as BigInt;

    return ChatMessage(
      sender: sender,
      receiver: receiver,
      senderContent: senderMessage,
      receiverContent: receiverMessage,
      created: DateTime.fromMillisecondsSinceEpoch(
          int.parse(timestamp.toString()) * 1000),
    );
  }
}
