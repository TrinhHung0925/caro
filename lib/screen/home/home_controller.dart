import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../route.dart';
import '../../service/audio_service.dart';

class HomeController extends GetxController {
  static const _kWinModeKey = 'win_mode';

  final _storage = GetStorage();

  late final AudioService _audio;

  var winMode = 5.obs;

  bool get isMusicEnabled => _audio.isMusicEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _audio = Get.find<AudioService>();
    winMode.value = _storage.read<int>(_kWinModeKey) ?? 5;
  }

  void setWinMode(int mode) {
    winMode.value = mode;
    _storage.write(_kWinModeKey, mode);
  }

  Future<void> toggleMusic(bool enabled) async {
    await _audio.toggleMusic(enabled);
    update();
  }

  void startGame() {
    Get.toNamed(
      AppPage.caro.routeName,
      arguments: {'winMode': winMode.value},
    );
  }

  void onBack() {
    Get.back();
  }
}
