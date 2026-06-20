import 'package:flutter/material.dart';
import '../../core/player/playback_manager.dart';

class QualityLevelInfo {
  final int index;
  final String label;
  final int width;
  final int height;
  final int bitrate;
  final bool enabled;

  const QualityLevelInfo({
    required this.index,
    required this.label,
    required this.width,
    required this.height,
    required this.bitrate,
    required this.enabled,
  });

  factory QualityLevelInfo.fromJson(Map<String, dynamic> json) {
    return QualityLevelInfo(
      index: json['index'] as int? ?? 0,
      label: json['label'] as String? ?? 'Unknown',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      bitrate: json['bitrate'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  String get displayLabel {
    if (height > 0) return '${height}p';
    return label;
  }

  String get bitrateLabel {
    if (bitrate <= 0) return '';
    if (bitrate >= 1000000) return '${(bitrate / 1000000).toStringAsFixed(1)} Mbps';
    return '${(bitrate / 1000).round()} kbps';
  }
}

class QualitySelector extends StatelessWidget {
  final PlaybackManager manager;
  final List<QualityLevelInfo> levels;
  final ValueChanged<int?> onSelectQuality;

  const QualitySelector({
    super.key,
    required this.manager,
    required this.levels,
    required this.onSelectQuality,
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
            child: Text(
              'Calidad',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (levels.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Calidad automática',
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
                itemCount: levels.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    final isAuto = manager.selectedQuality == null;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isAuto
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          color: isAuto ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        ),
                        child: isAuto
                            ? const Icon(Icons.check, color: Colors.white, size: 12)
                            : null,
                      ),
                      title: Text(
                        'Automática',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: isAuto ? 0.95 : 0.7),
                          fontWeight: isAuto ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => onSelectQuality(null),
                    );
                  }
                  final level = levels[i - 1];
                  final isSelected = manager.selectedQuality == level.index;
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
                      level.displayLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: isSelected ? 0.95 : 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: level.bitrateLabel.isNotEmpty
                        ? Text(
                            level.bitrateLabel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 11,
                            ),
                          )
                        : null,
                    onTap: () {
                      if (isSelected) {
                        onSelectQuality(null);
                      } else {
                        onSelectQuality(level.index);
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
