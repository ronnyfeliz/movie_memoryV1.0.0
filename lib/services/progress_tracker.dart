import 'package:shared_preferences/shared_preferences.dart';

class ProgressTracker {
  static const _prefix = 'progress_';

  static String _key(int tmdbId, {int? season, int? episode}) {
    final parts = <String>['$_prefix$tmdbId'];
    if (season != null) parts.add('s$season');
    if (episode != null) parts.add('e$episode');
    return parts.join('_');
  }

  static Future<void> saveProgress(int tmdbId, double progress,
      {int? season, int? episode}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key(tmdbId, season: season, episode: episode), progress.clamp(0.0, 1.0));
  }

  static Future<double> getProgress(int tmdbId,
      {int? season, int? episode}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key(tmdbId, season: season, episode: episode)) ?? 0.0;
  }

  static Future<void> clearProgress(int tmdbId,
      {int? season, int? episode}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(tmdbId, season: season, episode: episode));
  }

  static Future<bool> hasProgress(int tmdbId,
      {int? season, int? episode}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key(tmdbId, season: season, episode: episode));
  }
}
