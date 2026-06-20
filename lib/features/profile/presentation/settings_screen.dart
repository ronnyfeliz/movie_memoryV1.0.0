import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/sound/sound_provider.dart';
import '../../../core/sound/sound_service.dart';
import '../../../core/notification/notification_provider.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _languages = [
    'es', 'en', 'pt', 'it', 'fr', 'ru', 'ko', 'ja', 'zh',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeProvider);
    final soundPrefs = ref.watch(soundPreferencesProvider);
    final notifPrefs = ref.watch(notificationPreferencesProvider);
    final l10n = AppLocalizations.of(context)!;

    final isWide = MediaQuery.of(context).size.width > 600;
    // WindowInsets / safe area insets at the bottom + default Material 3 NavigationBar height (80)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomPadding = 16.0 + (isWide ? 0.0 : 80.0) + bottomInset;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
        children: [
          _SectionTitle(l10n.language),
          const SizedBox(height: 8),
          ..._languages.map((code) {
            final isSelected = currentLocale.languageCode == code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                tileColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : (Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent),
                ),
                title: Text(
                  LocaleNotifier.languageName(code),
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () => ref.read(localeProvider.notifier).setLocale(code),
              ),
            );
          }),
          const SizedBox(height: 24),
          _SectionTitle(l10n.theme),
          const SizedBox(height: 8),
          _ThemeSelector(currentTheme: currentTheme),
          const SizedBox(height: 24),
          _SectionTitle(l10n.notifications),
          const SizedBox(height: 8),
          _NotificationSettings(notifPrefs: notifPrefs),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          _SectionTitle(l10n.soundSettings),
          const SizedBox(height: 8),
          _SoundSettings(soundPrefs: soundPrefs),
          const SizedBox(height: 24),
          _SectionTitle(l10n.playbackLanguage),
          const SizedBox(height: 8),
          const _PlaybackLanguageSettings(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold));
  }
}

class _ThemeSelector extends ConsumerWidget {
  final AppTheme currentTheme;
  const _ThemeSelector({required this.currentTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: AppTheme.values.map((theme) {
        final isSelected = currentTheme == theme;
        final label = switch (theme) {
          AppTheme.light => AppLocalizations.of(context)!.light,
          AppTheme.dark => AppLocalizations.of(context)!.dark,
          AppTheme.system => AppLocalizations.of(context)!.systemTheme,
        };
        final icon = switch (theme) {
          AppTheme.light => Icons.light_mode,
          AppTheme.dark => Icons.dark_mode,
          AppTheme.system => Icons.settings_brightness,
        };
        return Expanded(
          child: GestureDetector(
            onTap: () => ref.read(themeProvider.notifier).setTheme(theme),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : (Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent),
              ),
              child: Column(
                children: [
                  Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, size: 28),
                  const SizedBox(height: 6),
                  Text(label, style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NotificationSettings extends ConsumerWidget {
  final NotificationPreferences notifPrefs;
  const _NotificationSettings({required this.notifPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SwitchListTile(
          title: Text(l10n.notifications, style: const TextStyle(fontSize: 14)),
          value: notifPrefs.enabled,
          activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          activeThumbColor: Theme.of(context).colorScheme.primary,
          onChanged: (v) => ref.read(notificationPreferencesProvider.notifier).setEnabled(v),
        ),
        if (notifPrefs.enabled) ...[
          const SizedBox(height: 8),
          ...NotificationMode.values.map((mode) {
            final isSelected = notifPrefs.mode == mode;
            final label = switch (mode) {
              NotificationMode.normal => l10n.normal,
              NotificationMode.popup => l10n.popup,
              NotificationMode.both => l10n.both,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                tileColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : (Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent),
                ),
                title: Text(label, style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
                trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () => ref.read(notificationPreferencesProvider.notifier).setMode(mode),
              ),
            );
          }),
        ],
        const SizedBox(height: 8),
        ListTile(
          tileColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
          title: Text(l10n.contentPreferencesNotif, style: const TextStyle(fontSize: 14)),
          trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: () {
            final prefs = ref.read(soundPreferencesProvider);
            SoundService.playClick(prefs);
            context.push('/onboarding');
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFE8E8E8) : Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
          title: Text('Personalizar notificaciones', style: const TextStyle(fontSize: 14)),
          trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: () {
            final prefs = ref.read(soundPreferencesProvider);
            SoundService.playClick(prefs);
            context.push('/notification-settings');
          },
        ),
      ],
    );
  }
}

class _SoundSettings extends ConsumerWidget {
  final SoundPreferences soundPrefs;
  const _SoundSettings({required this.soundPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final entries = [
      (l10n.openAppSound, 'openApp', soundPrefs.openAppSound),
      (l10n.clickSound, 'click', soundPrefs.clickSound),
      (l10n.addSound, 'add', soundPrefs.addSound),
      (l10n.confirmSound, 'confirm', soundPrefs.confirmSound),
      (l10n.removeSound, 'remove', soundPrefs.removeSound),
      (l10n.errorSound, 'error', soundPrefs.errorSound),
      (l10n.notificationSound, 'notification', soundPrefs.notificationSound),
    ];

    return Column(
      children: [
        SwitchListTile(
          title: Text(l10n.silentMode),
          subtitle: Text(l10n.silentModeDesc, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          value: soundPrefs.silentMode,
          activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          activeThumbColor: Theme.of(context).colorScheme.primary,
          onChanged: (v) => ref.read(soundPreferencesProvider.notifier).toggle('silent', v),
        ),
        ...entries.map((e) {
          final label = e.$1;
          final key = e.$2;
          final value = e.$3;
          return SwitchListTile(
            title: Text(label, style: const TextStyle(fontSize: 14)),
            value: value,
            activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (v) => ref.read(soundPreferencesProvider.notifier).toggle(key, v),
          );
        }),
      ],
    );
  }
}

class _PlaybackLanguageSettings extends ConsumerStatefulWidget {
  const _PlaybackLanguageSettings();

  @override
  ConsumerState<_PlaybackLanguageSettings> createState() => _PlaybackLanguageSettingsState();
}

class _PlaybackLanguageSettingsState extends ConsumerState<_PlaybackLanguageSettings> {
  late SharedPreferences _prefs;
  bool _initialized = false;
  String _audioLang = 'user';
  String _subtitleLang = 'user';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _audioLang = _prefs.getString('pref_default_audio_lang') ?? 'user';
      _subtitleLang = _prefs.getString('pref_default_subtitle_lang') ?? 'user';
      _initialized = true;
    });
  }

  Future<void> _setAudioLang(String value) async {
    setState(() {
      _audioLang = value;
    });
    await _prefs.setString('pref_default_audio_lang', value);
  }

  Future<void> _setSubtitleLang(String value) async {
    setState(() {
      _subtitleLang = value;
    });
    await _prefs.setString('pref_default_subtitle_lang', value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final l10n = AppLocalizations.of(context)!;
    final decoration = InputDecoration(
      filled: true,
      fillColor: isLight ? const Color(0xFFE8E8E8) : cs.surfaceContainerHighest,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.defaultAudioLanguage,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _audioLang,
          decoration: decoration,
          dropdownColor: isLight ? const Color(0xFFE8E8E8) : cs.surfaceContainerHighest,
          style: TextStyle(color: cs.onSurface, fontSize: 14),
          items: [
            DropdownMenuItem(value: 'user', child: Text(l10n.appLanguage)),
            DropdownMenuItem(value: 'system', child: Text(l10n.systemLanguage)),
            DropdownMenuItem(value: 'es', child: Text(l10n.spanish)),
            DropdownMenuItem(value: 'en', child: Text(l10n.english)),
            DropdownMenuItem(value: 'original', child: Text(l10n.originalLanguage)),
          ],
          onChanged: (v) {
            if (v != null) {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              _setAudioLang(v);
            }
          },
        ),
        const SizedBox(height: 14),
        Text(
          l10n.defaultSubtitleLanguage,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _subtitleLang,
          decoration: decoration,
          dropdownColor: isLight ? const Color(0xFFE8E8E8) : cs.surfaceContainerHighest,
          style: TextStyle(color: cs.onSurface, fontSize: 14),
          items: [
            DropdownMenuItem(value: 'user', child: Text(l10n.appLanguage)),
            DropdownMenuItem(value: 'system', child: Text(l10n.systemLanguage)),
            DropdownMenuItem(value: 'es', child: Text(l10n.spanish)),
            DropdownMenuItem(value: 'en', child: Text(l10n.english)),
            DropdownMenuItem(value: 'original', child: Text(l10n.originalLanguage)),
            DropdownMenuItem(value: 'disabled', child: Text(l10n.subtitlesDisabled)),
          ],
          onChanged: (v) {
            if (v != null) {
              final prefs = ref.read(soundPreferencesProvider);
              SoundService.playClick(prefs);
              _setSubtitleLang(v);
            }
          },
        ),
      ],
    );
  }
}
