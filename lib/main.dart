import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder_chat/controllers/profile_controller.dart';
import 'package:thunder_chat/helpers/crypto.dart';
import 'package:thunder_chat/models/chatMessage.dart';
import 'package:thunder_chat/models/chatProfileModel.dart';
import 'package:thunder_chat/screens/onBoardingPage.dart';
import 'package:thunder_chat/screens/profile/profilePage.dart';
import 'package:thunder_chat/screens/homePage.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:thunder_chat/controllers/message_controller.dart';
import 'package:thunder_chat/helpers/web3Helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:uni_links/uni_links.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('A bg message just showed up: ${message.messageId}');

  // final prefs = await SharedPreferences.getInstance();
  // final String? privateKey = prefs.getString('thunderPrivateKey');
  // print('privateKey: $privateKey');
  // print('message: ' + message.notification!.body.toString());
  // String encryptedContent = message.notification!.body.toString();
  // String decryptedContent = decrypt(privateKey, encryptedContent);
  // print('Decrypted content: $decryptedContent');

  // message.data['content'] = decryptedContent;

  // int pendingMessagesCount =
  //     5; // Replace this with the actual pending messages count
  // FlutterDynamicIcon.setApplicationIconBadgeNumber(5);

  // i want to decrypt the content of the incoming message decrypt(privateKey, content)

  await Firebase.initializeApp();
}

StreamSubscription<String>? subscription;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MainApp());
  handleDeepLink();
}

String? referralCode = "";
void handleDeepLink() async {
  // Init UniLinks
  try {
    String? initialLink = await getInitialLink();
    // Check if the app was opened with a deep link (referral link)
    if (initialLink != null) {
      Uri uri = Uri.parse(initialLink);
      // Extract the referral code from the deep link
      referralCode = uri.queryParameters['referrer'];
      // Store the referral code locally or process it as needed
      print('Referral Code: $referralCode');
    }
  } on Exception catch (e) {
    print('Error handling deep link: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Web3Helper web3Helper = Web3Helper();

    return FutureBuilder<void>(
      future: web3Helper.init(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white, // Set the background color to orange
            // child: Center(
            //   child: CircularProgressIndicator(),
            // ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ChatProfileController(web3Helper),
              ),
              ChangeNotifierProvider(
                create: (_) => ChatMessageController(web3Helper),
              ),
            ],
            child: MaterialApp(
              title: 'Thunder Chat',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              debugShowCheckedModeBanner: false,
              home: Builder(builder: (context) => const CheckLogin()),
              routes: <String, WidgetBuilder>{
                "profile": (BuildContext context) => ProfilePage(),
              },
            ),
          );
        }
      },
    );
  }
}

class CheckLogin extends StatefulWidget {
  const CheckLogin({super.key});

  @override
  _CheckLoginState createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  bool loading = true;
  bool loggedIn = false;
  late ChatProfileController chatProfileController;
  late ChatMessageController chatMessageController;

  @override
  void initState() {
    super.initState();

    @override
    void dispose() {
      subscription?.cancel();
      super.dispose();
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // final prefs = await SharedPreferences.getInstance();
      // final String? privateKey = prefs.getString('thunderPrivateKey');

      // print('A new onMessageOpenedApp event was published!');
      // RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;
      // if (notification != null && android != null) {
      //   showDialog(
      //       context: context,
      //       builder: (_) {
      //         return AlertDialog(
      //           title: Text(notification.title!),
      //           content: SingleChildScrollView(
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [Text(decrypt(privateKey, notification.body!))],
      //             ),
      //           ),
      //         );
      //       });
      // }
      checkLogin();
    });
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? privateKey = prefs.getString('thunderPrivateKey');

    if (privateKey != null) {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = credentials.address;

      try {
        // Get the app's document directory
        final directory = await getApplicationDocumentsDirectory();
        final fileProfile = File('${directory.path}/myProfile.json');
        final fileChat = File('${directory.path}/chatMessage.json');
        final lastRead = File('${directory.path}/lastRead.json');

        if (fileProfile.existsSync() && fileChat.existsSync()) {
          // If the file exists, read the JSON data and set myProfile
          final cachedProfile = await fileProfile.readAsString();
          final cachedMessage = await fileChat.readAsString();
          final cachedLastRead = await lastRead.readAsString();

          debugPrint("cachedLastRead: $cachedLastRead");
          debugPrint("cachedMessage: $cachedMessage");

          //if (cachedMessage.isNotEmpty) {
          chatMessageController.chatMessages =
              chatMessageController.decodeChatMessages(cachedMessage);
          //}

          // chatProfileController.myProfile =
          //     ChatProfile.fromJson(jsonDecode(cachedProfile));
          if (cachedLastRead != "") {
            chatProfileController.lastReadList =
                chatProfileController.decodeLastRead(cachedLastRead);
          }
          // If the file doesn't exist, call getProfileWithFriendList and save myProfile to the file
          await chatProfileController.getProfileWithFriendList(
            address,
            chatMessageController,
          );

          debugPrint("Profile: ");
          debugPrint(chatProfileController.myProfile.toJson().toString());
          debugPrint("Encrypted test message: ");
          debugPrint(encrypt(
              chatProfileController.myProfile.publicKey, "Hi how are you."));

          setState(() {
            loading = false;
            loggedIn = true;
          });

          await chatMessageController
              .getChatMessagesWhileOffline(chatProfileController);

          final myProfileJson =
              jsonEncode(chatProfileController.myProfile.toJson());
          final chatMessagesJson =
              jsonEncode(chatMessageController.messagesToJson());

          debugPrint("1");
          await fileProfile.writeAsString(myProfileJson);
          await fileChat.writeAsString(chatMessagesJson);
        } else {
          await chatMessageController.getAllChatMessages(address);

          // If the file doesn't exist, call getProfileWithFriendList and save myProfile to the file
          await chatProfileController.getProfileWithFriendList(
            address,
            chatMessageController,
          );

          final myProfileJson =
              jsonEncode(chatProfileController.myProfile.toJson());
          final chatMessagesJson =
              jsonEncode(chatMessageController.messagesToJson());

          await fileProfile.writeAsString(myProfileJson);
          await fileChat.writeAsString(chatMessagesJson);
          setState(() {
            loading = false;
            loggedIn = true;
          });
        }
      } catch (error) {
        debugPrint(error.toString());
        setState(() {
          loading = false;
          loggedIn = false;
        });
      }
    } else {
      if (referralCode != null) {
        await prefs.setString('thunderReferralCode', referralCode!);
      } else {
        await prefs.setString('thunderReferralCode', '');
      }
      setState(() {
        loading = false;
        loggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    chatProfileController = Provider.of<ChatProfileController>(context);
    chatMessageController = Provider.of<ChatMessageController>(context);

    if (loading) {
      return Scaffold(
          body: Center(
        child: CircularProgressIndicator(),
      ));
    } else {
      if (loggedIn) {
        return const HomePage();
      } else {
        return const OnBoardingPage();
      }
    }
  }
}
