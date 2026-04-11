import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationHelper {
  // 1. دالة بتجيب التوكن المؤقت من ملف الـ JSON
  static Future<String> getAccessToken() async {
    final jsonString =
        await rootBundle.loadString('assets/service_account.json');
    final accountCredentials = ServiceAccountCredentials.fromJson(jsonString);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final accessToken = client.credentials.accessToken.data;
    client.close();

    return accessToken;
  }

  // 2. دالة إرسال الإشعار
  static Future<void> sendPushMessage({
    required String deviceToken, // توكن الجهاز اللي هتبعتله
    required String title,
    required String body,
  }) async {
    final String serverToken = await getAccessToken();

    final String endpoint =
        "https://fcm.googleapis.com/v1/projects/smart-city-guide-6d83a/messages:send";

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken, // الجهاز الهدف
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          // 'route': 'homepage', // لو عايز تبعت داتا إضافية تستقبلها لما يدوس على الإشعار
          "name": "Taha",
          "id": "12331222"
        }
      }
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken', // هنا بنستخدم التوكن الجديد
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("✅ الإشعار اتبعت بنجاح يا كينج!");
      } else {
        print("❌ حصل خطأ: ${response.body}");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }
}
