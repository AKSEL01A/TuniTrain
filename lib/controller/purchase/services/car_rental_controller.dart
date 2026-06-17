import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:tuni_train/models/services/car_rental.dart';

class CarRentalController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String carsCollection = 'carRentals';

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<CarRental> cars = <CarRental>[].obs;
  final RxList<CarRental> filteredCars = <CarRental>[].obs;

  final Rxn<CarRental> selectedCar = Rxn<CarRental>();
  final Rxn<CarCategory> selectedCategory = Rxn<CarCategory>();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCars();

    debounce<String>(
      searchQuery,
      (_) => applyFilters(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> reloadData() async {
    await loadCars();
  }

  Future<void> loadCars() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final snap = await _db.collection(carsCollection).get();

      final list = snap.docs.map(_carFromDoc).toList();

      cars.assignAll(list);
      applyFilters();
    } catch (e, st) {
      debugPrint('CarRentalController loadCars error: $e');
      debugPrint('$st');

      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCar(CarRental car) {
    selectedCar.value = car;

    // If you already have a details route, you can enable this:
    // Get.toNamed('/services/cars/details', arguments: car);
  }

  void clearSelectedCar() {
    selectedCar.value = null;
  }

  void setCategoryFilter(CarCategory? category) {
    selectedCategory.value = category;
    applyFilters();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void clearFilters() {
    selectedCategory.value = null;
    searchQuery.value = '';
    applyFilters();
  }

  void toggleFavorite(CarRental car) {
    car.isFavorite = !car.isFavorite;
    cars.refresh();
    filteredCars.refresh();
  }

  List<CarRental> get availableCars {
    return cars.where((car) => car.available).toList();
  }

  List<CarRental> get favoriteCars {
    return cars.where((car) => car.isFavorite).toList();
  }

  List<CarRental> get featuredCars {
    return cars.where((car) => car.featured).toList();
  }

  void applyFilters() {
    List<CarRental> result = List<CarRental>.from(cars);

    final category = selectedCategory.value;
    if (category != null) {
      result = result.where((car) => car.category == category).toList();
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((car) {
        return car.companyName.toLowerCase().contains(q) ||
            car.brand.toLowerCase().contains(q) ||
            car.model.toLowerCase().contains(q) ||
            car.location.toLowerCase().contains(q) ||
            car.displayName.toLowerCase().contains(q);
      }).toList();
    }

    filteredCars.assignAll(result);
  }

  CarRental _carFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});

    data['id'] = doc.id;

    data['companyName'] = _string(data['companyName'], fallback: 'Agence');
    data['brand'] = _string(data['brand'], fallback: 'Car');
    data['model'] = _string(data['model'], fallback: 'Model');
    data['year'] = _int(data['year'], fallback: DateTime.now().year);
    data['location'] = _string(data['location'], fallback: 'Tunisie');

    data['latitude'] = _double(data['latitude'], fallback: 36.8189);
    data['longitude'] = _double(data['longitude'], fallback: 10.1658);

    data['fuelType'] = _carFuel(data['fuelType']);
    data['transmission'] = _carTransmission(data['transmission']);
    data['category'] = _carCategory(data['category']);

    data['pricePerDay'] = _double(data['pricePerDay'], fallback: 0);
    data['available'] = _bool(data['available'], fallback: true);
    data['rating'] = _double(data['rating'], fallback: 4.0);
    data['reviewsCount'] = _int(data['reviewsCount'], fallback: 0);
    data['seats'] = _int(data['seats'], fallback: 5);
    data['luggageCapacity'] = _int(data['luggageCapacity'], fallback: 2);
    data['featured'] = _bool(data['featured'], fallback: false);

    data['imageUrls'] = _stringList(data['imageUrls']);
    data['amenities'] = _stringList(data['amenities']);

    return CarRental.fromJson(data);
  }

  String _string(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final s = value.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  int _int(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _double(dynamic value, {required double fallback}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _bool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value == null) return fallback;

    final s = value.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;

    return fallback;
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  String _carFuel(dynamic value) {
    final s = value?.toString().toLowerCase().trim() ?? '';

    if (s == 'electric' || s == 'électrique' || s == 'electrique') {
      return 'electric';
    }
    if (s == 'diesel' || s == 'gasoil') return 'diesel';
    if (s == 'hybrid' || s == 'hybride') return 'hybrid';
    if (s == 'petrol' || s == 'essence') return 'petrol';

    return 'petrol';
  }

  String _carTransmission(dynamic value) {
    final s = value?.toString().toLowerCase().trim() ?? '';

    if (s == 'automatic' || s == 'automatique' || s == 'auto') {
      return 'automatic';
    }
    if (s == 'manual' || s == 'manuelle' || s == 'manuel') {
      return 'manual';
    }

    return 'manual';
  }

  String _carCategory(dynamic value) {
    final s = value?.toString().toLowerCase().trim() ?? '';

    if (s == 'economy' || s == 'économique' || s == 'economique') {
      return 'economy';
    }
    if (s == 'comfort' || s == 'confort') return 'comfort';
    if (s == 'sedan' || s == 'berline') return 'sedan';
    if (s == 'suv') return 'suv';
    if (s == 'luxury' || s == 'luxe') return 'luxury';
    if (s == 'minibus') return 'minibus';
    if (s == 'electric' || s == 'électrique' || s == 'electrique') {
      return 'electric';
    }
    if (s == 'van') return 'van';

    return 'economy';
  }
}
