import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _sosChannel =
      AndroidNotificationChannel(
    'sos_channel',
    'SOS Alerts',
    description: 'Emergency SOS notifications from RadarFest',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_sosChannel);
  }

  static Future<void> showSosNotification({
    required String senderName,
    required String senderId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sos_channel',
      'SOS Alerts',
      channelDescription: 'Emergency SOS notifications from RadarFest',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'SOS',
      color: Color(0xFFFF0000),
      enableVibration: true,
      playSound: true,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      senderId.hashCode,
      'SOS! $senderName needs help!',
      'Open RadarFest to see their location',
      details,
    );
  }

  static Future<String?> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void onForegroundMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'sos') {
      showSosNotification(
        senderName: data['senderName'] ?? 'Unknown',
        senderId: data['senderId'] ?? '0',
      );
    }
  }
}
