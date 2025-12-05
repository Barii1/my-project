import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'default_channel',
    'General Notifications',
    description: 'Default notification channel for general updates',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // Local notifications init
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(initSettings);

    // Create channel (Android)
    await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);

    // Request permissions (iOS/Android 13+)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Foreground presentation options (iOS/web)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and persist FCM token
    final token = await _messaging.getToken();
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('fcm_token', token);
    }

    // Listen to token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final p = await SharedPreferences.getInstance();
      await p.setString('fcm_token', newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  static Future<void> backgroundHandler(RemoteMessage message) async {
    // No UI here; ensure Firebase is initialized in main if needed.
    // Optionally persist or log background payload.
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;
    final title = notification?.title ?? 'Update';
    final body = notification?.body ?? (message.data.isNotEmpty ? jsonEncode(message.data) : '');

    await _local.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> testLocalNotification({String? title, String? body}) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title ?? 'Test Notification',
      body ?? 'This is a local test notification.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'General Notifications',
          channelDescription: 'Default notification channel for general updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}