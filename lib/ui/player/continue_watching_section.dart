import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../services/watch_history_service.dart';
import '../../services/watch_history_model.dart';
import '../../core/sound/sound_service.dart';
import '../../core/sound/sound_provider.dart';

final watchHistoryProvider = StreamProvider<List<WatchHistoryEntry>>((ref) {
  return WatchHistoryService.watchAll();
});

class ContinueWatchingSection extends ConsumerWidget {
  const ContinueWatchingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(watchHistoryProvider);

    return history.when(
      loading: () => _buildShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        final filtered = items.where((e) => e.percentage < 0.95).toList();
        if (filtered.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continuar viendo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                padding: const EdgeInsets.only(right: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _ContinueWatchingCard(entry: filtered[i]),
              ),
            ),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 4),
          child: Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: 5,
            itemBuilder: (_, __) => _ShimmerCard(),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 160, color: Colors.white10),
                const SizedBox(height: 8),
                Container(height: 10, width: 100, color: Colors.white10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueWatchingCard extends ConsumerWidget {
  final WatchHistoryEntry entry;
  const _ContinueWatchingCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final pct = entry.percentage.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () async {
        final prefs = ref.read(soundPreferencesProvider);
        await SoundService.playClick(prefs);
        if (!context.mounted) return;
        String type = entry.type;
        if (type != 'movie' && type != 'tv') {
          type = entry.season != null ? 'tv' : 'movie';
        }
        context.push('/detail/${entry.tmdbId}?type=$type');
      },
      child: _CardSwipeWrapper(
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    entry.posterPath != null && entry.posterPath!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: 'https://image.tmdb.org/t/p/w342${entry.posterPath}',
                            width: 280,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(Icons.movie_outlined, color: cs.onSurfaceVariant.withValues(alpha: 0.4), size: 40),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.primary,
                                ),
                                minHeight: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(pct * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    if (entry.seasonEpisodeLabel.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.seasonEpisodeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.play_circle_fill_rounded, size: 14, color: cs.primary),
                        const SizedBox(width: 5),
                        Text(
                          entry.timeRemaining.isNotEmpty
                              ? '${entry.timeRemaining} restantes'
                              : 'Seguir viendo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, size: 16, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSwipeWrapper extends StatefulWidget {
  final Widget child;
  const _CardSwipeWrapper({required this.child});

  @override
  State<_CardSwipeWrapper> createState() => _CardSwipeWrapperState();
}

class _CardSwipeWrapperState extends State<_CardSwipeWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
