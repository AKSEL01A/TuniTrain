import 'package:get/get.dart';
import 'package:tuni_train/data/services/car_rental_repository.dart';
import 'package:tuni_train/models/services/car_rental.dart';

class CarRentalController extends GetxController {
  final CarRentalRepository _repo;

  CarRentalController({CarRentalRepository? repo})
    : _repo = repo ?? MockCarRentalRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final hasError = false.obs;

  final allCars = <CarRental>[].obs;
  final displayedCars = <CarRental>[].obs;
  final featuredCars = <CarRental>[].obs;
  final selectedCar = Rx<CarRental?>(null);
  final favoriteIds = <int>{}.obs;

  // ── Filters ───────────────────────────────────────────────────────────────
  final selectedFuelType = Rx<FuelType?>(null);
  final selectedTransmission = Rx<TransmissionType?>(null);
  final selectedCategory = Rx<CarCategory?>(null);
  final availableOnly = false.obs;

  bool get hasActiveFilters =>
      selectedFuelType.value != null ||
      selectedTransmission.value != null ||
      selectedCategory.value != null ||
      availableOnly.value;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadCars();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> loadCars() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final cars = await _repo.getCars();
      final featured = await _repo.getFeaturedCars();
      allCars.assignAll(cars);
      featuredCars.assignAll(featured);
      _applyFilters();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reloadCars() async => loadCars();

  // ── Filtering ─────────────────────────────────────────────────────────────
  void setFuelFilter(FuelType? type) {
    selectedFuelType.value = type;
    _applyFilters();
  }

  void setTransmissionFilter(TransmissionType? type) {
    selectedTransmission.value = type;
    _applyFilters();
  }

  void setCategoryFilter(CarCategory? cat) {
    selectedCategory.value = cat;
    _applyFilters();
  }

  void toggleAvailableOnly() {
    availableOnly.value = !availableOnly.value;
    _applyFilters();
  }

  void clearFilters() {
    selectedFuelType.value = null;
    selectedTransmission.value = null;
    selectedCategory.value = null;
    availableOnly.value = false;
    displayedCars.assignAll(allCars);
  }

  void _applyFilters() {
    displayedCars.assignAll(
      allCars.where((car) {
        if (selectedFuelType.value != null &&
            car.fuelType != selectedFuelType.value) {
          return false;
        }
        if (selectedTransmission.value != null &&
            car.transmission != selectedTransmission.value) {
          return false;
        }
        if (selectedCategory.value != null &&
            car.category != selectedCategory.value) {
          return false;
        }
        if (availableOnly.value && !car.available) {
          return false;
        }
        return true;
      }).toList(),
    );
  }

  // ── Favorites ─────────────────────────────────────────────────────────────
  void toggleFavorite(int carId) {
    if (favoriteIds.contains(carId)) {
      favoriteIds.remove(carId);
    } else {
      favoriteIds.add(carId);
    }
    final idx = allCars.indexWhere((c) => c.id == carId);
    if (idx != -1) {
      allCars[idx].isFavorite = favoriteIds.contains(carId);
    }
    _applyFilters();
  }

  bool isFavorite(int carId) => favoriteIds.contains(carId);

  // ── Navigation ─────────────────────────────────────────────────────────────
  void selectCar(CarRental car) {
    selectedCar.value = car;
    Get.toNamed('/services/car-detail');
  }
}

class CarRentalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CarRentalController());
  }
}
