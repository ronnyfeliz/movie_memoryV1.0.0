import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/cache/cache_provider.dart';
import '../../search/domain/media_model.dart';
import 'package:movie_memory/core/sound/sound_service.dart';
import 'package:movie_memory/core/sound/sound_provider.dart';
import 'package:movie_memory/core/widgets/movie_poster.dart';
import 'package:movie_memory/core/widgets/shimmer_loading.dart';
import 'package:movie_memory/core/widgets/error_view.dart';
import 'package:movie_memory/ui/player/continue_watching_section.dart';
import 'package:movie_memory/features/library/data/library_provider.dart';
import 'package:movie_memory/features/library/domain/library_item.dart';
import 'package:movie_memory/features/discover/data/discover_provider.dart';
import 'package:movie_memory/features/discover/data/daily_recommendation_provider.dart';
import 'package:movie_memory/features/notifications/data/notification_repository.dart';
import 'package:movie_memory/features/notifications/data/series_subscription_repository.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  void _navigateToCategory(BuildContext context, WidgetRef ref, String key, String title) {
    final prefs = ref.read(soundPreferencesProvider);
    SoundService.playClick(prefs);
    context.push('/discover/category?key=$key&title=${Uri.encodeComponent(title)}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trending = ref.watch(cachedTrendingProvider);
    final popularMovies = ref.watch(cachedPopularMoviesProvider);
    final popularTv = ref.watch(cachedPopularTvProvider);
    final nowPlaying = ref.watch(cachedNowPlayingProvider);
    final topRated = ref.watch(cachedTopRatedProvider);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discover, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search),
            tooltip: 'Búsqueda avanzada',
            onPressed: () async {
              final prefs = ref.read(soundPreferencesProvider);
              await SoundService.playClick(prefs);
              if (context.mounted) {
                context.push('/discover/advanced');
              }
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                unreadCountAsync.maybeWhen(
                  data: (count) => count > 0
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            onPressed: () async {
              final prefs = ref.read(soundPreferencesProvider);
              await SoundService.playClick(prefs);
              if (context.mounted) {
                context.push('/notifications');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest,
        onRefresh: () async {
          ref.invalidate(cachedTrendingProvider);
          ref.invalidate(dailyRecommendationProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DailyRecommendationSection(),
              const SizedBox(height: 16),
              const ContinueWatchingSection(),
              _SectionTitle(l10n.trending, onTap: () => _navigateToCategory(context, ref, 'trending', l10n.trending)),
              _HorizontalList(asyncData: trending),
              const SizedBox(height: 24),
              _SectionTitle(l10n.nowPlaying, onTap: () => _navigateToCategory(context, ref, 'now_playing', l10n.nowPlaying)),
              _HorizontalList(asyncData: nowPlaying),
              const SizedBox(height: 24),
              _SectionTitle(l10n.popularMovies, onTap: () => _navigateToCategory(context, ref, 'popular_movies', l10n.popularMovies)),
              _HorizontalList(asyncData: popularMovies),
              const SizedBox(height: 24),
              _SectionTitle(l10n.popularTv, onTap: () => _navigateToCategory(context, ref, 'popular_tv', l10n.popularTv)),
              _HorizontalList(asyncData: popularTv),
              const SizedBox(height: 24),
              _SectionTitle(l10n.topRated, onTap: () => _navigateToCategory(context, ref, 'top_rated', l10n.topRated)),
              _HorizontalList(asyncData: topRated),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _SectionTitle(this.title, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class _HorizontalList extends ConsumerWidget {
  final AsyncValue<List<MediaModel>> asyncData;
  const _HorizontalList({required this.asyncData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncData.when(
      loading: () => SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => const ShimmerLoading(width: 130, height: 200),
        ),
      ),
      error: (e, _) => SizedBox(height: 220, child: ErrorView(message: 'Error: $e')),
      data: (items) => SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => _MovieCard(item: items[i]),
        ),
      ),
    );
  }
}

class _MovieCard extends ConsumerStatefulWidget {
  final MediaModel item;
  const _MovieCard({required this.item});

  @override
  ConsumerState<_MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends ConsumerState<_MovieCard> {
  double _scale = 1.0;
  bool? _isSubscribed;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    if (widget.item.mediaType != 'tv') return;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final subscribed = await ref.read(seriesSubscriptionRepositoryProvider).isSubscribed(uid, widget.item.id);
    if (mounted) setState(() => _isSubscribed = subscribed);
  }

  Future<void> _toggleSubscription() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    final prefs = ref.read(soundPreferencesProvider);
    await SoundService.playClick(prefs);
    await ref.read(seriesSubscriptionRepositoryProvider).toggleSubscription(
      uid,
      widget.item.id,
      widget.item.title,
      widget.item.posterPath,
      widget.item.mediaType,
    );
    final subscribed = await ref.read(seriesSubscriptionRepositoryProvider).isSubscribed(uid, widget.item.id);
    if (mounted) setState(() => _isSubscribed = subscribed);
  }

  @override
  Widget build(BuildContext context) {
    final libItem = ref.watch(libraryItemByTmdbIdProvider(widget.item.id));
    final isFav = libItem.valueOrNull?.isFavorite ?? false;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      MoviePoster(
                        imageUrl: widget.item.posterUrl,
                        borderRadius: 12,
                        heroTag: null,
                        useHero: false,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final prefs = ref.read(soundPreferencesProvider);
                              await SoundService.playClick(prefs);
                              if (!context.mounted) return;
                              context.push('/detail/${widget.item.id}?type=${widget.item.mediaType}');
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6, right: 6,
                        child: _MovieFavoriteBadge(
                          tmdbId: widget.item.id,
                          mediaType: widget.item.mediaType,
                          isFav: isFav,
                          libItem: libItem.valueOrNull,
                        ),
                      ),
                      if (widget.item.mediaType == 'tv')
                        Positioned(
                          top: 6, left: 6,
                          child: GestureDetector(
                            onTap: _toggleSubscription,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                              ),
                              child: Icon(
                                _isSubscribed == true ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                                color: _isSubscribed == true ? cs.primary : Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (widget.item.year.isNotEmpty) ...[
                    Text(
                      widget.item.year,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.item.voteAverage.toStringAsFixed(1),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieFavoriteBadge extends ConsumerWidget {
  final int tmdbId;
  final String mediaType;
  final bool isFav;
  final LibraryItem? libItem;
  const _MovieFavoriteBadge({
    required this.tmdbId,
    required this.mediaType,
    required this.isFav,
    this.libItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final prefs = ref.read(soundPreferencesProvider);
        await SoundService.playAdd(prefs);
        final repo = ref.read(libraryRepositoryProvider);
        if (libItem != null) {
          await repo.updateItem(libItem!.copyWith(isFavorite: !isFav));
        } else {
          final api = ref.read(tmdbApiProvider);
          try {
            final model = mediaType == 'tv'
                ? await api.getSeriesDetail(tmdbId)
                : await api.getMovieDetail(tmdbId);
            await repo.addItem(LibraryItem(
              id: '',
              tmdbId: tmdbId,
              title: model.title,
              posterPath: model.posterPath,
              mediaType: mediaType,
              status: LibraryStatus.watchLater,
              isFavorite: true,
              year: model.year,
              addedAt: DateTime.now(),
              genres: model.genreNames,
            ));
          } catch (_) {}
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Icon(
          isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          color: isFav ? Theme.of(context).colorScheme.primary : Colors.white,
          size: 14,
        ),
      ),
    );
  }
}

class _DailyRecommendationSection extends ConsumerWidget {
  const _DailyRecommendationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyRecommendationProvider);
    final cs = Theme.of(context).colorScheme;

    return dailyAsync.when(
      loading: () => const ShimmerLoading(width: double.infinity, height: 200),
      error: (e, _) => const SizedBox.shrink(),
      data: (item) {
        if (item == null) return const SizedBox.shrink();

        final isMovie = item.mediaType == 'movie';
        final categoryName = isMovie ? 'PELÍCULA DEL DÍA' : 'SERIE DEL DÍA';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Recomendación del día',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Backdrop Image
                    item.backdropUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.backdropUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: cs.surfaceContainerHigh),
                            errorWidget: (_, __, ___) => item.posterUrl.isNotEmpty
                                ? CachedNetworkImage(imageUrl: item.posterUrl, fit: BoxFit.cover)
                                : Container(color: cs.surfaceContainerHigh),
                          )
                        : (item.posterUrl.isNotEmpty
                            ? CachedNetworkImage(imageUrl: item.posterUrl, fit: BoxFit.cover)
                            : Container(color: cs.surfaceContainerHigh)),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.black45,
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),

                    // Information details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              item.overview.isNotEmpty ? item.overview : 'Sin sinopsis disponible.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                final prefs = ref.read(soundPreferencesProvider);
                                SoundService.playClick(prefs);
                                context.push('/detail/${item.id}?type=${item.mediaType}');
                              },
                              icon: const Icon(Icons.play_arrow_rounded, size: 18),
                              label: const Text(
                                'Ver contenido',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
