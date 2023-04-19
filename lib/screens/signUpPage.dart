import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:flutter_app/screens/homePage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:flutter_app/controllers/chatMessage_controller.dart';
import 'package:flutter_app/controllers/chatProfile_controller.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_app/models/chatProfileModel.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _result = '';
  bool logoutVisible = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final themeMap = HashMap<String, String>();
    themeMap['primary'] = "#229954";

    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('w3a://com.example.thunder/auth');
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('com.example.thunder://openlogin');
    } else {
      throw UnKnownException('Unknown platform');
    }

    await Web3AuthFlutter.init(Web3AuthOptions(
        clientId: 'XXX-5stw6em84c',
        network: Network.testnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(
            dark: false, name: "Thunder Chat App", theme: themeMap)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Image.asset(
                        'assets\\thunder_logo.png',
                        height: 160,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Let\'s get started',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'CONTINUE WITH',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Handle Google login button click
                              print("In google.");
                              Fluttertoast.showToast(
                                  msg: "Login with google",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black12,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              _login(_withGoogle);
                            },
                            child: SvgPicture.asset(
                              "assets/login-google.svg",
                            ),
                          ),
                          SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () {
                              // Handle Facebook login button click
                              Fluttertoast.showToast(
                                  msg: "Login with facebook",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black12,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              _login(_withFacebook);
                            },
                            child: SvgPicture.asset(
                              "assets/login-facebook.svg",
                            ),
                          ),
                          SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () {
                              // Handle Google login button click
                              print("In google.");
                              Fluttertoast.showToast(
                                  msg: "Login with Twitter",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black12,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              _login(_withGoogle);
                            },
                            child: SvgPicture.asset(
                              "assets/login-twitter.svg",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\n------------- or -------------\n',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    TextButton(
                      style: flatButtonStyle,
                      onPressed: () {},
                      child: Text(
                        'Log in with Email',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black87,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  Future<void> _login(Future<Web3AuthResponse> Function() method) async {
    try {
      final Web3AuthResponse response = await method();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('privateKey', response.privKey.toString());
      await _setUp();
      setState(() {
        _result = response.toString();
        logoutVisible = true;

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomePage();
        }));
      });
    } on UserCancelledException {
      print("User cancelled.");
    } on UnKnownException {
      print("Unknown exception occurred");
    }
  }

  /* VoidCallback _login(Future<Web3AuthResponse> Function() method) {
    return () async {
      try {
        final Web3AuthResponse response = await method();
        setState(() {
          _result = response.toString();
          logoutVisible = true;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  } */

  Future<Web3AuthResponse> _withGoogle() {
    return Web3AuthFlutter.login(LoginParams(
      loginProvider: Provider.google,
      mfaLevel: MFALevel.DEFAULT,
    ));
  }

  Future<Web3AuthResponse> _withFacebook() {
    return Web3AuthFlutter.login(LoginParams(loginProvider: Provider.facebook));
  }

  Future<Web3AuthResponse> _withEmailPasswordless() {
    return Web3AuthFlutter.login(LoginParams(
        loginProvider: Provider.email_passwordless,
        extraLoginOptions:
            ExtraLoginOptions(login_hint: "hello+flutterdemo@tor.us")));
  }

  Future<Web3AuthResponse> _withDiscord() {
    return Web3AuthFlutter.login(LoginParams(loginProvider: Provider.discord));
  }

  Future<EtherAmount> _setUp() async {
    ChatMessageController chatMessageController = ChatMessageController();
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('privateKey') ?? '0';

    final client = Web3Client(ChatMessageController().getRpcUrl(), Client());
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;
    final balance = await client.getBalance(address);

    debugPrint(address.toString());
    debugPrint(privateKey.toString());
    debugPrint(balance.toString());

    BigInt weiValue = balance.getInWei; // 1 ether = 10^18 Wei
    double ethValue = weiValue.toDouble() / BigInt.from(pow(10, 18)).toDouble();

    debugPrint(ethValue.toString()); // output: 1.0

    if (ethValue < 0.1) {
      double topUpValue = 0.05;
      _sendTopupAmount(topUpValue, address);
    }
    ChatProfileController cpc = ChatProfileController();

    ChatProfile? profile = cpc.chatProfile;

    debugPrint(profile.toString());
    if (profile == null) {
      debugPrint("Need to create chat contract and profile");
      chatMessageController.createChatApp();
    }

    return balance;
  }

  _sendTopupAmount(double topUpValue, EthereumAddress toAddress) async {
    String privateKey = "xxx";

    final client = Web3Client(ChatMessageController().getRpcUrl(), Client());
    final credentials = EthPrivateKey.fromHex(privateKey);
    final fromAddress = credentials.address;
    try {
      final receipt = await client.sendTransaction(
          credentials,
          Transaction(
            from: fromAddress,
            to: toAddress,
            // gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 100),
            value: EtherAmount.fromBigInt(EtherUnit.wei,
                BigInt.from((topUpValue * pow(10, 18)).floor())), // 0.005 ETH
          ),
          chainId: 421613);

      debugPrint(receipt);
    } catch (e) {
      _result = e.toString();
    }
  }
}
