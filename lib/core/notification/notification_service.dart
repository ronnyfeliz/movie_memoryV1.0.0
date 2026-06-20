import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_provider.dart';
import '../../features/notifications/domain/notification_category.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings,
      onDidReceiveNotificationResponse: _onNotificationTap);
    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // handled by FCM or navigation
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    NotificationCategory category = NotificationCategory.seriesUpdate,
    NotificationPreferences? prefs,
  }) async {
    final enabled = prefs?.enabled ?? true;
    if (!enabled) return;

    final catEnabled = prefs?.isCategoryEnabled(category) ?? true;
    if (!catEnabled) return;

    final mode = prefs?.mode ?? NotificationMode.normal;

    if (mode == NotificationMode.normal || mode == NotificationMode.both) {
      final channelId = 'movie_memory_${category.name}';
      final androidDetails = AndroidNotificationDetails(
        channelId,
        category.shortName,
        channelDescription: category.displayName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      final details = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());
      await _plugin.show(id, title, body, details);
    }
  }

  static Future<void> showCategoryNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    final details = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());
    await _plugin.show(id, title, body, details);
  }
}
