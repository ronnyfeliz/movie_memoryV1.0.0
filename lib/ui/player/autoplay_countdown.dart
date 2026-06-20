import 'dart:async';
import 'package:flutter/material.dart';

class AutoplayCountdown extends StatefulWidget {
  final String title;
  final int nextSeason;
  final int nextEpisode;
  final VoidCallback onPlay;
  final VoidCallback onCancel;

  const AutoplayCountdown({
    super.key,
    required this.title,
    required this.nextSeason,
    required this.nextEpisode,
    required this.onPlay,
    required this.onCancel,
  });

  @override
  State<AutoplayCountdown> createState() => _AutoplayCountdownState();
}

class _AutoplayCountdownState extends State<AutoplayCountdown> {
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdown <= 1) {
        _timer?.cancel();
        widget.onPlay();
        return;
      }
      setState(() => _countdown--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Siguiente episodio en $_countdown segundos',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.title} · S${widget.nextSeason} · E${widget.nextEpisode.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () {
                _timer?.cancel();
                widget.onPlay();
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Reproducir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: () {
                _timer?.cancel();
                widget.onCancel();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                side: BorderSide(color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
              ),
              child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
