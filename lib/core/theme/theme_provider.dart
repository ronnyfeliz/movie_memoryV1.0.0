import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system }

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme.dark);

  static const _key = 'app_theme';

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key) ?? 'dark';
    state = AppTheme.values.firstWhere(
      (t) => t.name == value,
      orElse: () => AppTheme.dark,
    );
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.name);
    state = theme;
  }
}
