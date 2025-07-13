import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
}
