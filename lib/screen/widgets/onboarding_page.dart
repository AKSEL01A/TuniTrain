import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/controller/onboarding_controller.dart';
import 'package:video_player/video_player.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({super.key});

  // ✅ find بدل put — الـ controller محمول من قبل (RootDecider أو Binding)
  final controller = Get.find<OnboardingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (!controller.isReady.value ||
            !controller.videoController.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // ── VIDEO ────────────────────────────────────────────────────
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.videoController.value.size.width,
                  height: controller.videoController.value.size.height,
                  child: VideoPlayer(controller.videoController),
                ),
              ),
            ),

            // ── DARK OVERLAY ─────────────────────────────────────────────
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.45)),
            ),

            // ── CONTENT ──────────────────────────────────────────────────
            SafeArea(
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
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Réservez vos billets rapidement et facilement.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const SizedBox(height: 40),

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
                          'Commencer',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'Billets digitaux sécurisés',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
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
