import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Should be overridden in ProviderScope
});

class AppSettings {
  final String appLanguage; // UI Language (es, en)
  final String contentLanguage; // Preferred Audio (es-419, es-ES, en)
  final bool autoSubtitles;
  final String? preferredQuality;
  AppSettings({
    required this.appLanguage,
    required this.contentLanguage,
    required this.autoSubtitles,
    this.preferredQuality,
  });

  AppSettings copyWith({
    String? appLanguage,
    String? contentLanguage,
    bool? autoSubtitles,
    String? preferredQuality,
  }) {
    return AppSettings(
      appLanguage: appLanguage ?? this.appLanguage,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      autoSubtitles: autoSubtitles ?? this.autoSubtitles,
      preferredQuality: preferredQuality ?? this.preferredQuality,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  AppSettingsNotifier(this._prefs)
      : super(AppSettings(
          appLanguage: _prefs.getString('app_language') ?? 'es',
          contentLanguage: _prefs.getString('content_language') ?? 'es-419',
          autoSubtitles: _prefs.getBool('auto_subtitles') ?? true,
          preferredQuality: _prefs.getString('preferred_quality'),
        ));

  void setAppLanguage(String lang) {
    state = state.copyWith(appLanguage: lang);
    _prefs.setString('app_language', lang);
  }

  void setContentLanguage(String lang) {
    state = state.copyWith(contentLanguage: lang);
    _prefs.setString('content_language', lang);
  }

  void setAutoSubtitles(bool enabled) {
    state = state.copyWith(autoSubtitles: enabled);
    _prefs.setBool('auto_subtitles', enabled);
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppSettingsNotifier(prefs);
});
