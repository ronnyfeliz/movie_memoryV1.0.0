import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'watch_history_model.dart';

class WatchHistoryService {
  static const _localKey = 'watch_history';

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static CollectionReference get _historyRef =>
      _firestore.collection('users').doc(_uid).collection('watch_history');

  static Future<void> save({
    required int tmdbId,
    int? imdbId,
    required String type,
    required double progress,
    String? title,
    String? posterPath,
    int? season,
    int? episode,
    double? totalDuration,
  }) async {
    final percentage = totalDuration != null && totalDuration > 0
        ? (progress / totalDuration).clamp(0.0, 1.0)
        : progress.clamp(0.0, 1.0);

    if (_uid != null) {
      try {
        final existing = await _historyRef
            .where('tmdbId', isEqualTo: tmdbId)
            .where('type', isEqualTo: type)
            .limit(1)
            .get();
        final data = {
          'tmdbId': tmdbId,
          'imdbId': imdbId,
          'type': type,
          'title': title ?? '',
          'posterPath': posterPath ?? '',
          'season': season,
          'episode': episode,
          'progress': progress,
          'totalDuration': totalDuration,
          'percentage': percentage,
          'lastWatched': DateTime.now().toIso8601String(),
        };
        if (existing.docs.isNotEmpty) {
          await existing.docs.first.reference.update(data);
        } else {
          await _historyRef.add(data);
        }
      } catch (e) {
        _saveLocal(tmdbId, progress,
            title: title, type: type, posterPath: posterPath, season: season, episode: episode);
      }
    } else {
      _saveLocal(tmdbId, progress,
          title: title, type: type, posterPath: posterPath, season: season, episode: episode);
    }
  }

  static Future<List<WatchHistoryEntry>> getAll() async {
    if (_uid != null) {
      try {
        final snap = await _historyRef
            .orderBy('lastWatched', descending: true)
            .limit(50)
            .get();
        return snap.docs
            .map((doc) => WatchHistoryEntry.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return _getAllLocal();
      }
    }
    return _getAllLocal();
  }

  static Stream<List<WatchHistoryEntry>> watchAll() {
    if (_uid != null) {
      return _historyRef
          .orderBy('lastWatched', descending: true)
          .limit(50)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => WatchHistoryEntry.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList());
    }
    return _localHistoryStream();
  }

  static Future<void> removeEntry(String docId) async {
    if (_uid != null) {
      try {
        await _historyRef.doc(docId).delete();
      } catch (_) {}
    }
  }

  static Future<void> clearAll() async {
    if (_uid != null) {
      try {
        final snap = await _historyRef.get();
        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
  }

  static Future<Map<String, dynamic>?> getLocal(int tmdbId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = _parse(prefs.getString(_localKey));
    return history[tmdbId.toString()] as Map<String, dynamic>?;
  }

  static void _saveLocal(int tmdbId, double progress,
      {String? title, String? type, String? posterPath, int? season, int? episode}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = _parse(prefs.getString(_localKey));
    history[tmdbId.toString()] = {
      'tmdbId': tmdbId,
      'type': type ?? 'movie',
      'progress': progress,
      'title': title ?? '',
      'posterPath': posterPath ?? '',
      'season': season,
      'episode': episode,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_localKey, jsonEncode(history));
  }

  static Future<List<WatchHistoryEntry>> _getAllLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final history = _parse(prefs.getString(_localKey));
    return history.entries.map((e) {
      final map = Map<String, dynamic>.from(e.value as Map);
      return WatchHistoryEntry.fromMap(e.key, map);
    }).toList();
  }

  static Stream<List<WatchHistoryEntry>> _localHistoryStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      yield await _getAllLocal();
    }
  }

  static Map<String, dynamic> _parse(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
