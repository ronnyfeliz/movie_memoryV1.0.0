import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/tmdb_api.dart';
import '../../search/domain/media_model.dart';

final tmdbApiProvider = Provider<TmdbApi>((ref) => TmdbApi());

final trendingProvider = FutureProvider<List<MediaModel>>((ref) async {
  final data = await ref.read(tmdbApiProvider).getTrending();
  return data.map((json) => MediaModel.fromJson(json)).toList();
});

final popularMoviesProvider = FutureProvider<List<MediaModel>>((ref) async {
  final data = await ref.read(tmdbApiProvider).getPopularMovies();
  return data.map((json) => MediaModel.fromJson(json)).toList();
});

final popularTvProvider = FutureProvider<List<MediaModel>>((ref) async {
  final data = await ref.read(tmdbApiProvider).getPopularTv();
  return data.map((json) => MediaModel.fromJson(json)).toList();
});

final searchProvider = FutureProvider.family<List<MediaModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final data = await ref.read(tmdbApiProvider).searchMulti(query);
  return data.map((json) => MediaModel.fromJson(json)).toList();
});
