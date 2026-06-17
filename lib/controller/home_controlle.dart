import 'package:get/get.dart';
import 'package:tuni_train/controller/accueil/accueil_controller.dart';
import 'package:tuni_train/controller/mon_journee/my_journey_controller.dart';
import 'package:tuni_train/controller/purchase/services/car_rental_controller.dart';
import 'package:tuni_train/controller/purchase/subscription_controller.dart';
import 'package:tuni_train/controller/purchase/ticket_controller.dart';
import 'package:tuni_train/controller/trains/search_train_controller.dart';
import 'package:tuni_train/controller/purchase/panel_controller.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(AccueilController());
  }
}

class SearchTrainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchTrainController());
  }
}

class PanelBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PanelController());
  }
}

class MyJourneyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MyJourneyController());
  }
}

class CarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CarRentalController(), permanent: true);
  }
}

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketController>(() => TicketController());
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
    Get.lazyPut<PanelController>(() => PanelController());
  }
}
