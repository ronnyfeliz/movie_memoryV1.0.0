import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'sound_provider.dart' as pref;

class SoundService {
  static final AudioContext _audioContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gain,
      stayAwake: false,
    ),
  );

  static final _players = <String, AudioPlayer>{};

  static Future<void> _play(String path) async {
    var player = _players[path];
    if (player == null) {
      player = AudioPlayer();
      _players[path] = player;

      player.onPlayerStateChanged.listen((state) {
        debugPrint('[SoundService] $path → state: $state');
      });
      
      try {
        await player.setAudioContext(_audioContext);
      } catch (e) {
        debugPrint('[SoundService] Error setting audio context: $e');
      }
    } else {
      try {
        await player.stop();
      } catch (_) {}
    }

    try {
      await player.setSource(AssetSource(path));
      await player.resume();
      debugPrint('[SoundService] $path → resume OK');
    } catch (e, stack) {
      debugPrint('[SoundService] $path → EXCEPTION: $e\n$stack');
    }
  }

  static Future<void> playOpenApp(pref.SoundPreferences? prefs) async {
    if (prefs == null || prefs.silentMode || !prefs.openAppSound) return;
    await _play('sound/open_app.wav');
  }

  static Future<void> playClick(pref.SoundPreferences? prefs) async {
    if (prefs == null || prefs.silentMode || !prefs.clickSound) return;
    await _play('sound/click_sound.mp3');
  }

  static Future<void> playAdd(pref.SoundPreferences? prefs) async {
    if (prefs == null || prefs.silentMode || !prefs.addSound) return;
    await _play('sound/add_sound.wav');
  }

  static Future<void> playConfirm(pref.SoundPreferences? prefs) async {
    if (prefs == null || prefs.silentMode || !prefs.confirmSound) return;
    await _play('sound/confirm_sound.wav');
  }

  static Future<void> playRemove(pref.SoundPreferences? prefs) async {
    if (prefs == null || prefs.silentMode || !prefs.removeSound) return;
    await _play('sound/remove_sound.wav');
  }

  static Future<void> playError(pref.SoundPreferences? prefs) async {
    if (prefs == null || prefs.silentMode || !prefs.errorSound) return;
    await _play('sound/error_sound.flac');
  }

  static Future<void> playNotification(pref.SoundPreferences? prefs) async {
    if (prefs == null || prefs.silentMode || !prefs.notificationSound) return;
    await _play('sound/notification_sound.wav');
  }
}
