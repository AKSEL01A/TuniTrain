import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:tuni_train/screen/widgets/onboarding_page.dart';
import 'package:tuni_train/screen/widgets/home_screen.dart';
import 'package:tuni_train/screen/page/auth/login.dart';
import 'package:tuni_train/controller/onboarding_controller.dart';

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    final seen = box.read<bool>('hasSeenOnboarding') ?? false;

    if (!seen) {
      // ✅ نحمل الـ controller هنا مباشرة لأننا مش جايين من named route
      Get.put(OnboardingController());
      return OnboardingPage();
    }

    final logged = box.read<bool>('isLoggedIn') ?? false;
    if (!logged) {
      return LoginScreen();
    }

    return const HomePageClient();
  }
}
