import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/models/services/place.dart';

class ServicesHomeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool   isLoading = false.obs;
  final RxBool   hasError  = false.obs;
  final RxString errorMsg  = ''.obs;

  final RxList<CarRental> cars   = <CarRental>[].obs;
  final RxList<Place>     places = <Place>[].obs;

  // ── Derived ───────────────────────────────────────────────────────────────
  List<CarRental> get featuredCars   => cars.where((c) => c.featured).toList();
  List<CarRental> get availableCars  => cars.where((c) => c.available).toList();
  List<CarRental> get favoriteCars   => cars.where((c) => c.isFavorite).toList();

  List<Place> get featuredPlaces  => places.where((p) => p.isRecommended).toList();
  List<Place> get bookablePlaces  => places.where((p) => p.hasBooking).toList();
  List<Place> get favoritePlaces  => places.where((p) => p.isFavorite).toList();
  List<Place> get recommendedPlaces => places.where((p) => p.isRecommended).toList();

  List<CarRental> carsByCategory(CarCategory cat) =>
      cars.where((c) => c.category == cat).toList();
  List<Place> placesByCategory(PlaceCategory cat) =>
      places.where((p) => p.category == cat).toList();

  @override
  void onInit() { super.onInit(); reloadData(); }

  Future<void> reloadData() async {
    try {
      isLoading.value = true;
      hasError.value  = false;
      errorMsg.value  = '';

      final results = await Future.wait([
        _db.collection('carRentals').get(),
        _db.collection('places').get(),
      ]);

      final carSnap   = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final placeSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;

      cars.assignAll(carSnap.docs.map(_carFromDoc).toList());
      places.assignAll(placeSnap.docs.map(_placeFromDoc).toList());
    } catch (e, st) {
      debugPrint('ServicesHomeController error: $e\n$st');
      hasError.value = true;
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleCarFavorite(CarRental car) {
    car.isFavorite = !car.isFavorite;
    cars.refresh();
  }

  void togglePlaceFavorite(Place place) {
    place.isFavorite = !place.isFavorite;
    places.refresh();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CAR PARSING
  // ══════════════════════════════════════════════════════════════════════════
  CarRental _carFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = Map<String, dynamic>.from(doc.data() ?? {});
    d['id'] = doc.id;
    return CarRental(
      id:              _str(d['id']),
      companyName:     _str(d['companyName'], fallback: 'Agence'),
      brand:           _str(d['brand'],       fallback: 'Car'),
      model:           _str(d['model'],       fallback: 'Model'),
      year:            _int(d['year'],         fallback: DateTime.now().year),
      location:        _str(d['location'],    fallback: 'Tunisie'),
      latitude:        _dbl(d['latitude'],    fallback: 36.8189),
      longitude:       _dbl(d['longitude'],   fallback: 10.1658),
      fuelType:        _fuelType(d['fuelType']),
      transmission:    _transmission(d['transmission']),
      category:        _carCategory(d['category']),
      pricePerDay:     _dbl(d['pricePerDay'], fallback: 0),
      available:       _bool(d['available'],  fallback: true),
      rating:          _dbl(d['rating'],      fallback: 4.0),
      reviewsCount:    _int(d['reviewsCount'],fallback: 0),
      seats:           _int(d['seats'],        fallback: 5),
      luggageCapacity: _int(d['luggageCapacity'], fallback: 2),
      featured:        _bool(d['featured'],   fallback: false),
      imageUrls:       _safeStrList(d['imageUrls']),   // ✅ fix
      amenities:       _safeStrList(d['amenities']),   // ✅ fix
      description:     d['description'] as String?,
      phone:           d['phone']        as String?,
      whatsapp:        d['whatsapp']     as String?,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PLACE PARSING
  // ══════════════════════════════════════════════════════════════════════════
  Place _placeFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = Map<String, dynamic>.from(doc.data() ?? {});
    d['id'] = doc.id;
    return Place(
      id:                 _str(d['id']),
      name:               _str(d['name'],     fallback: 'Lieu'),
      location:           _str(d['location'], fallback: 'Tunisie'),
      latitude:           _dbl(d['latitude'], fallback: 36.8189),
      longitude:          _dbl(d['longitude'],fallback: 10.1658),
      price:              d['price'] != null
          ? _dbl(d['price'], fallback: 0) : null,
      isTicketingEnabled: _bool(d['isTicketingEnabled'], fallback: false),
      category:           _placeCategory(d['category']),
      description:        _str(d['description'], fallback: ''),
      rating:             _dbl(d['rating'],      fallback: 4.0),
      reviewsCount:       _int(d['reviewsCount'],fallback: 0),
      externalLink:       d['externalLink']  as String?,
      createdAt:          _date(d['createdAt']),
      imageUrls:          _safeStrList(d['imageUrls']),   // ✅ fix
      openingHours:       d['openingHours']  as String?,
      phone:              d['phone']         as String?,
      email:              d['email']         as String?,
      tags:               _safeStrList(d['tags']),         // ✅ fix
      isRecommended:      _bool(d['isRecommended'], fallback: false),
      hasBooking:         _bool(d['hasBooking'],    fallback: false),
      promotionText:      d['promotionText']   as String?,
      socialInstagram:    d['socialInstagram'] as String?,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TYPE HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  String _str(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  int _int(dynamic v, {required int fallback}) {
    if (v is int)  return v;
    if (v is num)  return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  double _dbl(dynamic v, {required double fallback}) {
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    if (v is num)    return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? fallback;
  }

  bool _bool(dynamic v, {required bool fallback}) {
    if (v is bool) return v;
    if (v == null) return fallback;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true'  || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no')  return false;
    return fallback;
  }

  // ✅ FIX PRINCIPAL — gère List<dynamic> de Firestore + filtre null/vide
  List<String> _safeStrList(dynamic v) {
    if (v == null)  return const [];
    if (v is List) {
      return v
          .where((e) => e != null)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  // ← garde _strList pour compatibilité si utilisé ailleurs
  List<String> _strList(dynamic v) => _safeStrList(v);

  DateTime _date(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime)  return v;
    if (v is String && v.trim().isNotEmpty) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // ── Enum mappers ──────────────────────────────────────────────────────────
  FuelType _fuelType(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? '';
    if (s == 'electric'  || s == 'électrique' || s == 'electrique')
      return FuelType.electric;
    if (s == 'diesel'    || s == 'gasoil')  return FuelType.diesel;
    if (s == 'hybrid'    || s == 'hybride') return FuelType.hybrid;
    return FuelType.petrol;
  }

  TransmissionType _transmission(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? '';
    if (s == 'automatic' || s == 'automatique' || s == 'auto')
      return TransmissionType.automatic;
    return TransmissionType.manual;
  }

  CarCategory _carCategory(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? '';
    return switch (s) {
      'economy'  || 'économique' || 'economique' => CarCategory.economy,
      'comfort'  || 'confort'                    => CarCategory.comfort,
      'sedan'    || 'berline'                    => CarCategory.sedan,
      'suv'                                      => CarCategory.suv,
      'luxury'   || 'luxe'                       => CarCategory.luxury,
      'minibus'                                  => CarCategory.minibus,
      'electric' || 'électrique' || 'electrique' => CarCategory.electric,
      'van'                                      => CarCategory.van,
      _                                          => CarCategory.economy,
    };
  }

  PlaceCategory _placeCategory(dynamic v) {
    final s = v?.toString().toLowerCase().trim() ?? '';
    return switch (s) {
      'historicsite' || 'historic_site' ||
      'historic site' || 'site historique' => PlaceCategory.historicSite,
      'restaurant'                          => PlaceCategory.restaurant,
      'hotel' || 'hôtel'                    => PlaceCategory.hotel,
      'adventure' || 'aventure'             => PlaceCategory.adventure,
      'entertainment' || 'loisirs' ||
      'divertissement'                      => PlaceCategory.entertainment,
      _                                     => PlaceCategory.historicSite,
    };
  }
}