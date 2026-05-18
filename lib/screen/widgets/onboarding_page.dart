import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/controller/onboarding_controller.dart';
import 'package:video_player/video_player.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            // 🎥 Video
            controller.isReady.value
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.videoController.value.size.width,
                        height: controller.videoController.value.size.height,
                        child: VideoPlayer(controller.videoController),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),

            // 🌫 overlay
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),

            // 📱 content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Voyagez malin avec TuniTrain',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
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

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
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
      }),
    );
  }
}
