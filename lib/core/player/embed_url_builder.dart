import 'server_selector.dart';

class EmbedUrlBuilder {
  static String buildUrl(String mediaType, int tmdbId,
      {String? server, String? lang, String? audioLang, String? subtitleLang, int? season, int? episode}) {
    final serverName = server ?? ServerSelector.servers.first.name;
    final info = ServerSelector.serverByName(serverName);

    String url;
    if (mediaType == 'tv' && season != null && episode != null) {
      url = info.tvUrl(tmdbId, season, episode);
    } else {
      url = info.movieUrl(tmdbId);
    }

    final effAudio = audioLang ?? lang ?? '';
    final effSubtitle = subtitleLang ?? '';

    return _applyLanguages(url, effAudio, effSubtitle, serverName);
  }

  static String _getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'es': return 'spanish';
      case 'en': return 'english';
      case 'pt': return 'portuguese';
      case 'fr': return 'french';
      case 'de': return 'german';
      case 'it': return 'italian';
      case 'ru': return 'russian';
      case 'ja': return 'japanese';
      case 'ko': return 'korean';
      case 'zh': return 'chinese';
      default: return code;
    }
  }

  static String _applyLanguages(String url, String audioLang, String subtitleLang, String serverName) {
    final sep = url.contains('?') ? '&' : '?';
    final sname = serverName.toLowerCase();
    final params = <String>[];

    // 1. Apply Audio Language
    if (audioLang.isNotEmpty && audioLang.toUpperCase() != 'ORIGINAL') {
      final baseAudio = audioLang.toLowerCase().split('-').first;
      final isSpanish = baseAudio == 'es';
      params.add('audio=$baseAudio');
      params.add('lang=$baseAudio');
      params.add('primary_lang=$baseAudio');
      params.add('player_lang=$baseAudio');
      params.add('audio_track=$baseAudio');

      if (isSpanish && sname.contains('warez')) {
        params.add('type=latino');
      }
      if (sname.contains('vidlink')) {
        params.add('audio_lang=$baseAudio');
        params.add('audio_language=${_getLanguageName(baseAudio)}');
      }
      if (sname.contains('multiembed')) {
        params.add('audio_language=${_getLanguageName(baseAudio)}');
      }
      if (sname.contains('nontongo')) {
        params.add('audio_language=${_getLanguageName(baseAudio)}');
      }
    }

    // 2. Apply Subtitle Language
    if (subtitleLang.isNotEmpty && subtitleLang.toUpperCase() != 'ORIGINAL') {
      if (subtitleLang.toLowerCase() == 'disabled') {
        params.add('sub=0');
        params.add('subtitle=0');
        params.add('sub_lang=none');
        params.add('sub_language=none');
      } else {
        final baseSub = subtitleLang.toLowerCase().split('-').first;
        params.add('sub=$baseSub');
        params.add('subtitle=$baseSub');
        params.add('sub_lang=$baseSub');
        params.add('sub_language=${_getLanguageName(baseSub)}');
        params.add('player_sub=$baseSub');

        if (sname.contains('vidlink')) {
          params.add('sub_lang=$baseSub');
        }
        if (sname.contains('multiembed')) {
          params.add('sub_lang=$baseSub');
        }
      }
    }

    if (params.isEmpty) return url;
    return '$url$sep${params.join('&')}';
  }
}
