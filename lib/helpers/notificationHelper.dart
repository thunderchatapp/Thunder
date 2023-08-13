import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thunder_chat/appconfig.dart';

class NotificationHelper {
  static final String _serverKey =
      AppConfig().notificationServerId; // Replace with your FCM server key
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  Future<void> sendNotification(
      String toToken, String title, String body) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$_serverKey',
    };

    final Map<String, dynamic> notificationBody = {
      'to': toToken,
      'priority': 'high',
      'notification': {
        'title': title,
        'body': body,
      }
    };

    final http.Response response = await http.post(
      Uri.parse(_fcmUrl),
      headers: headers,
      body: jsonEncode(notificationBody),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
