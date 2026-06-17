import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';

class OnboardingController extends GetxController {
  late VideoPlayerController videoController;

  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initVideo();
  }

  Future<void> _initVideo() async {
    videoController = VideoPlayerController.asset('assets/videos/OnBV.mp4');

    await videoController.initialize();
    await videoController.setLooping(true);
    await videoController.setVolume(1.0);

    isReady.value = true;

    // نبدأ نلعبوا بعد ما يتبنى الـ widget
    await Future.delayed(const Duration(milliseconds: 100));
    videoController.play();
  }

  Future<void> completeOnboarding() async {
    // ✅ نوقفوا قبل أي navigation
    await videoController.pause();
    await videoController.setVolume(0.0);

    // ✅ نكتبوا في الـ storage
    await GetStorage().write('hasSeenOnboarding', true);

    // ✅ نمشوا للـ login ونمسحوا كامل الـ stack
    Get.offAllNamed('/login');

    // ✅ الـ controller يتمسح تلقائياً بعد ما تتعدى الصفحة
    // لأننا استعملنا Get.put عادي (مش permanent)
  }

  @override
  void onClose() {
    // ✅ هذا يتنادى تلقائياً لما تتعدى الصفحة
    videoController.pause();
    videoController.setVolume(0.0);
    videoController.dispose();
    super.onClose();
  }
}
