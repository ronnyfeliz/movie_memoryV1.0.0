import '../player/vod_models.dart';
import '../player/language_resolver.dart';

/// Middleware for normalizing third-party responses into VodMedia.
class ContentNormalizer {
  
  /// Example: Normalizing a response from a generic "Provider A"
  static VodMedia fromProviderA(Map<String, dynamic> json) {
    final List<VodSource> sources = [];
    
    if (json['links'] != null) {
      for (var link in json['links']) {
        sources.add(VodSource(
          provider: 'ProviderA',
          url: link['url'],
          format: link['type'] == 'hls' ? 'hls' : 'mp4',
          audios: (link['tracks'] as List? ?? [])
              .where((t) => t['type'] == 'audio')
              .map((t) => VodLanguage(
                id: t['id'].toString(),
                bcp47: LanguageResolver.normalizeBcp47(t['label'] ?? ''),
                label: t['label'] ?? 'Audio',
                isOriginal: t['default'] ?? false,
              ))
              .toList(),
          subtitles: (link['tracks'] as List? ?? [])
              .where((t) => t['type'] == 'subtitle')
              .map((t) => VodLanguage(
                id: t['id'].toString(),
                bcp47: LanguageResolver.normalizeBcp47(t['label'] ?? ''),
                label: t['label'] ?? 'Subtitle',
              ))
              .toList(),
        ));
      }
    }

    return VodMedia(
      id: json['id'].toString(),
      type: json['media_type'] ?? 'movie',
      title: json['title'] ?? 'Unknown',
      originalLanguage: json['original_language'] ?? 'en',
      posterPath: json['poster_path'],
      sources: sources,
    );
  }

  /// Example: Normalizing a response from a generic "Provider B" (Direct URL)
  static VodMedia fromProviderB(String id, String url, String title) {
    return VodMedia(
      id: id,
      type: 'movie',
      title: title,
      originalLanguage: 'en',
      sources: [
        VodSource(
          provider: 'ProviderB',
          url: url,
          format: 'hls',
        ),
      ],
    );
  }
}
