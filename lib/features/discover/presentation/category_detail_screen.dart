import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/movie_poster.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/sound/sound_service.dart';
import '../../../core/sound/sound_provider.dart';
import '../../search/domain/media_model.dart';
import '../data/discover_provider.dart';
import '../../../l10n/app_localizations.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categoryKey;
  final String title;

  const CategoryDetailScreen({
    super.key,
    required this.categoryKey,
    required this.title,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<MediaModel> _items = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(tmdbApiProvider);
      List<dynamic> raw = [];
      switch (widget.categoryKey) {
        case 'trending':
          raw = await api.getTrending(page: _page);
          break;
        case 'now_playing':
          raw = await api.getNowPlaying(page: _page);
          break;
        case 'popular_movies':
          raw = await api.getPopularMovies(page: _page);
          break;
        case 'popular_tv':
          raw = await api.getPopularTv(page: _page);
          break;
        case 'top_rated':
          raw = await api.getTopRated(page: _page);
          break;
      }

      final fetched = raw.map((json) {
        final map = Map<String, dynamic>.from(json);
        if (!map.containsKey('media_type')) {
          if (widget.categoryKey.contains('tv')) {
            map['media_type'] = 'tv';
          } else {
            map['media_type'] = 'movie';
          }
        }
        return MediaModel.fromJson(map);
      }).toList();

      if (mounted) {
        setState(() {
          _items.addAll(fetched);
          _page++;
          _isLoading = false;
          if (fetched.isEmpty || fetched.length < 20) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  String _getCategoryTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.categoryKey) {
      case 'trending':
        return l10n.trending;
      case 'now_playing':
        return l10n.nowPlaying;
      case 'popular_movies':
        return l10n.popularMovies;
      case 'popular_tv':
        return l10n.popularTv;
      case 'top_rated':
        return l10n.topRated;
      default:
        return widget.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getCategoryTitle(context), style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _items.isEmpty && _isLoading
          ? _buildShimmerGrid(isTabletOrDesktop)
          : _error != null && _items.isEmpty
              ? _buildErrorView()
              : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTabletOrDesktop ? 4 : 3,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return _GridCard(item: _items[index]);
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
    );
  }

  Widget _buildShimmerGrid(bool isTabletOrDesktop) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTabletOrDesktop ? 4 : 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 15,
      itemBuilder: (_, __) => const ShimmerLoading(width: 120, height: 180),
    );
  }

  Widget _buildErrorView() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '${l10n.errorLoading}:\n$_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchNextPage,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends ConsumerStatefulWidget {
  final MediaModel item;
  const _GridCard({required this.item});

  @override
  ConsumerState<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends ConsumerState<_GridCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () async {
        final prefs = ref.read(soundPreferencesProvider);
        await SoundService.playClick(prefs);
        if (context.mounted) {
          context.push('/detail/${item.id}?type=${item.mediaType}');
        }
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MoviePoster(
                  imageUrl: item.posterPath.isNotEmpty
                      ? 'https://image.tmdb.org/t/p/w300${item.posterPath}'
                      : null,
                  useHero: false,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.releaseDate.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.releaseDate.split('-').first,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (item.voteAverage > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            item.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
