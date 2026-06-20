import 'vod_models.dart';
import 'language_resolver.dart';
import 'app_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VodContentService {
  final Ref ref;

  VodContentService(this.ref);

  /// Main method to get playable content with resolved languages.
  Future<VodMedia> getMedia(String id, String type) async {
    // 1. Fetch from Middleware (simulated)
    final rawData = await _fetchFromBff(id, type);
    final media = VodMedia.fromJson(rawData);
    
    return media;
  }

  /// Resolves the best source and tracks based on user settings.
  ({VodSource source, VodLanguage? audio, VodLanguage? sub}) resolveBestStream(VodMedia media) {
    final settings = ref.read(appSettingsProvider);
    
    if (media.sources.isEmpty) {
      throw StateError('No sources available for media: ${media.id}');
    }
    final source = media.sources.first;

    final audio = LanguageResolver.resolve(
      source.audios,
      settings.contentLanguage,
      originalLang: media.originalLanguage,
    );

    final sub = settings.autoSubtitles 
      ? LanguageResolver.resolve(source.subtitles, settings.contentLanguage)
      : null;

    return (source: source, audio: audio, sub: sub);
  }

  Future<Map<String, dynamic>> _fetchFromBff(String id, String type) async {
    // In a real app, this calls your Node.js/Firebase middleware
    // which already has normalized the provider responses.
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "id": id,
      "type": type,
      "title": "Normalized Content",
      "original_language": "en",
      "sources": [
        {
          "provider": "PremiumServer",
          "url": "https://example.com/stream.m3u8",
          "format": "hls",
          "audios": [
            {"id": "en_orig", "bcp47": "en", "label": "English (Original)", "is_original": true},
            {"id": "es_lat", "bcp47": "es-419", "label": "Español Latino"}
          ],
          "subtitles": [
            {"id": "sub_es", "bcp47": "es", "label": "Español"},
            {"id": "sub_en", "bcp47": "en", "label": "English"}
          ]
        }
      ]
    };
  }
}

final vodContentServiceProvider = Provider((ref) => VodContentService(ref));
