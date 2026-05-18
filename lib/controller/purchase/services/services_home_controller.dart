import 'package:get/get.dart';
import 'package:tuni_train/data/services/car_rental_repository.dart';
import 'package:tuni_train/data/services/place_repository.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/models/services/place.dart';

class ServicesHomeController extends GetxController {
  final CarRentalRepository _carRepo;
  final PlaceRepository _placeRepo;

  ServicesHomeController({
    CarRentalRepository? carRepo,
    PlaceRepository? placeRepo,
  }) : _carRepo = carRepo ?? MockCarRentalRepository(),
       _placeRepo = placeRepo ?? MockPlaceRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final featuredCars = <CarRental>[].obs;
  final featuredPlaces = <Place>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _carRepo.getFeaturedCars(),
        _placeRepo.getFeaturedPlaces(),
      ]);
      featuredCars.assignAll(results[0] as List<CarRental>);
      featuredPlaces.assignAll(results[1] as List<Place>);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reloadData() async => loadData();
}

class ServicesHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ServicesHomeController());
  }
}
