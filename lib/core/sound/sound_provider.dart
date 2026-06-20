import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundPreferences {
  bool silentMode;
  bool openAppSound;
  bool clickSound;
  bool addSound;
  bool confirmSound;
  bool removeSound;
  bool errorSound;
  bool notificationSound;

  SoundPreferences({
    this.silentMode = false,
    this.openAppSound = true,
    this.clickSound = true,
    this.addSound = true,
    this.confirmSound = true,
    this.removeSound = true,
    this.errorSound = true,
    this.notificationSound = true,
  });

  static const _prefix = 'sound_';

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}silent', silentMode);
    await prefs.setBool('${_prefix}openApp', openAppSound);
    await prefs.setBool('${_prefix}click', clickSound);
    await prefs.setBool('${_prefix}add', addSound);
    await prefs.setBool('${_prefix}confirm', confirmSound);
    await prefs.setBool('${_prefix}remove', removeSound);
    await prefs.setBool('${_prefix}error', errorSound);
    await prefs.setBool('${_prefix}notification', notificationSound);
  }

  static Future<SoundPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SoundPreferences(
      silentMode: prefs.getBool('${_prefix}silent') ?? false,
      openAppSound: prefs.getBool('${_prefix}openApp') ?? true,
      clickSound: prefs.getBool('${_prefix}click') ?? true,
      addSound: prefs.getBool('${_prefix}add') ?? true,
      confirmSound: prefs.getBool('${_prefix}confirm') ?? true,
      removeSound: prefs.getBool('${_prefix}remove') ?? true,
      errorSound: prefs.getBool('${_prefix}error') ?? true,
      notificationSound: prefs.getBool('${_prefix}notification') ?? true,
    );
  }
}

final soundPreferencesProvider = StateNotifierProvider<SoundPreferencesNotifier, SoundPreferences>((ref) {
  return SoundPreferencesNotifier();
});

class SoundPreferencesNotifier extends StateNotifier<SoundPreferences> {
  SoundPreferencesNotifier() : super(SoundPreferences());

  Future<void> load() async {
    state = await SoundPreferences.load();
  }

  Future<void> toggle(String key, bool value) async {
    state = SoundPreferences(
      silentMode: key == 'silent' ? value : state.silentMode,
      openAppSound: key == 'openApp' ? value : state.openAppSound,
      clickSound: key == 'click' ? value : state.clickSound,
      addSound: key == 'add' ? value : state.addSound,
      confirmSound: key == 'confirm' ? value : state.confirmSound,
      removeSound: key == 'remove' ? value : state.removeSound,
      errorSound: key == 'error' ? value : state.errorSound,
      notificationSound: key == 'notification' ? value : state.notificationSound,
    );
    await state.save();
  }
}
