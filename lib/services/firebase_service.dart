import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'sos') {
    await NotificationService.showSosNotification(
      senderName: message.data['senderName'] ?? 'Unknown',
      senderId: message.data['senderId'] ?? '0',
    );
  }
}

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    FirebaseMessaging.onMessage.listen(NotificationService.onForegroundMessage);
  }

  static Future<String?> getAndSaveFcmToken(StorageService storage) async {
    await NotificationService.requestPermission();
    final token = await NotificationService.getFcmToken();
    if (token != null) {
      await storage.saveFcmToken(token);
    }
    return token;
  }
}
