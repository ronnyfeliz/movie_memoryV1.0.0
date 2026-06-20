import '../core/cache/tmdb_cache.dart';

/// In-memory + Hive two-tier cache for TMDB responses.
class TmdbCacheService {
  static final Map<String, _CacheEntry> _memory = {};
  static const _defaultTtl = Duration(minutes: 30);

  static dynamic get(String key, {Duration? ttl}) {
    final entry = _memory[key];
    if (entry != null) {
      if (DateTime.now().isBefore(entry.expiresAt)) {
        return entry.data;
      }
      _memory.remove(key);
    }
    final hiveData = TmdbCache().get(key);
    if (hiveData != null) {
      _memory[key] = _CacheEntry(hiveData, DateTime.now().add(ttl ?? _defaultTtl));
      return hiveData;
    }
    return null;
  }

  static Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    final expiresAt = DateTime.now().add(ttl ?? _defaultTtl);
    _memory[key] = _CacheEntry(data, expiresAt);
    await TmdbCache().put(key, data, ttl: ttl ?? _defaultTtl);
  }

  static Future<dynamic> fetch(
    String key,
    Future<dynamic> Function() fetcher, {
    Duration? ttl,
  }) async {
    final cached = get(key, ttl: ttl);
    if (cached != null) return cached;
    final data = await fetcher();
    await set(key, data, ttl: ttl);
    return data;
  }

  /// Remove a single key from both memory and persistent cache.
  static void invalidate(String key) {
    _memory.remove(key);
    TmdbCache().delete(key);
  }

  /// Clear ALL in-memory cache and optionally the persistent layer.
  static Future<void> clear({bool persistent = false}) async {
    _memory.clear();
    if (persistent) {
      await TmdbCache().clear();
    }
  }

  /// Invalidate every entry whose key starts with [prefix].
  static Future<void> invalidatePrefix(String prefix) async {
    _memory.removeWhere((k, _) => k.startsWith(prefix));
    await TmdbCache().deleteByPrefix(prefix);
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;
  const _CacheEntry(this.data, this.expiresAt);
}
