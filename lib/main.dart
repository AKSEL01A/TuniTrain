import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tuni_train/controller/onboarding_controller.dart';
import 'package:tuni_train/screen/page/accueil/car_details_page.dart';
import 'package:tuni_train/screen/page/accueil/place_details_page.dart';

// Firebase Configurations
import 'firebase_options.dart';

// Controllers & Deciders
import 'root_decider.dart';
import 'package:tuni_train/controller/auth/auth_controller.dart';
import 'package:tuni_train/controller/home_controlle.dart';

// Screens & Pages Imports
import 'package:tuni_train/screen/page/auth/login.dart';
import 'package:tuni_train/screen/page/mon_journee/mon_jourene_page.dart';
import 'package:tuni_train/screen/page/payments/payment_page.dart';
import 'package:tuni_train/screen/page/payments/payment_success_page.dart';
import 'package:tuni_train/screen/page/purchase/tickets/search_train.dart';
import 'package:tuni_train/screen/page/purchase/tickets/panel_page.dart';
import 'package:tuni_train/screen/page/map/stations_map_page.dart';
import 'package:tuni_train/screen/page/purchase/subscription_page.dart';
import 'package:tuni_train/screen/page/purchase/services/services_home_page.dart';

import 'package:tuni_train/screen/widgets/home_screen.dart';
import 'package:tuni_train/screen/widgets/onboarding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ AuthController فقط هو permanent — OnboardingController يتحمل فقط لما يلزم
  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tuni Train',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),

      home: const RootDecider(),

      getPages: [
        // ✅ OnboardingPage بـ binding منفصل يتحكم في دورة حياة الـ controller
        GetPage(
          name: '/onboarding',
          page: () => OnboardingPage(),
          binding: OnboardingBinding(),
        ),
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
        GetPage(
          name: '/payment',
          page: () => const PaymentPage(),
          binding: PaymentBinding(),
        ),
        GetPage(name: '/payment_success', page: () => PaymentSuccessPage()),
        GetPage(
          name: '/my-journeys',
          page: () => MyJourneyPage(),
          binding: MyJourneyBinding(),
        ),
        GetPage(name: '/subscription', page: () => SubscriptionPage()),
        GetPage(name: '/TunisiaTrainData', page: () => StationsMapPage()),
        GetPage(name: '/placesdetail', page: () => const PlaceDetailPage()),
        GetPage(
          name: '/carsdetail',
          page: () => const CarDetailPage(),
          binding: CarBinding(),
        ),
        GetPage(name: '/services', page: () => ServicesHomePage()),
      ],
    );
  }
}

// ✅ Binding منفصل للـ Onboarding — يتمسح تلقائياً لما تتعدى الصفحة
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
