import 'package:flutter/material.dart';
import '../../core/player/playback_manager.dart';

class PlaybackSettings extends StatelessWidget {
  final PlaybackManager manager;

  const PlaybackSettings({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Configuración de reproducción',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (manager.mediaType == 'tv')
            SwitchListTile(
              title: Text(
                'Auto-siguiente episodio',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
              ),
              subtitle: Text(
                'Reproducir siguiente episodio automáticamente',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
              ),
            value: manager.autoNext,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (_) {
                manager.setAutoNext(!manager.autoNext);
                Navigator.pop(context);
              },
            ),
          SwitchListTile(
            title: Text(
              'Subtítulos',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
            ),
            subtitle: Text(
              'Mostrar subtítulos si están disponibles',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
            ),
            value: manager.subsEnabled,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (_) {
              manager.toggleSubtitles();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
