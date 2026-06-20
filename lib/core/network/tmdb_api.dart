import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/search/domain/media_model.dart';

/// Centralized TMDB API service.
///
/// Content language is hardcoded to **es-ES** for all API calls.
/// If a localized field (e.g. overview) is empty, the service
/// automatically falls back to the original language (en-US).
class TmdbApi {
  static final TmdbApi _instance = TmdbApi._();
  factory TmdbApi() => _instance;
  TmdbApi._();

  // ── Fixed content language ─────────────────────────────────────────────

  /// TMDB language tag — always Spanish (Spain).
  static const String language = 'es-ES';

  /// Fallback language when the localized version is incomplete.
  static const String _fallbackLanguage = 'en-US';

  /// Region used in list endpoints.
  static const String region = 'ES';

  // ── Dio client ─────────────────────────────────────────────────────────

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    headers: {
      'Authorization': 'Bearer ${dotenv.env['TMDB_ACCESS_TOKEN']}',
      'accept': 'application/json',
    },
  ));

  // ── Helpers ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _langParams([Map<String, dynamic>? extra]) async {
    final prefs = await SharedPreferences.getInstance();
    final localCode = prefs.getString('app_locale') ?? 'es';
    
    String tmdbLang = 'es-ES';
    String tmdbRegion = 'ES';
    
    if (localCode == 'es') {
      tmdbLang = 'es-ES';
      tmdbRegion = 'ES';
    } else if (localCode == 'en') {
      tmdbLang = 'en-US';
      tmdbRegion = 'US';
    } else if (localCode == 'pt') {
      tmdbLang = 'pt-BR';
      tmdbRegion = 'BR';
    } else if (localCode == 'it') {
      tmdbLang = 'it-IT';
      tmdbRegion = 'IT';
    } else if (localCode == 'fr') {
      tmdbLang = 'fr-FR';
      tmdbRegion = 'FR';
    } else if (localCode == 'ru') {
      tmdbLang = 'ru-RU';
      tmdbRegion = 'RU';
    } else if (localCode == 'ko') {
      tmdbLang = 'ko-KR';
      tmdbRegion = 'KR';
    } else if (localCode == 'ja') {
      tmdbLang = 'ja-JP';
      tmdbRegion = 'JP';
    } else if (localCode == 'zh') {
      tmdbLang = 'zh-CN';
      tmdbRegion = 'CN';
    } else {
      tmdbLang = '$localCode-${localCode.toUpperCase()}';
      tmdbRegion = localCode.toUpperCase();
    }

    final params = <String, dynamic>{'language': tmdbLang, 'region': tmdbRegion};
    if (extra != null) params.addAll(extra);
    return params;
  }

  Future<List<dynamic>> _fetchList(String path, {Map<String, dynamic>? params}) async {
    final query = await _langParams(params);
    final response = await _dio.get(path, queryParameters: query);
    return response.data['results'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> _fetchMap(String path, {Map<String, dynamic>? params}) async {
    final query = await _langParams(params);
    final response = await _dio.get(path, queryParameters: query);
    return response.data as Map<String, dynamic>;
  }

  /// Fetch raw JSON for a single item — used internally for fallback.
  Future<Map<String, dynamic>> _fetchRaw(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(path, queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  // ── Trending ───────────────────────────────────────────────────────────

  Future<List<dynamic>> getTrending({String timeWindow = 'day', int page = 1}) =>
      _fetchList('/trending/all/$timeWindow', params: {'page': page});

  // ── Movie lists ────────────────────────────────────────────────────────

  Future<List<dynamic>> getPopularMovies({int page = 1}) =>
      _fetchList('/movie/popular', params: {'page': page});

  Future<List<dynamic>> getNowPlaying({int page = 1}) =>
      _fetchList('/movie/now_playing', params: {'page': page});

  Future<List<dynamic>> getTopRated({int page = 1}) =>
      _fetchList('/movie/top_rated', params: {'page': page});

  // ── TV lists ───────────────────────────────────────────────────────────

  Future<List<dynamic>> getPopularTv({int page = 1}) =>
      _fetchList('/tv/popular', params: {'page': page});

  // ── Search ─────────────────────────────────────────────────────────────

  Future<List<dynamic>> searchMulti(String query, {int page = 1}) =>
      _fetchList('/search/multi', params: {'query': query, 'page': page});

  Future<List<dynamic>> searchMovie(String query, {int page = 1}) =>
      _fetchList('/search/movie', params: {'query': query, 'page': page});

  // ── Movie detail ───────────────────────────────────────────────────────

  Future<MediaModel> getMovieDetail(int id) async {
    final data = await _fetchMap('/movie/$id');
    final model = MediaModel.fromJson({...data, 'media_type': 'movie'});

    // Fallback: if overview is empty in Spanish, fetch English
    if (model.overview.isEmpty) {
      try {
        final enData = await _fetchRaw('/movie/$id', params: {
          'language': _fallbackLanguage,
        });
        final enOverview = enData['overview'] as String? ?? '';
        if (enOverview.isNotEmpty) {
          return MediaModel(
            id: model.id,
            title: model.title,
            originalTitle: model.originalTitle,
            overview: enOverview,
            posterPath: model.posterPath,
            backdropPath: model.backdropPath,
            mediaType: model.mediaType,
            voteAverage: model.voteAverage,
            voteCount: model.voteCount,
            releaseDate: model.releaseDate,
            runtime: model.runtime,
            genreIds: model.genreIds,
            genreNames: model.genreNames,
            imdbId: model.imdbId,
          );
        }
      } catch (_) {}
    }

    return model;
  }

  // ── TV detail ──────────────────────────────────────────────────────────

  Future<MediaModel> getSeriesDetail(int id) async {
    final data = await _fetchMap('/tv/$id', params: {'append_to_response': 'external_ids'});
    final extIds = data['external_ids'] as Map<String, dynamic>?;
    final imdbId = extIds?['imdb_id'] as String?;
    final model = MediaModel.fromJson({...data, 'media_type': 'tv', 'imdb_id': imdbId});

    // Fallback: if overview is empty in Spanish, fetch English
    if (model.overview.isEmpty) {
      try {
        final enData = await _fetchRaw('/tv/$id', params: {
          'language': _fallbackLanguage,
        });
        final enOverview = enData['overview'] as String? ?? '';
        if (enOverview.isNotEmpty) {
          return MediaModel(
            id: model.id,
            title: model.title,
            originalTitle: model.originalTitle,
            overview: enOverview,
            posterPath: model.posterPath,
            backdropPath: model.backdropPath,
            mediaType: model.mediaType,
            voteAverage: model.voteAverage,
            voteCount: model.voteCount,
            releaseDate: model.releaseDate,
            runtime: model.runtime,
            genreIds: model.genreIds,
            genreNames: model.genreNames,
            imdbId: model.imdbId,
          );
        }
      } catch (_) {}
    }

    return model;
  }

  // ── Recommendations & Similar ──────────────────────────────────────────

  Future<List<dynamic>> getMovieRecommendations(int id, {int page = 1}) =>
      _fetchList('/movie/$id/recommendations', params: {'page': page});

  Future<List<dynamic>> getMovieSimilar(int id, {int page = 1}) =>
      _fetchList('/movie/$id/similar', params: {'page': page});

  // ── Genres ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMovieGenres() async {
    final query = await _langParams();
    final response = await _dio.get('/genre/movie/list', queryParameters: query);
    return List<Map<String, dynamic>>.from(response.data['genres'] as List);
  }

  // ── Videos ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMovieVideos(int id) async {
    final query = await _langParams();
    final response = await _dio.get('/movie/$id/videos', queryParameters: query);
    return List<Map<String, dynamic>>.from(response.data['results'] as List);
  }

  Future<List<Map<String, dynamic>>> getSeriesVideos(int id) async {
    final query = await _langParams();
    final response = await _dio.get('/tv/$id/videos', queryParameters: query);
    return List<Map<String, dynamic>>.from(response.data['results'] as List);
  }

  // ── TV seasons & episodes ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSeriesSeasons(int seriesId) async {
    final data = await _fetchMap('/tv/$seriesId');
    final seasons = data['seasons'] as List<dynamic>? ?? [];
    return seasons.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getSeasonDetails(int seriesId, int seasonNumber) =>
      _fetchMap('/tv/$seriesId/season/$seasonNumber');

  Future<Map<String, dynamic>> getEpisodeDetails(
      int seriesId, int seasonNumber, int episodeNumber) =>
      _fetchMap('/tv/$seriesId/season/$seasonNumber/episode/$episodeNumber');

  Future<List<Map<String, dynamic>>> getTvGenres() async {
    final query = await _langParams();
    final response = await _dio.get('/genre/tv/list', queryParameters: query);
    return List<Map<String, dynamic>>.from(response.data['genres'] as List);
  }

  Future<List<dynamic>> discoverMedia({
    required String type,
    int page = 1,
    int? year,
    String? region,
    List<int>? genres,
    String? sortBy,
  }) async {
    final Map<String, dynamic> params = {'page': page};
    if (year != null) {
      if (type == 'movie') {
        params['primary_release_year'] = year;
      } else {
        params['first_air_date_year'] = year;
      }
    }
    if (region != null && region.isNotEmpty) {
      params['region'] = region;
    }
    if (genres != null && genres.isNotEmpty) {
      params['with_genres'] = genres.join(',');
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      params['sort_by'] = sortBy;
    }
    return _fetchList('/discover/$type', params: params);
  }
}
