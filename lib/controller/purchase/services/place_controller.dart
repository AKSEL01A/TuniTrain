import 'package:get/get.dart';
import 'package:tuni_train/data/services/place_repository.dart';
import 'package:tuni_train/models/services/place.dart';

class PlaceController extends GetxController {
  final PlaceRepository _repo;

  PlaceController({PlaceRepository? repo})
    : _repo = repo ?? MockPlaceRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final hasError = false.obs;

  final allPlaces = <Place>[].obs;
  final displayedPlaces = <Place>[].obs;
  final featuredPlaces = <Place>[].obs;
  final selectedPlace = Rx<Place?>(null);
  final favoriteIds = <int>{}.obs;

  // ── Filter ────────────────────────────────────────────────────────────────
  final selectedCategory = Rx<PlaceCategory?>(null);
  final recommendedOnly = false.obs;
  final freeOnly = false.obs;

  bool get hasActiveFilter =>
      selectedCategory.value != null || recommendedOnly.value || freeOnly.value;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadPlaces();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> loadPlaces() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final places = await _repo.getPlaces();
      final featured = await _repo.getFeaturedPlaces();
      allPlaces.assignAll(places);
      featuredPlaces.assignAll(featured);
      _applyFilter();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reloadPlaces() async => loadPlaces();

  // ── Filtering ─────────────────────────────────────────────────────────────
  void setCategoryFilter(PlaceCategory? category) {
    selectedCategory.value = category;
    _applyFilter();
  }

  void toggleRecommendedOnly() {
    recommendedOnly.value = !recommendedOnly.value;
    _applyFilter();
  }

  void toggleFreeOnly() {
    freeOnly.value = !freeOnly.value;
    _applyFilter();
  }

  void clearFilter() {
    selectedCategory.value = null;
    recommendedOnly.value = false;
    freeOnly.value = false;
    displayedPlaces.assignAll(allPlaces);
  }

  void _applyFilter() {
    var result = allPlaces.toList();
    if (selectedCategory.value != null) {
      result = result
          .where((p) => p.category == selectedCategory.value)
          .toList();
    }
    if (recommendedOnly.value) {
      result = result.where((p) => p.isRecommended).toList();
    }
    if (freeOnly.value) {
      result = result.where((p) => p.price == 0).toList();
    }
    displayedPlaces.assignAll(result);
  }

  // ── Favorites ─────────────────────────────────────────────────────────────
  void toggleFavorite(int placeId) {
    if (favoriteIds.contains(placeId)) {
      favoriteIds.remove(placeId);
    } else {
      favoriteIds.add(placeId);
    }
    final idx = allPlaces.indexWhere((p) => p.id == placeId);
    if (idx != -1) {
      allPlaces[idx].isFavorite = favoriteIds.contains(placeId);
    }
    _applyFilter();
  }

  bool isFavorite(int placeId) => favoriteIds.contains(placeId);

  // ── Navigation ─────────────────────────────────────────────────────────────
  void selectPlace(Place place) {
    selectedPlace.value = place;
    Get.toNamed('/services/place-detail');
  }
}

class PlaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlaceController());
  }
}
