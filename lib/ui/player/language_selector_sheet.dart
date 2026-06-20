import 'package:flutter/material.dart';
import '../../core/player/vod_models.dart';

class LanguageSelectorSheet extends StatelessWidget {
  final List<VodLanguage> audios;
  final List<VodLanguage> subtitles;
  final VodLanguage? selectedAudio;
  final VodLanguage? selectedSubtitle;
  final Function(VodLanguage) onAudioSelected;
  final Function(VodLanguage?) onSubtitleSelected;

  const LanguageSelectorSheet({
    super.key,
    required this.audios,
    required this.subtitles,
    this.selectedAudio,
    this.selectedSubtitle,
    required this.onAudioSelected,
    required this.onSubtitleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.red,
              tabs: [
                Tab(text: 'Audio'),
                Tab(text: 'Subtítulos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLanguageList(
                    context, 
                    audios, 
                    selectedAudio, 
                    (l) => onAudioSelected(l)
                  ),
                  _buildLanguageList(
                    context, 
                    [const VodLanguage(id: 'off', bcp47: 'off', label: 'Desactivados'), ...subtitles], 
                    selectedSubtitle ?? const VodLanguage(id: 'off', bcp47: 'off', label: 'Desactivados'), 
                    (l) => onSubtitleSelected(l.id == 'off' ? null : l)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList(
    BuildContext context, 
    List<VodLanguage> items, 
    VodLanguage? selected, 
    Function(VodLanguage) onSelect
  ) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selected?.id == item.id;
        return ListTile(
          title: Text(
            item.label,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: isSelected ? const Icon(Icons.check, color: Colors.red) : null,
          onTap: () {
            onSelect(item);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
