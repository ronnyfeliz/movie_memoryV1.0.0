import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Persistent TMDB cache backed by Hive.
///
/// Cache keys should include the current language tag so that switching
/// languages automatically bypasses stale entries (see [TmdbCacheService]).
class TmdbCache {
  static const _boxName = 'tmdb_cache';
  late Box<String> _box;

  static final TmdbCache _instance = TmdbCache._();
  factory TmdbCache() => _instance;
  TmdbCache._();

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> put(String key, dynamic data, {Duration ttl = const Duration(hours: 1)}) async {
    final entry = jsonEncode({
      'data': data,
      'expiresAt': DateTime.now().add(ttl).toIso8601String(),
    });
    await _box.put(key, entry);
  }

  dynamic get(String key) {
    final entry = _box.get(key);
    if (entry == null) return null;
    try {
      final decoded = jsonDecode(entry);
      final expiresAt = DateTime.parse(decoded['expiresAt']);
      if (DateTime.now().isAfter(expiresAt)) {
        _box.delete(key);
        return null;
      }
      return decoded['data'];
    } catch (_) {
      _box.delete(key);
      return null;
    }
  }

  /// Remove a single entry.
  Future<void> delete(String key) => _box.delete(key);

  /// Remove all entries whose key starts with [prefix].
  Future<void> deleteByPrefix(String prefix) async {
    final keys = _box.keys.where((k) => k.toString().startsWith(prefix)).toList();
    for (final k in keys) {
      await _box.delete(k);
    }
  }

  /// Clear every cached entry.
  Future<void> clear() => _box.clear();
}
