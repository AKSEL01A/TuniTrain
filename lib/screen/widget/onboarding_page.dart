import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player/video_player.dart';

class OnboardingController extends GetxController {
  late VideoPlayerController controller;

  @override
  void onInit() {
    super.onInit();
    controller = VideoPlayerController.asset('assets/videos/OnBV.mp4')
      ..initialize().then((_) {
        controller.setLooping(true);
        controller.play();
        update();
      });
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }

  void completeOnboarding() {
    GetStorage().write('hasSeenOnboarding', true); // ← added
    controller.pause();
    Get.offAllNamed('/login');
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingController = Get.put(OnboardingController());

    return Scaffold(
      body: GetBuilder<OnboardingController>(
        builder: (_) {
          return Stack(
            children: [
              onboardingController.controller.value.isInitialized
                  ? SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width:
                              onboardingController.controller.value.size.width,
                          height:
                              onboardingController.controller.value.size.height,
                          child: VideoPlayer(onboardingController.controller),
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.4)),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Voyagez malin avec TuniTrain',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Réservez vos billets et profitez de nos services à bord en quelques clics.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 80),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        child: MaterialButton(
                          onPressed: onboardingController.completeOnboarding,
                          minWidth: double.infinity,
                          height: 55,
                          child: const Text(
                            "Commencer l'aventure",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Billets digitaux et services garantis",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
