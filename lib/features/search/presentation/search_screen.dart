import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_memory/core/widgets/movie_poster.dart';
import 'package:movie_memory/core/widgets/shimmer_loading.dart';
import 'package:movie_memory/core/widgets/error_view.dart';
import 'package:movie_memory/core/widgets/empty_view.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/media_model.dart';
import '../../../core/cache/cache_provider.dart';
import 'package:movie_memory/core/sound/sound_service.dart';
import 'package:movie_memory/core/sound/sound_provider.dart';
import 'package:movie_memory/features/library/data/library_provider.dart';
import 'package:movie_memory/features/library/domain/library_item.dart';
import 'package:movie_memory/features/discover/data/discover_provider.dart';

final _debouncedQueryProvider = StateProvider<String>((ref) => '');

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(_debouncedQueryProvider.notifier).state = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(_debouncedQueryProvider);
    final results = ref.watch(cachedSearchProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          style: const TextStyle(fontSize: 16),
           decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () async {
                      final prefs = ref.read(soundPreferencesProvider);
                      await SoundService.playClick(prefs);
                      _controller.clear();
                      ref.read(_debouncedQueryProvider.notifier).state = '';
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
        ),
        elevation: 0,
      ),
      body: query.isEmpty
          ? EmptyView(icon: Icons.search, message: l10n.searchHintEmpty)
          : results.when(
              loading: () => GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const ShimmerLoading(),
              ),
              error: (e, _) => ErrorView(message: '${l10n.error}: $e'),
              data: (items) => items.isEmpty
                  ? EmptyView(icon: Icons.search_off, message: l10n.noResultsSearch)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _SearchCard(item: items[i]),
                    ),
      ),
    );
  }
}

class _FavoriteBadge extends ConsumerWidget {
  final int tmdbId;
  final String mediaType;
  final bool isFav;
  final LibraryItem? libItem;
  const _FavoriteBadge({
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
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : Colors.white,
          size: 14,
        ),
      ),
    );
  }
}

class _SearchCard extends ConsumerWidget {
  final MediaModel item;
  const _SearchCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libItem = ref.watch(libraryItemByTmdbIdProvider(item.id));
    final isFav = libItem.valueOrNull?.isFavorite ?? false;
    return GestureDetector(
      onTap: () async {
        final prefs = ref.read(soundPreferencesProvider);
        await SoundService.playClick(prefs);
        if (!context.mounted) return;
        context.push('/detail/${item.id}?type=${item.mediaType}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                MoviePoster(
                  imageUrl: item.posterUrl,
                  borderRadius: 10,
                  heroTag: 'poster_${item.id}_search',
                ),
                Positioned(
                  top: 4, right: 4,
                  child: _FavoriteBadge(
                    tmdbId: item.id,
                    mediaType: item.mediaType,
                    isFav: isFav,
                    libItem: libItem.valueOrNull,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
          if (item.year.isNotEmpty)
            Text(item.year, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}
