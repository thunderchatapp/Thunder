import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:flutter_app/controllers/chatMessage_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:ethers/signers/wallet.dart' as w;
import 'package:flutter_app/models/chatProfileModel.dart';

class ChatProfileController {
  bool isLoading = true;
  ChatProfile? chatProfile;

  late Web3Client _client;
  late String _abiCode;
  late Credentials _credentials;

  late String _myProfilePrivateKey;
  late String _myProfilePublicKey;
  late EthereumAddress _myProfileAddress;
  late DeployedContract _profileContract;
  late EthereumAddress _contractProfileAddress;

  //late ContractFunction _addProfile;
  //late ContractFunction _getAllProfiles;
  late ContractFunction _getProfile;

  ChatProfileController() {
    init();
  }
  init() async {
    _client = Web3Client(ChatMessageController().getRpcUrl(), Client(),
        socketConnector: () {
      return IOWebSocketChannel.connect(ChatMessageController().getWsUrl())
          .cast<String>();
    });
    _contractProfileAddress =
        EthereumAddress.fromHex("0x4CB07C6e11FdA6748D0865cCBd1077ddc0c04DD2");

    await getAbi();
    await getCreadentials();
    await getDeployedProfileContract();
    await getProfile();
  }

  Future<void> getAbi() async {
    _abiCode = await rootBundle
        .loadString("contracts/build/contracts/ThunderProfileContract.json");
    //var jsonAbi = jsonDecode(abiStringFile);
    //_abiCode = jsonEncode(jsonAbi['abi']);
    //_contractAddress =
    //    EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCreadentials() async {
    final prefs = await SharedPreferences.getInstance();
    _myProfilePrivateKey = prefs.getString('privateKey') ?? '0';
    _credentials = EthPrivateKey.fromHex(_myProfilePrivateKey);
    _myProfileAddress = _credentials.address;
    final walletPrivateKey = w.Wallet.fromPrivateKey(_myProfilePrivateKey!);

    final publicKey = walletPrivateKey.signingKey?.publicKey;
    if (publicKey != null) {
      _myProfilePublicKey = publicKey.substring(2);
    } else {
      _myProfilePublicKey = "";
    }
  }

  Future<void> getDeployedProfileContract() async {
    _profileContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "ThunderChatProfile"),
        _contractProfileAddress);

    //_addProfile = _profileContract.function("addProfile");
    //_getAllProfiles = _profileContract?.function("getAllProfiles");
    _getProfile = _profileContract.function("getProfile");

    //await getMessages();
  }

/*
  addProfile(ChatProfile chatProfile) async {
    isLoading = true;

    try {
      await _client.sendTransaction(
          _credentials!,
          Transaction.callContract(
            contract: _profileContract,
            function: _addProfile,
            parameters: [
              chatProfile.chatAddress,
              chatProfile.name,
              chatProfile.description,
              chatProfile.pic,
              chatProfile.publicKey
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
*/
  getProfile() async {
    List<dynamic> result = await _client.call(
      contract: _profileContract,
      function: _getProfile,
      params: [_myProfileAddress],
    );

    if (result == null) {
      chatProfile = null;
    } else {
      if (result[0][0][6].toInt() == 0) {
        chatProfile = null;
      }
      int createdInt = (result[0][0][6]).toInt();

      chatProfile = ChatProfile(
          walletAddress: result[0][0][0],
          chatAddress: result[0][0][1],
          name: result[0][0][2],
          description: result[0][0][3],
          pic: result[0][0][4],
          publicKey: result[0][0][5],
          created: DateTime.fromMillisecondsSinceEpoch(createdInt * 1000));
    }
  }
}
