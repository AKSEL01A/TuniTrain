import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:tuni_train/data/services/alert.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/models/services/place.dart';

class AccueilController extends GetxController {
  final FirebaseFirestore _db;

  AccueilController({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  static const String alertsCollection = 'alerts';
  static const String carsCollection = 'carRentals';
  static const String placesCollection = 'places';

  final RxList<Alert> alerts = <Alert>[].obs;
  final RxBool isLoadingNews = false.obs;

  // All cars + places (no limit)
  final RxList<CarRental> featuredCars = <CarRental>[].obs;
  final RxList<Place> featuredPlaces = <Place>[].obs;

  final RxBool isLoadingData = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  List<Alert> get visibleAlerts {
    final now = DateTime.now();
    return alerts.where((a) {
      final notExpired = a.expiresAt == null || a.expiresAt!.isAfter(now);
      return a.isPublished && notExpired;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([loadAlerts(), loadServices()]);
  }

  // ── ALERTS ────────────────────────────────────────────────────────────────

  Future<void> loadAlerts() async {
    try {
      isLoadingNews.value = true;
      QuerySnapshot<Map<String, dynamic>> snap;
      try {
        snap = await _db
            .collection(alertsCollection)
            .where('isPublished', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get();
      } catch (_) {
        snap = await _db
            .collection(alertsCollection)
            .where('isPublished', isEqualTo: true)
            .limit(10)
            .get();
      }

      final list = snap.docs
          .map((doc) {
            try {
              return Alert.fromFirestore(doc);
            } catch (e) {
              debugPrint('❌ Alert parse error ${doc.id}: $e');
              return null;
            }
          })
          .whereType<Alert>()
          .toList();

      alerts.assignAll(list);
      debugPrint('✅ ALERTS: ${alerts.length}');
    } catch (e) {
      debugPrint('❌ loadAlerts: $e');
      alerts.clear();
    } finally {
      isLoadingNews.value = false;
    }
  }

  // ── SERVICES ──────────────────────────────────────────────────────────────

  Future<void> loadServices() async {
    try {
      isLoadingData.value = true;
      hasError.value = false;

      final results = await Future.wait([_fetchAllCars(), _fetchAllPlaces()]);

      featuredCars.assignAll(results[0] as List<CarRental>);
      featuredPlaces.assignAll(results[1] as List<Place>);

      debugPrint('✅ CARS: ${featuredCars.length}');
      debugPrint('✅ PLACES: ${featuredPlaces.length}');
    } catch (e) {
      debugPrint('❌ loadServices: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoadingData.value = false;
    }
  }

  // Fetch ALL cars — no featured filter, no limit
  Future<List<CarRental>> _fetchAllCars() async {
    var snap = await _db
        .collection(carsCollection)
        .where('available', isEqualTo: true)
        .get();

    if (snap.docs.isEmpty) {
      snap = await _db.collection(carsCollection).get();
    }

    debugPrint('🚗 Raw car docs: ${snap.docs.length}');
    return snap.docs.map(_carFromDoc).toList();
  }

  // Fetch ALL places — no recommended filter, no limit
  Future<List<Place>> _fetchAllPlaces() async {
    final snap = await _db.collection(placesCollection).get();
    debugPrint('📍 Raw place docs: ${snap.docs.length}');
    return snap.docs.map(_placeFromDoc).toList();
  }

  // ── MAPPERS ───────────────────────────────────────────────────────────────

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
    data['imageUrls'] = _imageList(data);
    data['amenities'] = _stringList(data['amenities']);
    data['description'] = _string(data['description'], fallback: '');
    data['phone'] = _string(data['phone'], fallback: '');
    data['whatsapp'] = _string(data['whatsapp'], fallback: '');
    return CarRental.fromJson(data);
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
    data['imageUrls'] = _imageList(data);
    data['tags'] = _stringList(data['tags']);
    data['isRecommended'] = _bool(data['isRecommended'], fallback: false);
    data['hasBooking'] = _bool(data['hasBooking'], fallback: false);
    return Place.fromJson(data);
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  static List<String> _imageList(Map<String, dynamic> data) {
    for (final key in ['imageUrls', 'images', 'photos']) {
      final v = data[key];
      if (v is List) {
        final urls = v
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (urls.isNotEmpty) return urls;
      }
    }
    for (final key in ['imageUrl', 'image', 'photo', 'thumbnail']) {
      final v = data[key];
      if (v != null && v.toString().trim().isNotEmpty) {
        return [v.toString().trim()];
      }
    }
    return const [];
  }

  static String _string(dynamic v, {required String fallback}) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  static int _int(dynamic v, {required int fallback}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  static double _double(dynamic v, {required double fallback}) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? fallback;
  }

  static bool _bool(dynamic v, {required bool fallback}) {
    if (v is bool) return v;
    if (v == null) return fallback;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'yes' || s == 'oui') return true;
    if (s == 'false' || s == '0' || s == 'no' || s == 'non') return false;
    return fallback;
  }

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _dateString(dynamic v) {
    if (v is Timestamp) return v.toDate().toIso8601String();
    if (v is DateTime) return v.toIso8601String();
    if (v is String && v.trim().isNotEmpty) return v;
    return DateTime.now().toIso8601String();
  }

  static String _carFuel(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? '';
    if (s.contains('elec')) return 'electric';
    if (s.contains('diesel') || s.contains('gasoil')) return 'diesel';
    if (s.contains('hybrid') || s.contains('hybride')) return 'hybrid';
    return 'petrol';
  }

  static String _carTransmission(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? '';
    if (s.contains('auto')) return 'automatic';
    return 'manual';
  }

  static String _carCategory(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? '';
    if (s.contains('econ') || s.contains('économ')) return 'economy';
    if (s.contains('comfort') || s.contains('confort')) return 'comfort';
    if (s.contains('sedan') || s.contains('berline')) return 'sedan';
    if (s.contains('suv')) return 'suv';
    if (s.contains('luxury') || s.contains('luxe')) return 'luxury';
    if (s.contains('minibus')) return 'minibus';
    if (s.contains('elec')) return 'electric';
    if (s.contains('van')) return 'van';
    return 'economy';
  }

  static String _placeCategory(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? '';
    if (s.contains('historic') || s.contains('site')) return 'historicSite';
    if (s.contains('restaurant')) return 'restaurant';
    if (s.contains('hotel') || s.contains('hôtel')) return 'hotel';
    if (s.contains('adventure') || s.contains('aventure')) return 'adventure';
    if (s.contains('entertain') || s.contains('loisir')) return 'entertainment';
    return 'historicSite';
  }
}
