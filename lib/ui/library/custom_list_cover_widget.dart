import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/library/domain/custom_list_model.dart';
import '../../features/library/data/custom_list_provider.dart';

class CustomListCoverWidget extends ConsumerWidget {
  final CustomListModel list;
  final double height;
  final double width;
  final double borderRadius;
  final bool isClickable;
  final VoidCallback? onTap;

  const CustomListCoverWidget({
    super.key,
    required this.list,
    required this.height,
    required this.width,
    this.borderRadius = 12,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasCover = list.coverUrl != null && list.coverUrl!.isNotEmpty;
    final isAutoGrid = list.coverUrl == 'auto_grid';

    Widget content;

    if (isAutoGrid) {
      final postersAsync = ref.watch(listPostersProvider(list));
      content = postersAsync.when(
        data: (posters) {
          if (posters.isEmpty) {
            return _buildDefaultPlaceholder(theme, cs);
          }
          if (posters.length < 4) {
            // Repeat or fill to complete 2x2 grid
            final gridList = List<String>.generate(4, (index) => posters[index % posters.length]);
            return _buildPosterGrid(gridList);
          }
          return _buildPosterGrid(posters.take(4).toList());
        },
        loading: () => Container(
          color: theme.brightness == Brightness.light 
              ? const Color(0xFFE8E8E8) 
              : theme.colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => _buildDefaultPlaceholder(theme, cs),
      );
    } else if (hasCover) {
      content = CachedNetworkImage(
        imageUrl: list.coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => Container(
          color: theme.brightness == Brightness.light 
              ? const Color(0xFFE8E8E8) 
              : theme.colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => _buildDefaultPlaceholder(theme, cs),
      );
    } else {
      content = _buildDefaultPlaceholder(theme, cs);
    }

    if (isClickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(height: height, width: width, child: content),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(height: height, width: width, child: content),
    );
  }

  Widget _buildPosterGrid(List<String> posters) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0, // square grid cells
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: posters[index],
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: Colors.black26,
          ),
          errorWidget: (_, __, ___) => Container(
            color: Colors.black26,
            child: const Icon(Icons.movie_outlined, color: Colors.white30, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildDefaultPlaceholder(ThemeData theme, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.15),
            cs.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: height > 100 ? 44 : 22,
            color: cs.primary.withValues(alpha: 0.6),
          ),
          if (height > 100) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                list.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
