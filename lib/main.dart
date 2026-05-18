import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tuni_train/controller/auth/auth_controller.dart';
import 'package:tuni_train/controller/home_controlle.dart';
import 'package:tuni_train/screen/page/auth/login.dart';
import 'package:tuni_train/screen/page/mon_journee/mon_jourene_page.dart';
import 'package:tuni_train/screen/page/payments/payment_page.dart';
import 'package:tuni_train/screen/page/payments/payment_success_page.dart';
import 'package:tuni_train/screen/page/purchase/tickets/search_train.dart';
import 'package:tuni_train/screen/page/purchase/tickets/panel_page.dart';
import 'package:tuni_train/screen/page/map/stations_map_page.dart';
import 'package:tuni_train/screen/page/purchase/subscription_page.dart';
import 'package:tuni_train/screen/page/purchase/services/services_home_page.dart';
import 'package:tuni_train/screen/page/purchase/services/car_rental_list_page.dart';
import 'package:tuni_train/screen/page/purchase/services/car_detail_page.dart';
import 'package:tuni_train/screen/page/purchase/services/places_list_page.dart';
import 'package:tuni_train/screen/page/purchase/services/place_detail_page.dart';
import 'package:tuni_train/screen/page/purchase/services/my_bookings_page.dart';
import 'package:tuni_train/screen/page/purchase/services/booking_detail_page.dart';
import 'package:tuni_train/screen/widgets/home_screen.dart';
import 'package:tuni_train/screen/widgets/onboarding_page.dart';
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

        // ── Services ──────────────────────────────────────────────────────
        GetPage(name: '/services', page: () => ServicesHomePage()),
        GetPage(name: '/services/cars', page: () => CarRentalListPage()),
        GetPage(name: '/services/car-detail', page: () => CarDetailPage()),
        GetPage(name: '/services/places', page: () => PlacesListPage()),
        GetPage(name: '/services/place-detail', page: () => PlaceDetailPage()),
        GetPage(name: '/services/bookings', page: () => MyBookingsPage()),
        GetPage(
          name: '/services/booking-detail',
          page: () => BookingDetailPage(),
        ),
      ],
    );
  }
}
