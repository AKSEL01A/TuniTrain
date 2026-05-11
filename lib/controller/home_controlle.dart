import 'package:get/get.dart';
import 'package:tuni_train/controller/accueil_controller.dart';
import 'package:tuni_train/controller/search_train_controller.dart';
import 'package:tuni_train/controller/panel_controller.dart';

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

