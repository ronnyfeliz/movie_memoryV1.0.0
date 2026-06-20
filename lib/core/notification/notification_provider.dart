import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/notifications/domain/notification_category.dart';

enum NotificationMode { normal, popup, both }

class NotificationPreferences {
  bool enabled;
  NotificationMode mode;
  Map<NotificationCategory, bool> categoryEnabled;

  NotificationPreferences({
    this.enabled = true,
    this.mode = NotificationMode.normal,
    Map<NotificationCategory, bool>? categoryEnabled,
  }) : categoryEnabled = categoryEnabled ?? {
          NotificationCategory.newEpisode: true,
          NotificationCategory.newSeason: true,
          NotificationCategory.movieRelease: true,
          NotificationCategory.seriesRelease: true,
          NotificationCategory.dailyRecommendation: true,
          NotificationCategory.seriesUpdate: true,
        };

  bool isCategoryEnabled(NotificationCategory category) {
    return enabled && (categoryEnabled[category] ?? true);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    await prefs.setString('notification_mode', mode.name);
    for (final entry in categoryEnabled.entries) {
      await prefs.setBool('notif_category_${entry.key.name}', entry.value);
    }
  }

  static Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = <NotificationCategory, bool>{};
    for (final cat in NotificationCategory.values) {
      categories[cat] = prefs.getBool('notif_category_${cat.name}') ?? true;
    }
    return NotificationPreferences(
      enabled: prefs.getBool('notifications_enabled') ?? true,
      mode: NotificationMode.values.firstWhere(
        (m) => m.name == prefs.getString('notification_mode'),
        orElse: () => NotificationMode.normal,
      ),
      categoryEnabled: categories,
    );
  }
}

final notificationPreferencesProvider = StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});

class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(NotificationPreferences());

  Future<void> load() async {
    state = await NotificationPreferences.load();
  }

  Future<void> setEnabled(bool value) async {
    state = NotificationPreferences(enabled: value, mode: state.mode, categoryEnabled: state.categoryEnabled);
    await state.save();
  }

  Future<void> setMode(NotificationMode mode) async {
    state = NotificationPreferences(enabled: state.enabled, mode: mode, categoryEnabled: state.categoryEnabled);
    await state.save();
  }

  Future<void> setCategoryEnabled(NotificationCategory category, bool value) async {
    final updated = Map<NotificationCategory, bool>.from(state.categoryEnabled);
    updated[category] = value;
    state = NotificationPreferences(enabled: state.enabled, mode: state.mode, categoryEnabled: updated);
    await state.save();
  }
}
