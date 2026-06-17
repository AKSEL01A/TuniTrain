import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:tuni_train/models/services/place.dart';

class PlaceController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String placesCollection = 'places';

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Place> places = <Place>[].obs;
  final RxList<Place> filteredPlaces = <Place>[].obs;

  final Rxn<Place> selectedPlace = Rxn<Place>();
  final Rxn<PlaceCategory> selectedCategory = Rxn<PlaceCategory>();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlaces();

    debounce<String>(
      searchQuery,
      (_) => applyFilters(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> reloadData() async {
    await loadPlaces();
  }

  Future<void> loadPlaces() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final snap = await _db.collection(placesCollection).get();

      final list = snap.docs.map(_placeFromDoc).toList();

      places.assignAll(list);
      applyFilters();
    } catch (e, st) {
      debugPrint('PlaceController loadPlaces error: $e');
      debugPrint('$st');

      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectPlace(Place place) {
    selectedPlace.value = place;

    // If you already have a details route, you can enable this:
    // Get.toNamed('/services/places/details', arguments: place);
  }

  void clearSelectedPlace() {
    selectedPlace.value = null;
  }

  void setCategoryFilter(PlaceCategory? category) {
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

  void toggleFavorite(Place place) {
    place.isFavorite = !place.isFavorite;
    places.refresh();
    filteredPlaces.refresh();
  }

  List<Place> get recommendedPlaces {
    return places.where((place) => place.isRecommended).toList();
  }

  List<Place> get favoritePlaces {
    return places.where((place) => place.isFavorite).toList();
  }

  List<Place> get bookablePlaces {
    return places.where((place) => place.hasBooking).toList();
  }

  void applyFilters() {
    List<Place> result = List<Place>.from(places);

    final category = selectedCategory.value;
    if (category != null) {
      result = result.where((place) => place.category == category).toList();
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((place) {
        return place.name.toLowerCase().contains(q) ||
            place.location.toLowerCase().contains(q) ||
            place.description.toLowerCase().contains(q) ||
            place.tags.any((tag) => tag.toLowerCase().contains(q));
      }).toList();
    }

    filteredPlaces.assignAll(result);
  }

  Place _placeFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data() ?? {});

    data['id'] = doc.id;

    data['name'] = _string(data['name'], fallback: 'Place');
    data['location'] = _string(data['location'], fallback: 'Tunisie');

    data['latitude'] = _double(data['latitude'], fallback: 36.8189);
    data['longitude'] = _double(data['longitude'], fallback: 10.1658);

    if (data['price'] != null) {
      data['price'] = _double(data['price'], fallback: 0);
    }

    data['isTicketingEnabled'] = _bool(
      data['isTicketingEnabled'],
      fallback: false,
    );
    data['category'] = _placeCategory(data['category']);
    data['description'] = _string(data['description'], fallback: '');
    data['rating'] = _double(data['rating'], fallback: 4.0);
    data['reviewsCount'] = _int(data['reviewsCount'], fallback: 0);

    data['createdAt'] = _dateString(data['createdAt']);

    data['imageUrls'] = _stringList(data['imageUrls']);
    data['tags'] = _stringList(data['tags']);

    data['isRecommended'] = _bool(data['isRecommended'], fallback: false);
    data['hasBooking'] = _bool(data['hasBooking'], fallback: false);

    return Place.fromJson(data);
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

  String _dateString(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    if (value is String && value.trim().isNotEmpty) return value;
    return DateTime.now().toIso8601String();
  }

  String _placeCategory(dynamic value) {
    final s = value?.toString().toLowerCase().trim() ?? '';

    if (s == 'historicsite' ||
        s == 'historic_site' ||
        s == 'historic site' ||
        s == 'site historique') {
      return 'historicSite';
    }
    if (s == 'restaurant') return 'restaurant';
    if (s == 'hotel' || s == 'hôtel') return 'hotel';
    if (s == 'adventure' || s == 'aventure') return 'adventure';
    if (s == 'entertainment' || s == 'loisirs' || s == 'divertissement') {
      return 'entertainment';
    }

    return 'historicSite';
  }
}
