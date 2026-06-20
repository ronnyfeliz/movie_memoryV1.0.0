import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es'));

  static const _key = 'app_locale';

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'es';
    state = Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
    state = Locale(languageCode);
  }

  static String languageName(String code) {
    switch (code) {
      case 'es': return 'Español';
      case 'en': return 'English';
      case 'pt': return 'Português';
      case 'it': return 'Italiano';
      case 'fr': return 'Français';
      case 'ru': return 'Русский';
      case 'ko': return '한국어';
      case 'ja': return '日本語';
      case 'zh': return '中文';
      default: return code;
    }
  }
}
