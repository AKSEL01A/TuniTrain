import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tuni_train/screen/widget/home_screen.dart';
import 'package:tuni_train/screen/widget/onboarding_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize GetStorage
  await GetStorage.init();

  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Check if user has seen onboarding
  final box = GetStorage();
  bool hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;

  runApp(MyApp(initialRoute: hasSeenOnboarding ? '/home' : '/onboarding'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tuni Train',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),

      // 3. Define Routes
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnboardingPage()),
        GetPage(
          name: '/home',
          page: () => const HomePageClient(),
        ), // Thabbet f esm el class mte3ek
      ],
    );
  }
}
