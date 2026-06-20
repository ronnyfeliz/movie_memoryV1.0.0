import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MoviePoster extends StatelessWidget {
  final String? imageUrl;
  final double borderRadius;
  final double? width;
  final double? height;
  final Object? heroTag;
  final BoxFit fit;
  final bool useHero;

  const MoviePoster({
    super.key,
    this.imageUrl,
    this.borderRadius = 12,
    this.width,
    this.height,
    this.heroTag,
    this.fit = BoxFit.cover,
    this.useHero = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final placeholderColor = cs.surfaceContainerHighest;

    Widget poster;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      poster = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: fit,
              placeholder: (_, __) => Container(color: placeholderColor),
              errorWidget: (_, __, ___) => _placeholder(cs, placeholderColor),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      poster = _placeholder(cs, placeholderColor);
    }

    if (heroTag != null && useHero) {
      poster = Hero(tag: heroTag!, child: poster);
    }

    if (width != null || height != null) {
      poster = SizedBox(width: width, height: height, child: poster);
    }

    return poster;
  }

  Widget _placeholder(ColorScheme cs, Color placeholderColor) {
    return Container(
      color: placeholderColor,
      child: Icon(Icons.movie, color: cs.onSurfaceVariant),
    );
  }
}
