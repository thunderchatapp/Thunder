import 'dart:convert';
import 'package:flutter_app/models/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:flutter_app/models/chatMessage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:ethers/signers/wallet.dart' as w;
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatMessageController extends ChangeNotifier {
  List<ChatMessage> chatMessages = [];

  String LoadProfile = "Dreamz";
  //String LoadProfile = "Velar";

  bool isLoading = true;

  final String _rpcUrl = "https://arb-goerli.g.alchemy.com/v2/xxx";
  final String _wsUrl = "wss://arb-goerli.g.alchemy.com/v2/xxx";

  late String _senderPrivateKey;
  late String _senderPublicKey;
  late String _receiverPublicKey;

  late EthereumAddress _receiverAddress;
  late EthereumAddress _senderAddress;

  late Web3Client _client;
  late String _abiCode;

  late Credentials _credentials;
  late EthereumAddress _contractSenderAddress;
  late EthereumAddress _contractReceiverAddress;
  late DeployedContract _senderContract;
  late DeployedContract _receiverContract;

  late ContractFunction _getMessages;
  late ContractFunction _sendMessage;

  ChatMessageController() {
    init();
  }

  init() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    if (LoadProfile == "Dreamz") {
      _senderPrivateKey = "";

      _receiverPublicKey = "";

      //_receiverPublicKey = "";

      _contractSenderAddress = EthereumAddress.fromHex("");

      _contractReceiverAddress = EthereumAddress.fromHex("");

      _senderAddress = EthereumAddress.fromHex("");

      _receiverAddress = EthereumAddress.fromHex("");
    } else //velar
    {
      _senderPrivateKey = "";

      _receiverPublicKey = "";

      _contractSenderAddress = EthereumAddress.fromHex("");

      _contractReceiverAddress = EthereumAddress.fromHex("");

      _senderAddress = EthereumAddress.fromHex("");

      _receiverAddress = EthereumAddress.fromHex("");
    }

    await getAbi();
    await getCreadentials();
    await getDeployedSenderContract();
    await getDeployedReceiverContract();
    await getMessages();
  }

  Future<void> getAbi() async {
    _abiCode = await rootBundle
        .loadString("contracts/build/contracts/ThunderChatContract.json");
    //var jsonAbi = jsonDecode(abiStringFile);
    //_abiCode = jsonEncode(jsonAbi['abi']);
    //_contractAddress =
    //    EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCreadentials() async {
    _credentials = EthPrivateKey.fromHex(_senderPrivateKey);

    final walletPrivateKey = w.Wallet.fromPrivateKey(_senderPrivateKey);

    final publicKey = walletPrivateKey.signingKey?.publicKey;
    if (publicKey != null) {
      _senderPublicKey = publicKey.substring(2);
    } else {
      _senderPublicKey = "";
    }
  }

  Future<void> getDeployedSenderContract() async {
    _senderContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "ThunderChatContract"),
        _contractSenderAddress);

    _getMessages = _senderContract.function("getMessages");

    //await getMessages();
  }

  Future<void> getDeployedReceiverContract() async {
    _receiverContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "ThunderChatContract"),
        _contractReceiverAddress);

    _sendMessage = _receiverContract.function("sendMessage");

    //await getMessages();
  }

  getMessages() async {
    List<dynamic> result = await _client.call(
      contract: _senderContract,
      function: _getMessages,
      params: [_receiverAddress],
    );

    for (var msg in result[0]) {
      EthereumAddress sender = msg[0];
      String content = msg[1];
      int created = (msg[2]).toInt();
      try {
        content = decrypt(_senderPrivateKey, content);
      } catch (e) {}

      ChatMessage message = ChatMessage(
          sender: sender,
          content: content,
          type: "receiver",
          created: DateTime.fromMillisecondsSinceEpoch(created * 1000));

      bool found = false;
      for (var j = 0; j < chatMessages.length; j++) {
        if (chatMessages[j].sender == message.sender &&
            chatMessages[j].content == message.content &&
            chatMessages[j].created == message.created) {
          found = true;
          break;
        }
      }

      if (!found) {
        chatMessages.add(message);
      }
    }

    isLoading = false;

    notifyListeners();

    // Listen for pending transactions
    final channel = IOWebSocketChannel.connect(_wsUrl);

    final request = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'eth_subscribe',
      'params': [
        'alchemy_minedTransactions',
        {
          'addresses': [
            {'to': _contractSenderAddress.hexEip55}
          ],
          'includeRemoved': false,
          'hashesOnly': true
        }
      ]
    };

    channel.stream.listen((event) async {
      List<dynamic> result = await _client.call(
        contract: _senderContract,
        function: _getMessages,
        params: [_receiverAddress],
      );

      try {
        //FlutterRingtonePlayer.playNotification();

        // FlutterRingtonePlayer.play(
        //   android: AndroidSounds.notification,
        //   ios: IosSounds.glass,
        // );
        AudioPlayer? _player;
        final player = _player = AudioPlayer();
        player.play(AssetSource('audio/receive.wav'));
      } catch (e) {}
      for (var msg in result[0]) {
        EthereumAddress sender = msg[0];
        String content = msg[1];
        int created = (msg[2]).toInt();
        try {
          content = decrypt(_senderPrivateKey, content);
        } catch (e) {}
        ChatMessage message = ChatMessage(
            sender: sender,
            content: content,
            type: "receiver",
            created: DateTime.fromMillisecondsSinceEpoch(created * 1000));

        bool found = false;
        for (var j = 0; j < chatMessages.length; j++) {
          if (chatMessages[j].sender == message.sender &&
              chatMessages[j].content == message.content &&
              chatMessages[j].created == message.created) {
            found = true;
            break;
          }
        }

        if (!found) {
          chatMessages.add(message);
        }
      }

      isLoading = false;

      notifyListeners();
    });

    channel.sink.add(jsonEncode(request));
  }

  sendMessage(String content) async {
    isLoading = true;
    notifyListeners();

    ChatMessage message = ChatMessage(
        sender: _senderAddress,
        content: content,
        type: "sender",
        created: DateTime.now());

    try {
      AudioPlayer? _player;
      final player = _player = AudioPlayer();
      player.play(AssetSource('audio/pop.mp3'));
      chatMessages.add(message);
      await _client.sendTransaction(
          _credentials,
          Transaction.callContract(
            contract: _receiverContract,
            function: _sendMessage,
            parameters: [encrypt(_receiverPublicKey, content)],
          ),
          chainId: 421613);
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black12,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    //await getMessages();
  }
}
