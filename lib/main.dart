import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tuni_train/controller/home_controlle.dart';
import 'package:tuni_train/screen/page/payment_page.dart';
import 'package:tuni_train/screen/page/payment_success_page.dart';
import 'package:tuni_train/screen/page/qr_ticket_page.dart';
import 'package:tuni_train/screen/page/search_train.dart';
import 'package:tuni_train/screen/page/panel_page.dart';

import 'package:tuni_train/screen/widget/home_screen.dart';
import 'package:tuni_train/screen/widget/onboarding_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  // IMPORTANT: safe for both app + test
  await initializeDateFormatting('fr_FR', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        GetPage(name: '/ticket-qr', page: () => QrTicketPage()),

        GetPage(name: '/payment', page: () => const PaymentPage()),
        GetPage(name: '/payment_success', page: () => PaymentSuccessPage()),
      ],
    );
  }
}
