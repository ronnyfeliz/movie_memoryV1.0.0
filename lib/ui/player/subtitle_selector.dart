import 'package:flutter/material.dart';
import '../../core/player/playback_manager.dart';

class SubtitleTrackInfo {
  final int index;
  final String label;
  final String language;
  final String kind;
  final bool enabled;

  const SubtitleTrackInfo({
    required this.index,
    required this.label,
    required this.language,
    required this.kind,
    required this.enabled,
  });

  factory SubtitleTrackInfo.fromJson(Map<String, dynamic> json) {
    return SubtitleTrackInfo(
      index: json['index'] as int? ?? 0,
      label: json['label'] as String? ?? 'Unknown',
      language: json['language'] as String? ?? '',
      kind: json['kind'] as String? ?? 'subtitles',
      enabled: json['enabled'] as bool? ?? false,
    );
  }
}

class SubtitleSelector extends StatelessWidget {
  final PlaybackManager manager;
  final List<SubtitleTrackInfo> tracks;
  final bool subsEnabled;
  final ValueChanged<bool> onToggleSubtitles;
  final ValueChanged<int?> onSelectTrack;

  const SubtitleSelector({
    super.key,
    required this.manager,
    required this.tracks,
    required this.subsEnabled,
    required this.onToggleSubtitles,
    required this.onSelectTrack,
  });

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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Subtítulos',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: subsEnabled,
                  onChanged: onToggleSubtitles,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),
          if (tracks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No hay subtítulos disponibles',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: tracks.length,
                itemBuilder: (_, i) {
                  final track = tracks[i];
                  final isSelected = manager.selectedSubtitleTrack == track.index;
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 12)
                          : null,
                    ),
                    title: Text(
                      track.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: isSelected ? 0.95 : 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      track.language.isNotEmpty ? track.language.toUpperCase() : track.kind,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                      ),
                    ),
                    onTap: () {
                      if (isSelected) {
                        onSelectTrack(null);
                      } else {
                        onSelectTrack(track.index);
                      }
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
