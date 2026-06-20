import 'package:flutter/material.dart';
import '../../core/player/language_manager.dart';
import '../../core/player/playback_manager.dart';

class LanguageSelector extends StatefulWidget {
  final PlaybackManager manager;

  const LanguageSelector({super.key, required this.manager});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLanguages = PlayerLanguage.known;
    final filtered = _searchQuery.isEmpty
        ? allLanguages
        : allLanguages.where((l) =>
            l.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            l.code.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Material(
      color: Colors.transparent,
      child: Container(
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
                'Idioma de audio',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar idioma...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: Colors.white.withValues(alpha: 0.4)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final lang = filtered[i];
                  final isSelected = lang == widget.manager.currentLang;

                  if (lang.code == 'ORIGINAL') {
                    return Column(
                      children: [
                        if (_searchQuery.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Row(
                              children: [
                                Text('IDIOMAS DISPONIBLES',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withValues(alpha: 0.35),
                                      letterSpacing: 0.5,
                                    )),
                                const Spacer(),
                                Text('${allLanguages.length - 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.35),
                                    )),
                              ],
                            ),
                          ),
                        _LanguageTile(lang: lang, isSelected: isSelected),
                      ],
                    );
                  }

                  return _LanguageTile(lang: lang, isSelected: isSelected);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final PlayerLanguage lang;
  final bool isSelected;

  const _LanguageTile({
    required this.lang,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : null,
        ),
        title: Text(
          lang.label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: isSelected ? 0.95 : 0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: Text(
          lang.code,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 12,
          ),
        ),
        onTap: () => Navigator.pop(context, lang),
      ),
    );
  }
}
