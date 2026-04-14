import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AudioService extends GetxService {
  static const _kMusicKey = 'music_enabled';

  final _player = AudioPlayer();
  final _storage = GetStorage();

  var isMusicEnabled = true.obs;

  /// Called by Get.putAsync in main.dart
  Future<AudioService> initialize() async {
    isMusicEnabled.value = _storage.read<bool>(_kMusicKey) ?? true;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.6);
    if (isMusicEnabled.value) {
      await _startMusic();
    }
    return this;
  }

  Future<void> _startMusic() async {
    await _player.play(AssetSource('audio/bg_music.mp3'));
  }

  Future<void> toggleMusic(bool enabled) async {
    isMusicEnabled.value = enabled;
    _storage.write(_kMusicKey, enabled);
    if (enabled) {
      await _startMusic();
    } else {
      await _player.stop();
    }
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
