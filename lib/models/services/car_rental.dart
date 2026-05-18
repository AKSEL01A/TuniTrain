import 'package:flutter/material.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum FuelType { electric, petrol, diesel, hybrid }

enum TransmissionType { automatic, manual }

enum CarCategory { economy, luxury, sedan, suv, van }

extension FuelTypeX on FuelType {
  String get label => switch (this) {
    FuelType.electric => 'Électrique',
    FuelType.petrol   => 'Essence',
    FuelType.diesel   => 'Diesel',
    FuelType.hybrid   => 'Hybride',
  };

  IconData get icon => switch (this) {
    FuelType.electric => Icons.electric_bolt_rounded,
    FuelType.petrol   => Icons.local_gas_station_rounded,
    FuelType.diesel   => Icons.local_gas_station_rounded,
    FuelType.hybrid   => Icons.eco_rounded,
  };
}

extension TransmissionTypeX on TransmissionType {
  String get label => switch (this) {
    TransmissionType.automatic => 'Automatique',
    TransmissionType.manual    => 'Manuelle',
  };
}

extension CarCategoryX on CarCategory {
  String get label => switch (this) {
    CarCategory.economy => 'Économique',
    CarCategory.luxury  => 'Luxe',
    CarCategory.sedan   => 'Berline',
    CarCategory.suv     => 'SUV',
    CarCategory.van     => 'Van',
  };
}

// ─── Model ───────────────────────────────────────────────────────────────────

class CarRental {
  final int id;
  final String companyName;
  final String brand;
  final String model;
  final int year;
  final String location;
  final double latitude;
  final double longitude;
  final FuelType fuelType;
  final TransmissionType transmission;
  final CarCategory category;
  final double pricePerDay;
  final bool available;
  final double rating;
  final int reviewsCount;
  final int seats;
  final int luggageCapacity;
  final bool featured;
  final List<String> imageUrls;
  final List<String> amenities;
  final List<DateTime> unavailableDates;
  bool isFavorite;

  CarRental({
    required this.id,
    required this.companyName,
    required this.brand,
    required this.model,
    required this.year,
    required this.location,
    this.latitude = 36.8189,
    this.longitude = 10.1658,
    required this.fuelType,
    required this.transmission,
    required this.category,
    required this.pricePerDay,
    this.available = true,
    this.rating = 4.0,
    this.reviewsCount = 0,
    this.seats = 5,
    this.luggageCapacity = 2,
    this.featured = false,
    this.imageUrls = const [],
    this.amenities = const [],
    this.unavailableDates = const [],
    this.isFavorite = false,
  });

  String get displayName => '$brand $model ($year)';

  CarRental copyWith({
    int? id,
    String? companyName,
    String? brand,
    String? model,
    int? year,
    String? location,
    double? latitude,
    double? longitude,
    FuelType? fuelType,
    TransmissionType? transmission,
    CarCategory? category,
    double? pricePerDay,
    bool? available,
    double? rating,
    int? reviewsCount,
    int? seats,
    int? luggageCapacity,
    bool? featured,
    List<String>? imageUrls,
    List<String>? amenities,
    List<DateTime>? unavailableDates,
    bool? isFavorite,
  }) {
    return CarRental(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      category: category ?? this.category,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      available: available ?? this.available,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      seats: seats ?? this.seats,
      luggageCapacity: luggageCapacity ?? this.luggageCapacity,
      featured: featured ?? this.featured,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      unavailableDates: unavailableDates ?? this.unavailableDates,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory CarRental.fromJson(Map<String, dynamic> json) {
    return CarRental(
      id: json['id'] as int,
      companyName: json['companyName'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      location: json['location'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 36.8189,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 10.1658,
      fuelType: FuelType.values.byName(json['fuelType'] as String),
      transmission: TransmissionType.values.byName(json['transmission'] as String),
      category: CarCategory.values.byName(json['category'] as String),
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      available: json['available'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      seats: json['seats'] as int? ?? 5,
      luggageCapacity: json['luggageCapacity'] as int? ?? 2,
      featured: json['featured'] as bool? ?? false,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'brand': brand,
    'model': model,
    'year': year,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'fuelType': fuelType.name,
    'transmission': transmission.name,
    'category': category.name,
    'pricePerDay': pricePerDay,
    'available': available,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'seats': seats,
    'luggageCapacity': luggageCapacity,
    'featured': featured,
    'imageUrls': imageUrls,
    'amenities': amenities,
    'isFavorite': isFavorite,
  };
}
