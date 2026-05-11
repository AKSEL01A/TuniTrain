import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';

class OnboardingController extends GetxController {
  late VideoPlayerController videoController;

  final isReady = false.obs;

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initVideo();
  }

  Future<void> _initVideo() async {
    videoController = VideoPlayerController.asset('assets/videos/OnBV.mp4');

    await videoController.initialize();

    videoController
      ..setLooping(true)
      ..play();

    isReady.value = true;
  }

  void completeOnboarding() {
    storage.write('hasSeenOnboarding', true);
    videoController.pause();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    videoController.dispose();
    super.onClose();
  }
}
