import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      await _messaging.requestPermission();
    }
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  Stream<String?> onTokenRefresh() {
    return _messaging.onTokenRefresh;
  }

  Future<void> saveTokenToFirestore(String userId) async {
    final token = await getToken();
    if (token == null || userId.isEmpty) return;
    await _firestore.collection('users').doc(userId).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  Future<void> removeTokenFromFirestore(String userId) async {
    final token = await getToken();
    if (token == null || userId.isEmpty) return;
    await _firestore.collection('users').doc(userId).set({
      'fcmTokens': FieldValue.arrayRemove([token]),
    }, SetOptions(merge: true));
  }

  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final data = message.data;
  final notification = message.notification;
  if (notification == null && data.isEmpty) return;

  final title = notification?.title ?? data['title'] ?? '';
  final body = notification?.body ?? data['body'] ?? '';

  if (title.isEmpty || body.isEmpty) return;

  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
  await plugin.initialize(settings);

  final category = data['category'] ?? 'general';
  final channelId = 'movie_memory_$category';
  final channelName = data['categoryName'] ?? 'MovieMemory';

  const androidDetails = AndroidNotificationDetails(
    'movie_memory_channel',
    'MovieMemory',
    channelDescription: 'MovieMemory notifications',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
  final details = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());
  await plugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    details,
  );
}
