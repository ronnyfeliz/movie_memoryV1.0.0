import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tmdb_cache.dart';
import '../../features/search/domain/media_model.dart';
import '../../features/discover/data/discover_provider.dart';
import '../l10n/locale_provider.dart';

final tmdbCacheProvider = Provider<TmdbCache>((ref) => TmdbCache());

Future<List<MediaModel>> _fetchWithCache({
  required TmdbCache cache,
  required String cacheKey,
  required Future<List<dynamic>> Function() fetch,
  Duration ttl = const Duration(hours: 24),
}) async {
  final cached = cache.get(cacheKey);
  if (cached != null) {
    return (cached as List).map((e) => MediaModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  final data = await fetch();
  cache.put(cacheKey, data, ttl: ttl);
  return data.map((json) => MediaModel.fromJson(json)).toList();
}

final cachedTrendingProvider = FutureProvider<List<MediaModel>>((ref) {
  final cache = ref.read(tmdbCacheProvider);
  final api = ref.read(tmdbApiProvider);
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;
  return _fetchWithCache(
    cache: cache, cacheKey: '${lang}_trending_day',
    fetch: () => api.getTrending(), ttl: const Duration(hours: 24),
  );
});

final cachedPopularMoviesProvider = FutureProvider<List<MediaModel>>((ref) {
  final cache = ref.read(tmdbCacheProvider);
  final api = ref.read(tmdbApiProvider);
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;
  return _fetchWithCache(
    cache: cache, cacheKey: '${lang}_popular_movies',
    fetch: () => api.getPopularMovies(), ttl: const Duration(hours: 24),
  );
});

final cachedPopularTvProvider = FutureProvider<List<MediaModel>>((ref) {
  final cache = ref.read(tmdbCacheProvider);
  final api = ref.read(tmdbApiProvider);
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;
  return _fetchWithCache(
    cache: cache, cacheKey: '${lang}_popular_tv',
    fetch: () => api.getPopularTv(), ttl: const Duration(hours: 24),
  );
});

final cachedNowPlayingProvider = FutureProvider<List<MediaModel>>((ref) {
  final cache = ref.read(tmdbCacheProvider);
  final api = ref.read(tmdbApiProvider);
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;
  return _fetchWithCache(
    cache: cache, cacheKey: '${lang}_now_playing',
    fetch: () => api.getNowPlaying(), ttl: const Duration(hours: 24),
  );
});

final cachedTopRatedProvider = FutureProvider<List<MediaModel>>((ref) {
  final cache = ref.read(tmdbCacheProvider);
  final api = ref.read(tmdbApiProvider);
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;
  return _fetchWithCache(
    cache: cache, cacheKey: '${lang}_top_rated',
    fetch: () => api.getTopRated(), ttl: const Duration(hours: 24),
  );
});

final cachedSearchProvider = FutureProvider.family<List<MediaModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final cache = ref.read(tmdbCacheProvider);
  final api = ref.read(tmdbApiProvider);
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;
  final cacheKey = '${lang}_search_${query.toLowerCase()}';
  final cached = cache.get(cacheKey);
  if (cached != null) {
    return (cached as List).map((e) => MediaModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  final data = await api.searchMulti(query);
  cache.put(cacheKey, data, ttl: const Duration(hours: 1));
  return data.map((json) => MediaModel.fromJson(json)).toList();
});
