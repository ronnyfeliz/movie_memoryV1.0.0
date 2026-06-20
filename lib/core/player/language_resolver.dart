import 'vod_models.dart';

class LanguageResolver {
  /// Resolves which language to pick from a list based on user preference.
  /// userPref should be a BCP47 code (e.g., 'es-MX' or 'en').
  static VodLanguage? resolve(List<VodLanguage> available, String userPref, {String? originalLang}) {
    if (available.isEmpty) return null;

    // 1. Exact BCP47 match (e.g., es-ES == es-ES)
    for (var lang in available) {
      if (lang.bcp47.toLowerCase() == userPref.toLowerCase()) return lang;
    }

    // 2. Base language match (e.g., es-MX matches es-ES or es)
    final basePref = userPref.split('-').first.toLowerCase();
    for (var lang in available) {
      final baseAvail = lang.bcp47.split('-').first.toLowerCase();
      if (baseAvail == basePref) return lang;
    }

    // 3. Fallback to original language if available and preferred over English
    if (originalLang != null) {
      for (var lang in available) {
        if (lang.bcp47.toLowerCase() == originalLang.toLowerCase()) return lang;
      }
    }

    // 4. Fallback to English
    for (var lang in available) {
      if (lang.bcp47.toLowerCase().startsWith('en')) return lang;
    }

    // 5. Just pick the first one marked as original or just the first one
    return available.firstWhere((l) => l.isOriginal, orElse: () => available.first);
  }

  /// Maps common provider names to standard BCP47
  static String normalizeBcp47(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('spanish') || s.contains('español') || s.contains('castellano')) {
      if (s.contains('latino') || s.contains('mx')) return 'es-419';
      return 'es';
    }
    if (s.contains('english') || s.contains('inglés')) return 'en';
    if (s.contains('portuguese') || s.contains('português')) return 'pt';
    if (s.contains('french') || s.contains('français')) return 'fr';
    
    // ISO 639-2 to 639-1
    if (s == 'spa') return 'es';
    if (s == 'eng') return 'en';
    if (s == 'fra') return 'fr';
    if (s == 'deu' || s == 'ger') return 'de';
    
    return s;
  }
}
