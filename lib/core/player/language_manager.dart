import 'dart:ui' show PlatformDispatcher;
import 'package:shared_preferences/shared_preferences.dart';

class PlayerLanguage {
  final String code;
  final String label;
  final String bcp47;

  const PlayerLanguage({
    required this.code,
    required this.label,
    required this.bcp47,
  });

  static const es = PlayerLanguage(code: 'ES', label: 'Español', bcp47: 'es');
  static const en = PlayerLanguage(code: 'EN', label: 'English', bcp47: 'en');
  static const original = PlayerLanguage(code: 'ORIGINAL', label: 'Original', bcp47: '');

  static const defaults = [es, en, original];

  static final Map<String, PlayerLanguage> _known = () {
    final languages = <PlayerLanguage>[
      const PlayerLanguage(code: 'ES', label: 'Español (Castellano)', bcp47: 'es'),
      const PlayerLanguage(code: 'ES-MX', label: 'Español (Latino)', bcp47: 'es-MX'),
      const PlayerLanguage(code: 'EN', label: 'English', bcp47: 'en'),
      const PlayerLanguage(code: 'EN-US', label: 'English (US)', bcp47: 'en-US'),
      const PlayerLanguage(code: 'EN-GB', label: 'English (UK)', bcp47: 'en-GB'),
      const PlayerLanguage(code: 'FR', label: 'Français', bcp47: 'fr'),
      const PlayerLanguage(code: 'DE', label: 'Deutsch', bcp47: 'de'),
      const PlayerLanguage(code: 'IT', label: 'Italiano', bcp47: 'it'),
      const PlayerLanguage(code: 'PT', label: 'Português', bcp47: 'pt'),
      const PlayerLanguage(code: 'PT-BR', label: 'Português (Brasil)', bcp47: 'pt-BR'),
      const PlayerLanguage(code: 'RU', label: 'Русский', bcp47: 'ru'),
      const PlayerLanguage(code: 'JA', label: '日本語', bcp47: 'ja'),
      const PlayerLanguage(code: 'KO', label: '한국어', bcp47: 'ko'),
      const PlayerLanguage(code: 'ZH', label: '中文', bcp47: 'zh'),
      const PlayerLanguage(code: 'AR', label: 'العربية', bcp47: 'ar'),
      const PlayerLanguage(code: 'HI', label: 'हिन्दी', bcp47: 'hi'),
      const PlayerLanguage(code: 'TR', label: 'Türkçe', bcp47: 'tr'),
      const PlayerLanguage(code: 'NL', label: 'Nederlands', bcp47: 'nl'),
      const PlayerLanguage(code: 'PL', label: 'Polski', bcp47: 'pl'),
      const PlayerLanguage(code: 'SV', label: 'Svenska', bcp47: 'sv'),
      const PlayerLanguage(code: 'DA', label: 'Dansk', bcp47: 'da'),
      const PlayerLanguage(code: 'FI', label: 'Suomi', bcp47: 'fi'),
      const PlayerLanguage(code: 'NB', label: 'Norsk', bcp47: 'nb'),
      const PlayerLanguage(code: 'TH', label: 'ไทย', bcp47: 'th'),
      const PlayerLanguage(code: 'VI', label: 'Tiếng Việt', bcp47: 'vi'),
      const PlayerLanguage(code: 'ORIGINAL', label: 'Original', bcp47: ''),
    ];
    final sorted = List<PlayerLanguage>.from(languages)
      ..sort((a, b) => a.label.compareTo(b.label));
    return {for (final l in sorted) l.code: l};
  }();

  static List<PlayerLanguage> get known => _known.values.toList();

  static PlayerLanguage fromCode(String code) {
    return _known[code] ??
        PlayerLanguage(code: code, label: code, bcp47: code.toLowerCase());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PlayerLanguage && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class LanguageManager {
  static const _prefKey = 'player_lang';
  static const _explicitKey = 'player_lang_explicit';
  static const _defaultLang = 'ES';

  static Future<PlayerLanguage> getCurrentLang() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey) ?? _defaultLang;
    return PlayerLanguage.fromCode(code);
  }

  static Future<bool> hasExplicitLangChoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_explicitKey) ?? false;
  }

  static Future<String?> getUILocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_locale');
  }

  static Future<void> setLang(PlayerLanguage lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, lang.code);
    await prefs.setBool(_explicitKey, true);
  }

  static Future<Map<String, String>> resolvePlaybackLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final audioOption = prefs.getString('pref_default_audio_lang') ?? 'user';
    final subtitleOption = prefs.getString('pref_default_subtitle_lang') ?? 'user';

    String resolvedAudio;
    if (audioOption == 'user') {
      final uiLoc = prefs.getString('app_locale') ?? 'es';
      resolvedAudio = uiLoc.toLowerCase().split('_').first;
    } else if (audioOption == 'system') {
      final sysLoc = PlatformDispatcher.instance.locale.languageCode;
      resolvedAudio = sysLoc.toLowerCase().split('_').first;
    } else {
      resolvedAudio = audioOption; // 'es', 'en', 'original'
    }

    String resolvedSubtitle;
    if (subtitleOption == 'user') {
      final uiLoc = prefs.getString('app_locale') ?? 'es';
      resolvedSubtitle = uiLoc.toLowerCase().split('_').first;
    } else if (subtitleOption == 'system') {
      final sysLoc = PlatformDispatcher.instance.locale.languageCode;
      resolvedSubtitle = sysLoc.toLowerCase().split('_').first;
    } else {
      resolvedSubtitle = subtitleOption; // 'es', 'en', 'original', 'disabled'
    }

    return {
      'audio': resolvedAudio,
      'subtitle': resolvedSubtitle,
    };
  }

  static List<PlayerLanguage> get fallbackChain => const [
    PlayerLanguage(code: 'ES', label: 'Español', bcp47: 'es'),
    PlayerLanguage(code: 'ES-MX', label: 'Español (Latino)', bcp47: 'es-MX'),
    PlayerLanguage(code: 'EN', label: 'English', bcp47: 'en'),
  ];

  static List<String> searchNames(String code) {
    final lang = PlayerLanguage.fromCode(code);
    final names = <String>[
      lang.bcp47,
      lang.code.toLowerCase(),
      lang.label.toLowerCase(),
    ];
    if (code == 'ES') {
      names.addAll(['espanol', 'spanish', 'castellano', 'latino', 'spa']);
    } else if (code == 'EN') {
      names.addAll(['english', 'ingles', 'inglés', 'eng']);
    } else if (code == 'FR') {
      names.addAll(['francais', 'french', 'fra']);
    } else if (code == 'DE') {
      names.addAll(['german', 'deu']);
    } else if (code == 'PT' || code == 'PT-BR') {
      names.addAll(['portuguese', 'português', 'por']);
    } else if (code == 'JA') {
      names.addAll(['japanese', 'jpn']);
    } else if (code == 'KO') {
      names.addAll(['korean', 'kor']);
    } else if (code == 'ZH') {
      names.addAll(['chinese', 'mandarin', 'zho']);
    } else if (code == 'RU') {
      names.addAll(['russian', 'rus']);
    } else if (code == 'IT') {
      names.addAll(['italian', 'italiano', 'ita']);
    } else if (code == 'HI') {
      names.addAll(['hindi', 'hin']);
    }
    return names.toSet().toList();
  }
}
