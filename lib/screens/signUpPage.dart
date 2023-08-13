import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:ethers/signers/wallet.dart' as w;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder_chat/controllers/message_controller.dart';
import 'package:thunder_chat/models/chatProfileModel.dart';
import 'package:thunder_chat/screens/homePage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:thunder_chat/appconfig.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:web_socket_channel/io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thunder_chat/helpers/web3Helper.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpPage> {
  final config = AppConfig();
  late TextEditingController emailCtrl;
  late ChatMessageController chatMessageController;
  var email;
  Future<ChatProfile>? _futureChatProfile;

  String _futurePrivateKey = "";

  late ChatProfileController chatProfileController;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController(text: "");
    initPlatformState();
  }

  handleEmailLogin() async {
    email = emailCtrl.text;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final themeMap = HashMap<String, String>();
    themeMap['primary'] = "#229954";

    Uri redirectUrl;

    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('w3a://com.example.thunder_chat/auth');
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('com.example.thunder_chat://openlogin');
    } else {
      throw UnKnownException('Unknown platform');
    }

    await Web3AuthFlutter.init(Web3AuthOptions(
        clientId: config.web3AuthClientID,
        network: Network.testnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(
            dark: false, name: "Thunder Chat", theme: themeMap)));
  }

  @override
  Widget build(BuildContext context) {
    chatProfileController = p.Provider.of<ChatProfileController>(context);
    chatMessageController = p.Provider.of<ChatMessageController>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child:
              (_futurePrivateKey == "") ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  FutureBuilder<ChatProfile> buildFutureBuilder() {
    return FutureBuilder<ChatProfile>(
      future: _futureChatProfile,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              SizedBox(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 18.0,
                    //fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  child: Column(
                    children: <Widget>[
                      AnimatedTextKit(
                        isRepeatingAnimation: false,
                        repeatForever: false,
                        totalRepeatCount: 1,
                        onFinished: () => Navigator.of(context).push(
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, anotherAnimation) {
                                  return HomePage();
                                },
                                transitionDuration:
                                    Duration(milliseconds: 1000),
                                transitionsBuilder: (context, animation,
                                    anotherAnimation, child) {
                                  animation = CurvedAnimation(
                                      curve: Curves.easeIn, parent: animation);
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                })),
                        animatedTexts: [
                          FadeAnimatedText(
                            'Welcome',
                            duration: Duration(seconds: 3),
                            fadeOutBegin: 0.9,
                            fadeInEnd: 0.7,
                          ),
                          FadeAnimatedText('${snapshot.data!.name}',
                              duration: Duration(seconds: 3),
                              fadeOutBegin: 0.9,
                              fadeInEnd: 0.7),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return SizedBox(
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 18.0,
              //fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            child: Center(
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  FadeAnimatedText('Please wait.',
                      duration: Duration(seconds: 2),
                      fadeOutBegin: 0.9,
                      fadeInEnd: 0.7),
                  FadeAnimatedText('While we are getting your account.',
                      duration: Duration(seconds: 2),
                      fadeOutBegin: 0.9,
                      fadeInEnd: 0.7),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Column buildColumn() {
    return Column(
      children: [
        Image.asset(
          'assets\\thunder_logo.png',
          height: 100,
        ),
        const SizedBox(height: 50),
        const Text(
          'Let\'s get started',
          style: TextStyle(
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'CONTINUE WITH',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Handle Google login button click
                  if (kDebugMode) {
                    print("In google.");
                  }
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
                  height: 50,
                ),
              ),
              const SizedBox(width: 20.0),
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
                  height: 50,
                ),
              ),
            ],
          ),
        ),
        const Text(
          '\n------------- or -------------\n',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          child: TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Email',
            ),
          ),
        ),
        TextButton(
          style: flatButtonStyle,
          onPressed: () {
            if (kDebugMode) {
              print("In passwordless email.");
            }
            Fluttertoast.showToast(
                msg: "Login with email",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black12,
                textColor: Colors.white,
                fontSize: 16.0);
            _login(_withEmailPasswordless);
          },
          child: const Text(
            'Log in with Email',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black87,
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  Future<void> _login(Future<Web3AuthResponse> Function() method) async {
    try {
      final Web3AuthResponse response = await method();
      debugPrint(response.toJson().toString());

      final prefs = await SharedPreferences.getInstance();
      String privateKey = response.privKey.toString();

      await prefs.setString('thunderPrivateKey', privateKey);

      String? email = response.userInfo!.email;
      setState(() {
        _futurePrivateKey = privateKey;
      });

      await _setUp(privateKey, email, getEmailUserId(email!),
          "I am using Thunder!", response.userInfo!.profileImage);
      await prefs.setString('thunderPrivateKey', privateKey);
    } on UserCancelledException {
      if (kDebugMode) {
        print("User cancelled.");
      }
    } on UnKnownException {
      if (kDebugMode) {
        print("Unknown exception occurred");
      }
    }
  }

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
        extraLoginOptions: ExtraLoginOptions(login_hint: emailCtrl.text)));
  }

  _setUp(String privateKey, String? userId, String name, String description,
      String? photoURL) async {
    final client = Web3Client(config.rpcUrl, http.Client());
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;
    //final publicKey = credentials.publicKey;
    //final balance = await client.getBalance(address);
    final walletPrivateKey = w.Wallet.fromPrivateKey(privateKey);
    final directory = await getApplicationDocumentsDirectory();
    final fileProfile = File('${directory.path}/myProfile.json');
    final fileChat = File('${directory.path}/chatMessage.json');
    final fileLastRead = File('${directory.path}/lastRead.json');

    String publicKey;
    String referredBy = "";

    final _publicKey = walletPrivateKey.signingKey?.publicKey;
    if (_publicKey != null) {
      publicKey = _publicKey.substring(2);
    } else {
      publicKey = "";
    }

    debugPrint("Wallet Address: $address");
    debugPrint("Wallet Public Key: $publicKey");
    debugPrint("Wallet Private Key: $privateKey");
    //debugPrint("Wallet Balance: $balance");
    debugPrint("email: $userId");
    debugPrint("description: $description");
    debugPrint("photoURL: $photoURL");

    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("fcmToken: $fcmToken");

    bool userIdExists = await chatProfileController.checkUserIdExits(userId!);

    if (!(await fileProfile.exists())) {
      // Create the file if it doesn't exist
      await fileProfile.create();
    }

    if (!(await fileChat.exists())) {
      // Create the file if it doesn't exist
      await fileChat.create();
    }

    if (!(await fileLastRead.exists())) {
      // Create the file if it doesn't exist
      await fileLastRead.create();
    }

    if (userIdExists) {
      await chatMessageController.getAllChatMessages(address);
      _futureChatProfile = chatProfileController.getProfileWithFriendList(
          address, chatMessageController);

      setState(() {
        _futurePrivateKey = privateKey;

        final myProfileJson =
            jsonEncode(chatProfileController.myProfile.toJson());
        final chatMessagesJson =
            jsonEncode(chatMessageController.messagesToJson());
        final lastReadJson = jsonEncode(chatProfileController.lastReadToJson());

        fileProfile.writeAsString(myProfileJson);
        fileChat.writeAsString(chatMessagesJson);
        fileLastRead.writeAsString(lastReadJson);
      });
    } else {
      debugPrint("Profile not found!");

      await chatProfileController.createProfile(userId!, name, photoURL!,
          publicKey, address.toString(), referredBy, privateKey, fcmToken!);

      //userIdExists = false;
      // while (!userIdExists) {
      //   await Future.delayed(
      //       const Duration(milliseconds: 1000)); // Add a delay before retrying
      //   userNameExists = await chatProfileController.checkUserNameExits(userId);
      // }
      chatMessageController.getAllChatMessages(address);
      _futureChatProfile = chatProfileController.getProfileWithFriendList(
          address, chatMessageController);

      setState(() {
        _futurePrivateKey = privateKey;

        final myProfileJson =
            jsonEncode(chatProfileController.myProfile.toJson());
        final chatMessagesJson =
            jsonEncode(chatMessageController.messagesToJson());
        final lastReadJson = jsonEncode(chatProfileController.lastReadToJson());

        debugPrint("myProfileJson: $myProfileJson");
        fileProfile.writeAsString(myProfileJson);
        fileChat.writeAsString(chatMessagesJson);
        fileLastRead.writeAsString(lastReadJson);
      });
    }

    chatMessageController.startListener(chatProfileController);
  }

  String getEmailUserId(String email) {
    // Split the email address by the '@' symbol
    List<String> emailParts = email.split('@');

    // Return the first part (user ID) of the split email address
    return emailParts[0];
  }
}
