import 'dart:convert';
import 'dart:io';
//import 'package:flutter_web3/flutter_web3.dart' as e;
import 'package:flutter_app/models/chatProfileModel.dart';
import 'package:flutter_app/models/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/screens/addFriendByQRScan.dart';
import 'package:http/http.dart';
import 'package:flutter_app/models/chatMessage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:ethers/signers/wallet.dart' as w;
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_app/appconfig.dart';

class ChatMessageController extends ChangeNotifier {
  List<ChatMessage> chatMessages = [];
  List<ChatProfile> friendList = [];
  final config = AppConfig();
  bool isLoading = true;

  late String _rpcUrl;
  late String _wsUrl;

  late String _myPrivateKey;
  late String _myPublicKey;
  late EthereumAddress _myAddress;
  late EthereumAddress _myChatAddress;
  late DeployedContract _myChatContract;

  late String _receiverPublicKey;
  late EthereumAddress _receiverChatAddress;
  late EthereumAddress _receiverAddress;

  late Web3Client _client;
  late String _abiCode;

  late Credentials _credentials;

  late ContractFunction _getMessages;
  late ContractFunction _sendMessage;
  late ContractFunction _getAllFriends;
  late ContractFunction _addToFriendlist;
  late ContractFunction _receiveMessage;

  late DeployedContract _profileContract;
  late EthereumAddress _profileContractAddress;
  late ContractFunction _getProfile;

  late ChatProfile _chatProfile;
  late ChatProfile _friendProfile;
  ChatProfile get chatProfile => _chatProfile;

  ChatMessageController() {
    init();
  }

  init() async {
    _rpcUrl = config.rpcUrl;
    _wsUrl = config.wsUrl;
    _profileContractAddress =
        EthereumAddress.fromHex(config.profileContractAddress);

    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getCreadentials();
    await getMyProfile();
    await getDeployedThunderChatContract();
    await getFriendList();

    //await getDeployedReceiverContract();
    //await getMessages();
  }

  Future<void> getCreadentials() async {
    final prefs = await SharedPreferences.getInstance();
    _myPrivateKey = prefs.getString('privateKey') ?? '0';
    _credentials = EthPrivateKey.fromHex(_myPrivateKey);
    _myAddress = _credentials.address;
    final walletPrivateKey = w.Wallet.fromPrivateKey(_myPrivateKey);

    final publicKey = walletPrivateKey.signingKey?.publicKey;
    if (publicKey != null) {
      _myPublicKey = publicKey.substring(2);
    } else {
      _myPublicKey = "";
    }
  }

  Future<void> getDeployedThunderChatContract() async {
    _abiCode = await rootBundle
        .loadString("contracts/build/contracts/ThunderChatContract.json");

    _myChatContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "ThunderChatContract"), _myChatAddress);

    _getMessages = _myChatContract.function("getMessages");
    _sendMessage = _myChatContract.function("sendMessage");
    _receiveMessage = _myChatContract.function("receiveMessage");
    _getAllFriends = _myChatContract.function("getAllFriends");
    _addToFriendlist = _myChatContract.function("addToFriendlist");
    //await getMessages();
  }

  getMessages(ChatProfile friendProfile) async {
    bool boolFirstLoad = true;

    if (chatMessages.length > 0) {
      if (chatMessages[0].sender != friendProfile.walletAddress) {
        chatMessages = [];
        boolFirstLoad = true;
      } else {
        boolFirstLoad = false;
      }
    } else {
      boolFirstLoad = true;
    }
    List<dynamic> result = await _client.call(
      contract: _myChatContract,
      function: _getMessages,
      params: [friendProfile.walletAddress],
    );

    for (var msg in result[0]) {
      EthereumAddress sender = msg[0];
      String type = msg[1];
      String content = msg[2];
      int created = (msg[3]).toInt();
      try {
        content = decrypt(_myPrivateKey, content);
      } catch (e) {}

      ChatMessage message = ChatMessage(
          sender: sender,
          content: content,
          type: type,
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
        if (boolFirstLoad == false) {
          if (message.type == "received") {
            AudioPlayer? _player;
            final player = _player = AudioPlayer();
            player.play(AssetSource('audio/receive.mp3'));
            found = true;
            chatMessages.add(message);
          }
        } else {
          chatMessages.add(message);
        }
      }
    }

    isLoading = false;

    notifyListeners();

    // Listen for pending transactions
    /* final channel = IOWebSocketChannel.connect(_wsUrl);

    final request = {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'eth_subscribe',
      'params': [
        'alchemy_minedTransactions',
        {
          'addresses': [
            {'to': _myAddress.hexEip55}
          ],
          'includeRemoved': false,
          'hashesOnly': true
        }
      ]
    }; */

    /* channel.stream.listen((event) async {
      List<dynamic> result = await _client.call(
        contract: _myChatContract,
        function: _getMessages,
        params: [_receiverAddress],
      );

      for (var msg in result[0]) {
        EthereumAddress sender = msg[0];
        String content = msg[1];
        int created = (msg[2]).toInt();
        try {
          content = decrypt(_myPrivateKey, content);
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
          try {
            AudioPlayer? _player;
            final player = _player = AudioPlayer();
            player.play(AssetSource('audio/receive.wav'));
          } catch (e) {}
        }
      }

      isLoading = false;

      notifyListeners();
    });

    channel.sink.add(jsonEncode(request)); */
  }

  sendMessage(String content, ChatProfile friendProfile) async {
    isLoading = true;
    notifyListeners();

    ChatMessage message = ChatMessage(
        sender: friendProfile.walletAddress,
        content: content,
        type: "Sent",
        created: DateTime.now());

    try {
      AudioPlayer? _player;
      final player = _player = AudioPlayer();
      player.play(AssetSource('audio/pop.mp3'));
    } catch (e) {}
    chatMessages.add(message);

    String abiCode = await rootBundle
        .loadString("contracts/build/contracts/ThunderChatContract.json");

    DeployedContract friendChatContract = DeployedContract(
        ContractAbi.fromJson(abiCode, "ThunderChatContract"),
        friendProfile.chatAddress);

    try {
      await _client.sendTransaction(
          _credentials,
          Transaction.callContract(
            contract: friendChatContract,
            function: _receiveMessage,
            parameters: [encrypt(friendProfile.publicKey, content)],
          ),
          chainId: 421613);

      await _client.sendTransaction(
          _credentials,
          Transaction.callContract(
            contract: _myChatContract,
            function: _sendMessage,
            parameters: [
              friendProfile.walletAddress,
              encrypt(_myPublicKey, content)
            ],
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
  }

  getMyProfile() async {
    _abiCode = await rootBundle
        .loadString("contracts/build/contracts/ThunderProfileContract.json");

    _profileContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "ThunderChatProfile"),
        _profileContractAddress);

    //_addProfile = _profileContract.function("addProfile");
    //_getAllProfiles = _profileContract?.function("getAllProfiles");
    _getProfile = _profileContract.function("getProfile");

    List<dynamic> result = await _client.call(
      contract: _profileContract,
      function: _getProfile,
      params: [_myAddress],
    );

    int createdInt = (result[0][0][6]).toInt();

    _chatProfile = ChatProfile(
        walletAddress: result[0][0][0],
        chatAddress: result[0][0][1],
        name: result[0][0][2],
        description: result[0][0][3],
        pic: result[0][0][4],
        publicKey: result[0][0][5],
        created: DateTime.fromMillisecondsSinceEpoch(createdInt * 1000));

    _myChatAddress = _chatProfile.chatAddress;
  }

  addFriend(String friendAddress) async {
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _myChatContract,
          function: _addToFriendlist,
          parameters: [EthereumAddress.fromHex(friendAddress)],
        ),
        chainId: 421613);
  }

  getFriendList() async {
    List<dynamic> result = await _client.call(
      contract: _myChatContract,
      function: _getAllFriends,
      params: [],
    );

    for (var msg in result[0]) {
      await getFriendProfile(msg[0]);
      friendList.add(_friendProfile);
    }

    notifyListeners();
  }

  getFriendProfile(EthereumAddress friend) async {
    String abiCode = await rootBundle
        .loadString("contracts/build/contracts/ThunderProfileContract.json");
    String lastMessage;

    DeployedContract profileContract = DeployedContract(
        ContractAbi.fromJson(abiCode, "ThunderChatProfile"),
        _profileContractAddress);

    ContractFunction getProfile = profileContract.function("getProfile");

    List<dynamic> result = await _client.call(
      contract: profileContract,
      function: getProfile,
      params: [friend],
    );

    int createdInt = (result[0][0][6]).toInt();

    List<dynamic> resultLastMessage = await _client.call(
      contract: _myChatContract,
      function: _getMessages,
      params: [result[0][0][0]],
    );

    if (resultLastMessage[0][0] != null) {
      List a = resultLastMessage[0];
      lastMessage =
          decrypt(_myPrivateKey, resultLastMessage[0][a.length - 1][2]);
    } else {
      lastMessage = "";
    }

    _friendProfile = ChatProfile(
      walletAddress: result[0][0][0],
      chatAddress: result[0][0][1],
      name: result[0][0][2],
      description: result[0][0][3],
      pic: result[0][0][4],
      publicKey: result[0][0][5],
      created: DateTime.fromMillisecondsSinceEpoch(createdInt * 1000),
      lastMessage: lastMessage,
    );
  }
}



 /* createChatApp() async {
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey') ?? '0';
    final client = Web3Client(_rpcUrl, Client());
    final credential = EthPrivateKey.fromHex(privateKey);

    var list = utf8.encode(TestContract.byteCode);
    Uint8List payload = Uint8List.fromList(list);
    final Transaction transaction = Transaction(
        to: null, from: credential.address, data: payload, maxGas: 3000000);
    final String transactionId =
        await client.sendTransaction(credential, transaction, chainId: 421613);

    debugPrint("Transaction ID: " + transactionId);
  } */

/* 
class TestContract {
  static final deployedAddress =
      EthereumAddress.fromHex("0x5D683bFf4B5830cC74c87622574d2FA12C41aeAc");
  static const contractAbi =
      '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":false,"internalType":"address","name":"addr","type":"address"},{"indexed":false,"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"NewFriend","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"uint256","name":"timestamp","type":"uint256"},{"indexed":false,"internalType":"string","name":"message","type":"string"}],"name":"NewMessage","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"addr","type":"address"},{"indexed":false,"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"RemoveFriend","type":"event"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"addr","type":"address"}],"name":"addToFriendlist","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getAllFriends","outputs":[{"components":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"friendAddress","type":"address"},{"internalType":"uint256","name":"timestamp","type":"uint256"}],"internalType":"struct ThunderChatContract.Friend[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"}],"name":"getMessages","outputs":[{"components":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"string","name":"content","type":"string"},{"internalType":"uint256","name":"timestamp","type":"uint256"}],"internalType":"struct ThunderChatContract.Message[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"}],"name":"isSenderAllowed","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"addr","type":"address"}],"name":"removeFromFriendlist","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"_content","type":"string"}],"name":"sendMessage","outputs":[],"stateMutability":"nonpayable","type":"function"}]';
  static const byteCode =
      "0x608060405234801561001057600080fd5b50336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506119b5806100606000396000f3fe608060405234801561001057600080fd5b50600436106100625760003560e01c80634647672614610067578063469c81101461008357806366e2ca541461009f5780637d8ffca0146100bd578063b2f71322146100d9578063efc7840114610109575b600080fd5b610081600480360381019061007c9190610e5b565b610139565b005b61009d60048036038101906100989190610eed565b6103ec565b005b6100a76105d7565b6040516100b49190611104565b60405180910390f35b6100d760048036038101906100d29190611126565b610728565b005b6100f360048036038101906100ee9190610e5b565b6109e6565b6040516101009190611298565b60405180910390f35b610123600480360381019061011e9190610e5b565b610d09565b60405161013091906112d5565b60405180910390f35b60008054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146101c7576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016101be90611373565b60405180910390fd5b600360008273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff16610253576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161024a906113df565b60405180910390fd5b6000600360008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff02191690831515021790555060005b6002805490508110156103e8578173ffffffffffffffffffffffffffffffffffffffff16600282815481106102e6576102e56113ff565b5b906000526020600020906003020160010160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16036103d55760028181548110610347576103466113ff565b5b9060005260206000209060030201600080820160006103669190610d5f565b6001820160006101000a81549073ffffffffffffffffffffffffffffffffffffffff0219169055600282016000905550507fbe19c30302b65c2a25617069194520c08ce342e839e69418eba502290cad7d6f82426040516103c892919061144c565b60405180910390a16103e8565b80806103e0906114a4565b9150506102ae565b5050565b600360003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff16610478576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161046f90611538565b60405180910390fd5b600160405180606001604052803373ffffffffffffffffffffffffffffffffffffffff16815260200184848080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050815260200142815250908060018154018082558091505060019003906000526020600020906003020160009091909190915060008201518160000160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555060208201518160010190816105749190611793565b506040820151816002015550503373ffffffffffffffffffffffffffffffffffffffff167f0ff94fec3112de81726d79117e091c7c9d47da8a38c73e8cec7ee350a61898a64284846040516105cb939291906118a1565b60405180910390a25050565b60606002805480602002602001604051908101604052809291908181526020016000905b8282101561071f578382906000526020600020906003020160405180606001604052908160008201805461062e906115b6565b80601f016020809104026020016040519081016040528092919081815260200182805461065a906115b6565b80156106a75780601f1061067c576101008083540402835291602001916106a7565b820191906000526020600020905b81548152906001019060200180831161068a57829003601f168201915b505050505081526020016001820160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001600282015481525050815260200190600101906105fb565b50505050905090565b60008054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146107b6576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016107ad90611373565b60405180910390fd5b600360008273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff1615610843576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161083a9061191f565b60405180910390fd5b6001600360008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff0219169083151502179055506002604051806060016040528085858080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505081526020018373ffffffffffffffffffffffffffffffffffffffff16815260200142815250908060018154018082558091505060019003906000526020600020906003020160009091909190915060008201518160000190816109509190611793565b5060208201518160010160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506040820151816002015550507fb45a2f74a904403ae54825131c5e2b3281e8b8032af0e68ac10b50e19a4e8a85838383426040516109d9949392919061193f565b60405180910390a1505050565b60606000805b600180549050811015610a93578373ffffffffffffffffffffffffffffffffffffffff1660018281548110610a2457610a236113ff565b5b906000526020600020906003020160000160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1603610a80578180610a7c906114a4565b9250505b8080610a8b906114a4565b9150506109ec565b5060008167ffffffffffffffff811115610ab057610aaf611558565b5b604051908082528060200260200182016040528015610ae957816020015b610ad6610d9f565b815260200190600190039081610ace5790505b5090506000805b600180549050811015610cfd578573ffffffffffffffffffffffffffffffffffffffff1660018281548110610b2857610b276113ff565b5b906000526020600020906003020160000160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1603610cea57604051806060016040528060018381548110610b9457610b936113ff565b5b906000526020600020906003020160000160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200160018381548110610bf557610bf46113ff565b5b90600052602060002090600302016001018054610c11906115b6565b80601f0160208091040260200160405190810160405280929190818152602001828054610c3d906115b6565b8015610c8a5780601f10610c5f57610100808354040283529160200191610c8a565b820191906000526020600020905b815481529060010190602001808311610c6d57829003601f168201915b5050505050815260200160018381548110610ca857610ca76113ff565b5b906000526020600020906003020160020154815250838381518110610cd057610ccf6113ff565b5b60200260200101819052508180610ce6906114a4565b9250505b8080610cf5906114a4565b915050610af0565b50819350505050919050565b6000600360008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff169050919050565b508054610d6b906115b6565b6000825580601f10610d7d5750610d9c565b601f016020900490600052602060002090810190610d9b9190610dd6565b5b50565b6040518060600160405280600073ffffffffffffffffffffffffffffffffffffffff16815260200160608152602001600081525090565b5b80821115610def576000816000905550600101610dd7565b5090565b600080fd5b600080fd5b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b6000610e2882610dfd565b9050919050565b610e3881610e1d565b8114610e4357600080fd5b50565b600081359050610e5581610e2f565b92915050565b600060208284031215610e7157610e70610df3565b5b6000610e7f84828501610e46565b91505092915050565b600080fd5b600080fd5b600080fd5b60008083601f840112610ead57610eac610e88565b5b8235905067ffffffffffffffff811115610eca57610ec9610e8d565b5b602083019150836001820283011115610ee657610ee5610e92565b5b9250929050565b60008060208385031215610f0457610f03610df3565b5b600083013567ffffffffffffffff811115610f2257610f21610df8565b5b610f2e85828601610e97565b92509250509250929050565b600081519050919050565b600082825260208201905092915050565b6000819050602082019050919050565b600081519050919050565b600082825260208201905092915050565b60005b83811015610fa0578082015181840152602081019050610f85565b60008484015250505050565b6000601f19601f8301169050919050565b6000610fc882610f66565b610fd28185610f71565b9350610fe2818560208601610f82565b610feb81610fac565b840191505092915050565b610fff81610e1d565b82525050565b6000819050919050565b61101881611005565b82525050565b6000606083016000830151848203600086015261103b8282610fbd565b91505060208301516110506020860182610ff6565b506040830151611063604086018261100f565b508091505092915050565b600061107a838361101e565b905092915050565b6000602082019050919050565b600061109a82610f3a565b6110a48185610f45565b9350836020820285016110b685610f56565b8060005b858110156110f257848403895281516110d3858261106e565b94506110de83611082565b925060208a019950506001810190506110ba565b50829750879550505050505092915050565b6000602082019050818103600083015261111e818461108f565b905092915050565b60008060006040848603121561113f5761113e610df3565b5b600084013567ffffffffffffffff81111561115d5761115c610df8565b5b61116986828701610e97565b9350935050602061117c86828701610e46565b9150509250925092565b600081519050919050565b600082825260208201905092915050565b6000819050602082019050919050565b60006060830160008301516111ca6000860182610ff6565b50602083015184820360208601526111e28282610fbd565b91505060408301516111f7604086018261100f565b508091505092915050565b600061120e83836111b2565b905092915050565b6000602082019050919050565b600061122e82611186565b6112388185611191565b93508360208202850161124a856111a2565b8060005b8581101561128657848403895281516112678582611202565b945061127283611216565b925060208a0199505060018101905061124e565b50829750879550505050505092915050565b600060208201905081810360008301526112b28184611223565b905092915050565b60008115159050919050565b6112cf816112ba565b82525050565b60006020820190506112ea60008301846112c6565b92915050565b600082825260208201905092915050565b7f4f6e6c792074686520636f6e7472616374206f776e65722063616e2063616c6c60008201527f20746869732066756e6374696f6e2e0000000000000000000000000000000000602082015250565b600061135d602f836112f0565b915061136882611301565b604082019050919050565b6000602082019050818103600083015261138c81611350565b9050919050565b7f41646472657373206973206e6f7420616c6c6f7765642e000000000000000000600082015250565b60006113c96017836112f0565b91506113d482611393565b602082019050919050565b600060208201905081810360008301526113f8816113bc565b9050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b61143781610e1d565b82525050565b61144681611005565b82525050565b6000604082019050611461600083018561142e565b61146e602083018461143d565b9392505050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b60006114af82611005565b91507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff82036114e1576114e0611475565b5b600182019050919050565b7f53656e646572206e6f7420616c6c6f7765642e00000000000000000000000000600082015250565b60006115226013836112f0565b915061152d826114ec565b602082019050919050565b6000602082019050818103600083015261155181611515565b9050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b600060028204905060018216806115ce57607f821691505b6020821081036115e1576115e0611587565b5b50919050565b60008190508160005260206000209050919050565b60006020601f8301049050919050565b600082821b905092915050565b6000600883026116497fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8261160c565b611653868361160c565b95508019841693508086168417925050509392505050565b6000819050919050565b600061169061168b61168684611005565b61166b565b611005565b9050919050565b6000819050919050565b6116aa83611675565b6116be6116b682611697565b848454611619565b825550505050565b600090565b6116d36116c6565b6116de8184846116a1565b505050565b5b81811015611702576116f76000826116cb565b6001810190506116e4565b5050565b601f82111561174757611718816115e7565b611721846115fc565b81016020851015611730578190505b61174461173c856115fc565b8301826116e3565b50505b505050565b600082821c905092915050565b600061176a6000198460080261174c565b1980831691505092915050565b60006117838383611759565b9150826002028217905092915050565b61179c82610f66565b67ffffffffffffffff8111156117b5576117b4611558565b5b6117bf82546115b6565b6117ca828285611706565b600060209050601f8311600181146117fd57600084156117eb578287015190505b6117f58582611777565b86555061185d565b601f19841661180b866115e7565b60005b828110156118335784890151825560018201915060208501945060208101905061180e565b86831015611850578489015161184c601f891682611759565b8355505b6001600288020188555050505b505050505050565b82818337600083830152505050565b600061188083856112f0565b935061188d838584611865565b61189683610fac565b840190509392505050565b60006040820190506118b6600083018661143d565b81810360208301526118c9818486611874565b9050949350505050565b7f4164647265737320697320616c726561647920616c6c6f7765642e0000000000600082015250565b6000611909601b836112f0565b9150611914826118d3565b602082019050919050565b60006020820190508181036000830152611938816118fc565b9050919050565b6000606082019050818103600083015261195a818688611874565b9050611969602083018561142e565b611976604083018461143d565b9594505050505056fea2646970667358221220fa1a8ca4b752203fadafb0e5ee856214899c45e26233dc9ea6a146fb8e606bb564736f6c63430008120033";
}
 */