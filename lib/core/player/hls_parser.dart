import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Result of an HLS Spanish-track search.
class HlsParseResult {
  /// The resolved URI (may be [originalUri] if no Spanish track found).
  final String url;

  /// Whether the manifest contained `#EXT-X-MEDIA:TYPE=AUDIO` lines.
  final bool isMasterPlaylist;

  /// Whether a Spanish audio track was actually found and selected.
  final bool spanishFound;

  /// The original (fallback) URI that was passed in.
  final String originalUri;

  const HlsParseResult({
    required this.url,
    required this.isMasterPlaylist,
    required this.spanishFound,
    required this.originalUri,
  });
}

class HlsParser {
  static final List<String> _spanishKeywords = [
    'es', 'spa', 'spanish', 'español', 'es-mx', 'es-es', 'es_es',
    'castellano', 'esp', 'espanol', 'espania', 'spain',
    'latin', 'latino', 'lat', 'mex', 'spanish (latin', 'spa-lat',
    'es-la', 'spa-la',
  ];

  static bool _matchesSpanish(String value) {
    final lower = value.toLowerCase().trim();
    if (lower == 'es') return true;
    return _spanishKeywords.any((kw) => lower.contains(kw));
  }

  static Map<String, String> _parseAttributes(String line) {
    final map = <String, String>{};
    final re = RegExp(r'''(\w[\w-]*)=("(?:[^"\\]|\\.)*"|[^",\s]+)''');
    for (final m in re.allMatches(line)) {
      final group1 = m.group(1);
      var group2 = m.group(2);
      if (group1 == null || group2 == null) continue;
      if (group2.startsWith('"') && group2.endsWith('"')) {
        group2 = group2.substring(1, group2.length - 1);
      }
      map[group1.toLowerCase()] = group2;
    }
    return map;
  }

  static String _resolve(String uri, String baseUrl) {
    if (uri.startsWith('http')) return uri;
    if (baseUrl.isEmpty) return uri;
    return Uri.parse(baseUrl).resolve(uri).toString();
  }

  // ────────────────────────────────────────────────────────────────
  //  Public API
  // ────────────────────────────────────────────────────────────────

  /// Returns `true` when [manifestContent] contains at least one
  /// `#EXT-X-MEDIA:TYPE=AUDIO` line (i.e. it is a Master Playlist
  /// with separate audio tracks).
  static bool isMasterPlaylist(String manifestContent) {
    return manifestContent.contains('#EXT-X-MEDIA:TYPE=AUDIO');
  }

  /// Parses an already-downloaded HLS master manifest and returns a
  /// [HlsParseResult] with the best Spanish audio URI found.
  ///
  /// When no Spanish track is detected, [HlsParseResult.url] equals
  /// [originalUri] and [spanishFound] is `false`.
  ///
  /// When the manifest is not a master playlist (no audio track tags),
  /// [isMasterPlaylist] will be `false`.
  static HlsParseResult findSpanishTrack(String manifestContent,
      {String originalUri = ''}) {
    final lines = manifestContent.split('\n');

    // ── Log all audio track lines for debugging ────────────────────
    debugPrint('[HlsParser] ===== MANIFEST AUDIO TRACKS =====');
    var audioCount = 0;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains('#EXT-X-MEDIA:') && lines[i].contains('TYPE=AUDIO')) {
        audioCount++;
        debugPrint('[HlsParser]   L$i: ${lines[i]}');
      }
    }
    debugPrint('[HlsParser] ===== $audioCount audio tracks found =====');

    if (audioCount == 0) {
      debugPrint('[HlsParser] Not a Master Playlist — no audio track tags.');
      return HlsParseResult(
        url: originalUri,
        isMasterPlaylist: false,
        spanishFound: false,
        originalUri: originalUri,
      );
    }

    // ── Phase 1: collect audio tracks and stream variants ──────────
    final audioTracks = <_AudioTrackCandidate>[];
    final streamVariants = <_StreamVariant>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.contains('#EXT-X-MEDIA:') && line.contains('TYPE=AUDIO')) {
        final attrs = _parseAttributes(line);
        audioTracks.add(_AudioTrackCandidate(
          language: attrs['language'] ?? '',
          name: attrs['name'] ?? '',
          uri: attrs['uri'] ?? '',
          groupId: attrs['group-id'] ?? '',
          isDefault: (attrs['default'] ?? '').toUpperCase() == 'YES',
          isAutoselect: (attrs['autoselect'] ?? '').toUpperCase() == 'YES',
          rawLine: line,
        ));
      }

      if (line.contains('#EXT-X-STREAM-INF:')) {
        final attrs = _parseAttributes(line);
        final audioGroup = attrs['audio'] ?? '';
        final nextLine = i + 1 < lines.length ? lines[i + 1].trim() : '';
        if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
          streamVariants.add(_StreamVariant(audioGroup: audioGroup, uri: nextLine));
        }
      }
    }

    // ── Phase 2: prioritised matching ──────────────────────────────
    String? bestUri;
    String? bestGroupId;
    String? debugReason;
    var spanishFound = false;

    // Priority A: audio track with URI + matching language/name
    for (final t in audioTracks) {
      if (_matchesSpanish(t.language) || _matchesSpanish(t.name)) {
        if (t.uri.isNotEmpty) {
          bestUri = t.uri;
          bestGroupId = t.groupId;
          spanishFound = true;
          debugReason = 'A: lang="${t.language}" name="${t.name}"';
          debugPrint('[HlsParser] ✓ Priority $debugReason');
          break;
        }
      }
    }

    // Priority B: audio track without URI — remember groupId
    if (!spanishFound) {
      for (final t in audioTracks) {
        if (_matchesSpanish(t.language) || _matchesSpanish(t.name)) {
          bestGroupId = t.groupId;
          spanishFound = true;
          debugReason = 'B: groupId="${t.groupId}" lang="${t.language}" name="${t.name}"';
          debugPrint('[HlsParser] ✓ Priority $debugReason');
          break;
        }
      }
    }

    // Priority C: stream variant referencing the matched group
    if (bestUri == null && bestGroupId != null) {
      for (final v in streamVariants) {
        if (v.audioGroup == bestGroupId) {
          bestUri = v.uri;
          debugReason = 'C: variant → group "$bestGroupId"';
          debugPrint('[HlsParser] ✓ Priority $debugReason');
          break;
        }
      }
    }

    // Priority D: combined fallback on any track that smells Spanish
    if (!spanishFound) {
      for (final t in audioTracks) {
        final combined = '${t.language} ${t.name} ${t.groupId}';
        if (_matchesSpanish(combined)) {
          spanishFound = true;
          if (t.uri.isNotEmpty) {
            bestUri = t.uri;
          } else {
            bestGroupId = t.groupId;
          }
          debugReason = 'D: combined="$combined"';
          debugPrint('[HlsParser] ✓ Priority $debugReason');
          break;
        }
      }
    }

    // Priority E: group from D → variant
    if (bestUri == null && bestGroupId != null) {
      for (final v in streamVariants) {
        if (v.audioGroup == bestGroupId) {
          bestUri = v.uri;
          break;
        }
      }
    }

    // ── Phase 3: return ────────────────────────────────────────────
    String finalUrl;
    if (bestUri == null) {
      debugPrint('[HlsParser] ✗ No Spanish track found among $audioCount audio tracks.');
      finalUrl = originalUri;
    } else {
      finalUrl = _resolve(bestUri, originalUri);
      debugPrint('[HlsParser] ✓ Selected: $finalUrl  ($debugReason)');
    }

    return HlsParseResult(
      url: finalUrl,
      isMasterPlaylist: true,
      spanishFound: spanishFound,
      originalUri: originalUri,
    );
  }

  /// Downloads the manifest at [masterUrl] and returns the best
  /// Spanish audio URI found.
  ///
  /// Returns [masterUrl] unchanged when:
  ///   - the download fails,
  ///   - the manifest is not a master playlist,
  ///   - no Spanish track is found.
  static Future<String> getVariantForLanguage(
    String masterUrl,
    String targetLang,
    Map<String, String> headers,
  ) async {
    if (!targetLang.toUpperCase().startsWith('ES')) {
      debugPrint('[HlsParser] Target "$targetLang" is not Spanish — skipping.');
      return masterUrl;
    }

    try {
      debugPrint('[HlsParser] Downloading manifest: $masterUrl');
      final response = await http.get(Uri.parse(masterUrl), headers: headers);
      if (response.statusCode != 200) {
        debugPrint('[HlsParser] HTTP ${response.statusCode}');
        return masterUrl;
      }

      final result = findSpanishTrack(response.body, originalUri: masterUrl);
      return result.url;
    } catch (e) {
      debugPrint('[HlsParser] Error: $e');
      return masterUrl;
    }
  }
}

class _AudioTrackCandidate {
  final String language;
  final String name;
  final String uri;
  final String groupId;
  final bool isDefault;
  final bool isAutoselect;
  final String rawLine;

  const _AudioTrackCandidate({
    required this.language,
    required this.name,
    required this.uri,
    required this.groupId,
    required this.isDefault,
    required this.isAutoselect,
    required this.rawLine,
  });
}

class _StreamVariant {
  final String audioGroup;
  final String uri;

  const _StreamVariant({required this.audioGroup, required this.uri});
}
