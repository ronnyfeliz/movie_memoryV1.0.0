import 'package:flutter/foundation.dart';

/// Standardized Language representation for VOD.
@immutable
class VodLanguage {
  final String id;
  final String bcp47;
  final String label;
  final bool isOriginal;

  const VodLanguage({
    required this.id,
    required this.bcp47,
    required this.label,
    this.isOriginal = false,
  });

  factory VodLanguage.fromJson(Map<String, dynamic> json) {
    return VodLanguage(
      id: json['id'] ?? '',
      bcp47: json['bcp47'] ?? json['lang'] ?? 'und',
      label: json['label'] ?? '',
      isOriginal: json['is_original'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bcp47': bcp47,
    'label': label,
    'is_original': isOriginal,
  };
}

/// Representation of a Video Source with its tracks.
class VodSource {
  final String provider;
  final String url;
  final String format; // hls, dash, mp4
  final List<VodLanguage> audios;
  final List<VodLanguage> subtitles;
  final Map<String, String>? headers;

  VodSource({
    required this.provider,
    required this.url,
    this.format = 'hls',
    this.audios = const [],
    this.subtitles = const [],
    this.headers,
  });

  factory VodSource.fromJson(Map<String, dynamic> json) {
    return VodSource(
      provider: json['provider'] ?? 'unknown',
      url: json['url'] ?? '',
      format: json['format'] ?? 'hls',
      audios: (json['audios'] as List? ?? [])
          .map((e) => VodLanguage.fromJson(e))
          .toList(),
      subtitles: (json['subtitles'] as List? ?? [])
          .map((e) => VodLanguage.fromJson(e))
          .toList(),
      headers: (json['headers'] as Map?)?.cast<String, String>(),
    );
  }
}

/// Unified Media Content for the Player.
class VodMedia {
  final String id;
  final String type; // movie, tv
  final String title;
  final String originalLanguage;
  final List<VodSource> sources;
  final String? posterPath;
  
  // For TV Shows
  final List<VodSeason>? seasons;

  VodMedia({
    required this.id,
    required this.type,
    required this.title,
    required this.originalLanguage,
    required this.sources,
    this.posterPath,
    this.seasons,
  });

  factory VodMedia.fromJson(Map<String, dynamic> json) {
    return VodMedia(
      id: json['id'].toString(),
      type: json['type'] ?? 'movie',
      title: json['title'] ?? '',
      originalLanguage: json['original_language'] ?? 'en',
      posterPath: json['poster_path'],
      sources: (json['sources'] as List? ?? [])
          .map((e) => VodSource.fromJson(e))
          .toList(),
      seasons: (json['seasons'] as List?)
          ?.map((e) => VodSeason.fromJson(e))
          .toList(),
    );
  }
}

class VodSeason {
  final int number;
  final String? title;
  final List<VodEpisode> episodes;

  VodSeason({required this.number, this.title, required this.episodes});

  factory VodSeason.fromJson(Map<String, dynamic> json) {
    return VodSeason(
      number: json['number'] ?? 1,
      title: json['title'],
      episodes: (json['episodes'] as List? ?? [])
          .map((e) => VodEpisode.fromJson(e))
          .toList(),
    );
  }
}

class VodEpisode {
  final int number;
  final String title;
  final List<VodSource> sources;

  VodEpisode({required this.number, required this.title, required this.sources});

  factory VodEpisode.fromJson(Map<String, dynamic> json) {
    return VodEpisode(
      number: json['number'] ?? 1,
      title: json['title'] ?? '',
      sources: (json['sources'] as List? ?? [])
          .map((e) => VodSource.fromJson(e))
          .toList(),
    );
  }
}
