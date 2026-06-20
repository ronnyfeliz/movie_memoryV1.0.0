import 'package:shared_preferences/shared_preferences.dart';

class ServerInfo {
  final String name;
  final String baseUrl;
  final String movieFormat;
  final String tvFormat;

  const ServerInfo({
    required this.name,
    required this.baseUrl,
    required this.movieFormat,
    required this.tvFormat,
  });

  String movieUrl(int tmdbId) {
    return '$baseUrl${movieFormat.replaceAll('{id}', '$tmdbId')}';
  }

  String tvUrl(int tmdbId, int season, int episode) {
    return '$baseUrl${tvFormat
        .replaceAll('{id}', '$tmdbId')
        .replaceAll('{s}', '$season')
        .replaceAll('{e}', '$episode')}';
  }
}

class ServerSelector {
  /// Priority-ordered servers for Spanish audio.
  /// Vidsrc.to has built-in audio track selection.
  /// WarezCDN supports explicit latino/spanish params.
  /// Embed.su and VidLink provide reliable Spanish fallback.
  static const _servers = [
    ServerInfo(
      name: 'Vidsrc.to',
      baseUrl: 'https://vidsrc.to/embed',
      movieFormat: '/movie/{id}',
      tvFormat: '/tv/{id}/{s}/{e}',
    ),
    ServerInfo(
      name: 'WarezCDN',
      baseUrl: 'https://warezcdn.com/embed',
      movieFormat: '/movie?tmdb={id}',
      tvFormat: '/tv?tmdb={id}&season={s}&episode={e}',
    ),
    ServerInfo(
      name: 'Embed.su',
      baseUrl: 'https://embed.su/embed',
      movieFormat: '/movie/{id}',
      tvFormat: '/tv/{id}/{s}/{e}',
    ),
    ServerInfo(
      name: 'VidLink',
      baseUrl: 'https://vidlink.pro',
      movieFormat: '/movie/{id}',
      tvFormat: '/tv/{id}/{s}/{e}',
    ),
    ServerInfo(
      name: 'MultiEmbed',
      baseUrl: 'https://multiembed.mov',
      movieFormat: '/?video_id={id}&tmdb=1',
      tvFormat: '/?video_id={id}&tmdb=1&s={s}&e={e}',
    ),
    ServerInfo(
      name: 'NontonGo',
      baseUrl: 'https://www.nontongo.win/embed',
      movieFormat: '/movie/{id}',
      tvFormat: '/tv/{id}/{s}/{e}',
    ),
  ];

  /// TMDB-specific server overrides.
  /// Certain titles are known to work better with specific servers for Spanish.
  static const Map<int, List<String>> _tmdbOverrides = {
    103: ['WarezCDN', 'MultiEmbed', 'Vidsrc.to', 'VidLink', 'Embed.su', 'NontonGo'], // Resident Evil (2002)
  };

  static const Map<String, List<String>> _serversByLang = {
    'ES':       ['WarezCDN', 'MultiEmbed', 'Vidsrc.to', 'NontonGo', 'VidLink', 'Embed.su'],
    'ES-MX':    ['WarezCDN', 'MultiEmbed', 'Vidsrc.to', 'NontonGo', 'VidLink', 'Embed.su'],
    'PT':       ['WarezCDN', 'MultiEmbed', 'Vidsrc.to', 'NontonGo', 'VidLink', 'Embed.su'],
    'EN':       ['VidLink', 'Vidsrc.to', 'MultiEmbed', 'Embed.su', 'NontonGo', 'WarezCDN'],
    'ORIGINAL': ['VidLink', 'Vidsrc.to', 'MultiEmbed', 'Embed.su', 'NontonGo', 'WarezCDN'],
  };

  static const _prefKey = 'server_cache_';
  static const _failKey = 'server_fail_';

  static List<ServerInfo> get servers => List.unmodifiable(_servers);
  static List<String> get serverNames => _servers.map((s) => s.name).toList();

  static ServerInfo serverByName(String name) {
    return _servers.firstWhere((s) => s.name == name, orElse: () => _servers.first);
  }

  static List<ServerInfo> serversForLanguage(String langCode, {int? tmdbId}) {
    final base = langCode.toUpperCase().split('-').first;

    // TMDB override
    if (tmdbId != null && _tmdbOverrides.containsKey(tmdbId)) {
      final override = _tmdbOverrides[tmdbId]!;
      return override
          .map((name) => _servers.firstWhere(
            (s) => s.name == name,
            orElse: () => _servers.first,
          ))
          .toList();
    }

    final preferred = _serversByLang[langCode.toUpperCase()]
        ?? _serversByLang[base]
        ?? _servers.map((s) => s.name).toList();

    return preferred
        .map((name) => _servers.firstWhere(
          (s) => s.name == name,
          orElse: () => _servers.first,
        ))
        .toList();
  }

  static Future<String> getBestServerForLanguage(int tmdbId, String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_prefKey${tmdbId}_$langCode');
    if (cached != null && _servers.any((s) => s.name == cached)) {
      return cached;
    }
    final ordered = serversForLanguage(langCode, tmdbId: tmdbId);
    return ordered.isNotEmpty ? ordered.first.name : _servers.first.name;
  }

  static Future<void> markSuccess(int tmdbId, String server, {String? langCode}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = langCode != null ? '$_prefKey${tmdbId}_$langCode' : '$_prefKey$tmdbId';
    await prefs.setString(key, server);
  }

  static Future<void> recordFailure(int tmdbId, String server) async {
    final prefs = await SharedPreferences.getInstance();
    final fails = (prefs.getInt('$_failKey$tmdbId$server') ?? 0) + 1;
    await prefs.setInt('$_failKey$tmdbId$server', fails);
  }

  static Future<void> resetFailCache(int tmdbId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('$_failKey$tmdbId'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<void> clearServerPreference(int tmdbId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('$_prefKey$tmdbId'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<String> switchServer(int tmdbId, String current, {String? langCode}) async {
    final ordered = langCode != null
        ? serversForLanguage(langCode, tmdbId: tmdbId).map((s) => s.name).toList()
        : _servers.map((s) => s.name).toList();

    final idx = ordered.indexOf(current);
    if (idx == -1 || idx >= ordered.length - 1) return ordered.first;
    return ordered[idx + 1];
  }
}
