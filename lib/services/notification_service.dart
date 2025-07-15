import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // يمكن إضافة معالجة النقر على الإشعار هنا
        print('تم النقر على الإشعار: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'zawamil_channel',
      'Zwamil Notifications',
      channelDescription: 'إشعارات تطبيق زوامل',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> showNewArtistNotification(String artistName) async {
    await showNotification(
      title: 'فنان جديد! 🎵',
      body: 'تم إضافة الفنان "$artistName" إلى التطبيق',
      payload: 'new_artist',
    );
  }

  static Future<void> showNewSongNotification(
      String songTitle, String artistName) async {
    await showNotification(
      title: 'زامل جديد! 🎶',
      body: 'تم إضافة "$songTitle" للفنان "$artistName"',
      payload: 'new_song',
    );
  }

  /// ترسل إشعارًا إلى جميع المستخدمين المشتركين في topic 'all_users' عبر FCM HTTP API.
  /// يجب وضع Server Key الخاص بك في المتغير serverKey (لا تضعه في تطبيق المستخدمين العاديين).
  static Future<void> sendNotificationToAllUsers({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    final serverKey = 'ضع_هنا_Server_Key_الخاص_بك'; // انسخه من Firebase Console
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final notification = {
      'title': title,
      'body': body,
      if (imageUrl != null) 'image': imageUrl,
    };

    final payload = {
      'to': '/topics/all_users',
      'notification': notification,
      'priority': 'high',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('تم إرسال الإشعار بنجاح');
    } else {
      print('فشل في إرسال الإشعار: \\${response.body}');
    }
  }

  /// ترسل إشعارًا جماعيًا عبر سيرفر Node.js (notificationServer.js) عند إضافة زامل أو فنان جديد.
  /// يجب أن يكون السيرفر شغالاً على جهاز المدير أو سيرفر خاص (انظر notificationServer.js).
  static Future<void> sendNotificationViaServer({
    required String title,
    required String body,
    String serverUrl =
        'http://localhost:3000/send-notification', // عدّل العنوان إذا كان السيرفر على جهاز آخر
  }) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'body': body}),
      );
      if (response.statusCode == 200) {
        print('تم إرسال الإشعار عبر السيرفر بنجاح');
      } else {
        print('فشل في إرسال الإشعار عبر السيرفر: \\${response.body}');
      }
    } catch (e) {
      print('خطأ في الاتصال بسيرفر الإشعارات: $e');
    }
  }
}
