// 1. Enums
enum FuelType { ELECTRIC, PETROL, DIESEL, HYBRID }

enum TransmissionType { AUTOMATIC, MANUAL }

enum CarType { ECONOMY, LUXURY, SEDAN, SUV, VAN }

// 2. Class CarLocation
class CarLocation {
  int? id; // Long f'Java wallat int f'Dart
  String? companyName;
  String? location;
  String? brand;
  String? model;
  FuelType? fuelType;
  TransmissionType? transmission;
  CarType? carType;
  double? pricePerDay;
  bool available; // boolean wallat bool

  // Constructor
  CarLocation({
    this.id,
    this.companyName,
    this.location,
    this.brand,
    this.model,
    this.fuelType,
    this.transmission,
    this.carType,
    this.pricePerDay,
    this.available = true,
  });

  // Methods
  void bookCar() {
    // Logic bech ta3mel reservation
  }
}
