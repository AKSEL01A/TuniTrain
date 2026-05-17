import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tuni_train/controller/auth_controller.dart';
import 'package:tuni_train/controller/home_controlle.dart';
import 'package:tuni_train/screen/page/auth/login.dart';
import 'package:tuni_train/screen/page/my_journey_page.dart';
import 'package:tuni_train/screen/page/payment_page.dart';
import 'package:tuni_train/screen/page/payment_success_page.dart';
import 'package:tuni_train/screen/page/search_train.dart';
import 'package:tuni_train/screen/page/panel_page.dart';
import 'package:tuni_train/screen/page/stations_map_page.dart';
import 'package:tuni_train/screen/page/subscription_page.dart';
import 'package:tuni_train/screen/widget/home_screen.dart';
import 'package:tuni_train/screen/widget/onboarding_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  // IMPORTANT: safe for both app + test
  await initializeDateFormatting('fr_FR', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController(), permanent: true);
  final box = GetStorage();
  final bool hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;

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

      initialRoute: initialRoute,

      getPages: [
        GetPage(name: '/onboarding', page: () => const OnboardingPage()),
        GetPage(
          name: '/home',
          page: () => const HomePageClient(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/searchtrain',
          page: () => SearchTrainPage(),
          binding: SearchTrainBinding(),
        ),

        GetPage(
          name: '/panel',
          page: () => PanelPage(),
          binding: PanelBinding(),
        ),
        GetPage(name: '/login', page: () => LoginScreen()),

        GetPage(name: '/payment', page: () => const PaymentPage()),
        GetPage(name: '/payment_success', page: () => PaymentSuccessPage()),
        GetPage(
          name: '/my-journeys',
          page: () => MyJourneyPage(),
          binding: MyJourneyBinding(),
        ),
        GetPage(name: '/subscription', page: () => SubscriptionPage()),
        GetPage(name: '/TunisiaTrainData', page: () => StationsMapPage()),
      ],
    );
  }
}
