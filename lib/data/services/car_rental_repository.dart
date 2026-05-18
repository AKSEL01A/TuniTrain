import 'package:tuni_train/models/services/car_rental.dart';

// ─── Filters ─────────────────────────────────────────────────────────────────

class CarRentalFilters {
  final FuelType? fuelType;
  final TransmissionType? transmission;
  final CarCategory? category;
  final double? maxPrice;
  final bool availableOnly;

  const CarRentalFilters({
    this.fuelType,
    this.transmission,
    this.category,
    this.maxPrice,
    this.availableOnly = false,
  });

  bool get hasFilters =>
      fuelType != null ||
      transmission != null ||
      category != null ||
      maxPrice != null ||
      availableOnly;

  CarRentalFilters copyWith({
    FuelType? fuelType,
    TransmissionType? transmission,
    CarCategory? category,
    double? maxPrice,
    bool? availableOnly,
  }) {
    return CarRentalFilters(
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      category: category ?? this.category,
      maxPrice: maxPrice ?? this.maxPrice,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }

  CarRentalFilters cleared() => const CarRentalFilters();
}

// ─── Abstract repository ──────────────────────────────────────────────────────

abstract class CarRentalRepository {
  Future<List<CarRental>> getCars({CarRentalFilters? filters});
  Future<CarRental?> getCarById(int id);
  Future<List<CarRental>> getFeaturedCars();
}

// ─── Mock implementation ──────────────────────────────────────────────────────

class MockCarRentalRepository implements CarRentalRepository {
  static final List<CarRental> _cars = [
    CarRental(
      id: 1,
      companyName: 'Europcar Tunis',
      brand: 'Volkswagen',
      model: 'Golf',
      year: 2023,
      location: 'Gare de Tunis',
      latitude: 36.8189,
      longitude: 10.1658,
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      category: CarCategory.economy,
      pricePerDay: 55.0,
      available: true,
      rating: 4.7,
      reviewsCount: 128,
      seats: 5,
      luggageCapacity: 3,
      featured: true,
      imageUrls: [
        'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800',
        'https://images.unsplash.com/photo-1616440347437-b1c73416efc2?w=800',
      ],
      amenities: ['Climatisation', 'GPS', 'Bluetooth', 'USB'],
    ),
    CarRental(
      id: 2,
      companyName: 'Hertz Tunisia',
      brand: 'BMW',
      model: 'Série 3',
      year: 2023,
      location: 'Aéroport Tunis-Carthage',
      latitude: 36.8515,
      longitude: 10.2272,
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      category: CarCategory.luxury,
      pricePerDay: 145.0,
      available: true,
      rating: 4.9,
      reviewsCount: 87,
      seats: 5,
      luggageCapacity: 4,
      featured: true,
      imageUrls: [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
        'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800',
      ],
      amenities: [
        'Climatisation',
        'GPS',
        'Sièges chauffants',
        'Toit ouvrant',
        'Caméra recul',
      ],
    ),
    CarRental(
      id: 3,
      companyName: 'Budget Car Rental',
      brand: 'Toyota',
      model: 'Corolla',
      year: 2022,
      location: 'Sfax Centre',
      latitude: 34.7400,
      longitude: 10.7601,
      fuelType: FuelType.diesel,
      transmission: TransmissionType.manual,
      category: CarCategory.sedan,
      pricePerDay: 45.0,
      available: true,
      rating: 4.3,
      reviewsCount: 56,
      seats: 5,
      luggageCapacity: 3,
      featured: false,
      imageUrls: [
        'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800',
      ],
      amenities: ['Climatisation', 'Radio', 'USB'],
    ),
    CarRental(
      id: 4,
      companyName: 'Sixt Tunisia',
      brand: 'Hyundai',
      model: 'Tucson',
      year: 2023,
      location: 'Gare de Sousse',
      latitude: 35.8245,
      longitude: 10.6346,
      fuelType: FuelType.petrol,
      transmission: TransmissionType.automatic,
      category: CarCategory.suv,
      pricePerDay: 95.0,
      available: true,
      rating: 4.6,
      reviewsCount: 73,
      seats: 5,
      luggageCapacity: 5,
      featured: true,
      imageUrls: [
        'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800',
      ],
      amenities: ['Climatisation', 'GPS', 'Bluetooth', '4x4', 'Espace bagages'],
    ),
    CarRental(
      id: 5,
      companyName: 'Eco Drive',
      brand: 'Renault',
      model: 'Zoé',
      year: 2023,
      location: 'Tunis-Lac',
      latitude: 36.8400,
      longitude: 10.2100,
      fuelType: FuelType.electric,
      transmission: TransmissionType.automatic,
      category: CarCategory.economy,
      pricePerDay: 65.0,
      available: true,
      rating: 4.8,
      reviewsCount: 44,
      seats: 5,
      luggageCapacity: 2,
      featured: false,
      imageUrls: [
        'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800',
      ],
      amenities: ['Climatisation', 'Chargeur rapide', 'GPS', 'Zéro émissions'],
    ),
    CarRental(
      id: 6,
      companyName: 'Atlas Rent',
      brand: 'Mercedes',
      model: 'Sprinter',
      year: 2022,
      location: 'Gare de Bizerte',
      latitude: 37.2745,
      longitude: 9.8736,
      fuelType: FuelType.diesel,
      transmission: TransmissionType.manual,
      category: CarCategory.van,
      pricePerDay: 85.0,
      available: false,
      rating: 4.2,
      reviewsCount: 31,
      seats: 9,
      luggageCapacity: 10,
      featured: false,
      imageUrls: [
        'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800',
      ],
      amenities: ['Climatisation', 'Grande capacité', 'Idéal groupe'],
    ),
    CarRental(
      id: 7,
      companyName: 'Peugeot Rental',
      brand: 'Peugeot',
      model: '3008',
      year: 2023,
      location: 'Monastir Aéroport',
      latitude: 35.7584,
      longitude: 10.7541,
      fuelType: FuelType.hybrid,
      transmission: TransmissionType.automatic,
      category: CarCategory.suv,
      pricePerDay: 110.0,
      available: true,
      rating: 4.7,
      reviewsCount: 62,
      seats: 5,
      luggageCapacity: 4,
      featured: true,
      imageUrls: [
        'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800',
      ],
      amenities: ['Hybride', 'GPS', 'Toit panoramique', 'Sièges cuir'],
    ),
    CarRental(
      id: 8,
      companyName: 'Tunis Car',
      brand: 'Dacia',
      model: 'Duster',
      year: 2022,
      location: 'Gare de Nabeul',
      latitude: 36.4513,
      longitude: 10.7357,
      fuelType: FuelType.petrol,
      transmission: TransmissionType.manual,
      category: CarCategory.suv,
      pricePerDay: 55.0,
      available: true,
      rating: 4.4,
      reviewsCount: 89,
      seats: 5,
      luggageCapacity: 4,
      featured: false,
      imageUrls: [
        'https://images.unsplash.com/photo-1570733117311-d990c3816c47?w=800',
      ],
      amenities: ['Climatisation', '4x4', 'Budget idéal'],
    ),
  ];

  @override
  Future<List<CarRental>> getCars({CarRentalFilters? filters}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (filters == null || !filters.hasFilters) return List.from(_cars);

    return _cars.where((car) {
      if (filters.fuelType != null && car.fuelType != filters.fuelType) {
        return false;
      }
      if (filters.transmission != null &&
          car.transmission != filters.transmission) {
        return false;
      }
      if (filters.category != null && car.category != filters.category) {
        return false;
      }
      if (filters.maxPrice != null && car.pricePerDay > filters.maxPrice!) {
        return false;
      }
      if (filters.availableOnly && !car.available) return false;
      return true;
    }).toList();
  }

  @override
  Future<CarRental?> getCarById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _cars.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CarRental>> getFeaturedCars() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _cars.where((c) => c.featured && c.available).toList();
  }
}
