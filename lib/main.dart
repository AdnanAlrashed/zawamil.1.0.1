import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_notifier.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');

    // تنظيف البيانات القديمة تلقائياً
    await _cleanOldDataOnStartup();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // تهيئة خدمة الإشعارات
  await NotificationService.initialize();

  // تهيئة FCM وطلب الصلاحيات
  await _initFCM();

  // اشتراك جميع المستخدمين في topic عام
  await FirebaseMessaging.instance.subscribeToTopic('all_users');

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(isDarkMode),
      child: MyApp(),
    ),
  );
}

Future<void> _initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  String? token = await messaging.getToken();
  print('FCM Token: ' +
      (token ?? '')); // يمكنك حفظ التوكن في Firestore لاحقاً إذا أردت
}

Future<void> _cleanOldDataOnStartup() async {
  try {
    print('Cleaning old data on startup...');
    await FirestoreService.updateOldAudioPaths();
    print('Old data cleanup completed');
  } catch (e) {
    print('Error cleaning old data on startup: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Zwamil',
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
