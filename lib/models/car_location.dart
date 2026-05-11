enum FuelType { electric, petrol, diesel, hybrid }

enum TransmissionType { automatic, manual }

enum CarType { economy, luxury, sedan, suv, van }

class CarLocation {
  int? id;
  String? companyName;
  String? location;
  String? brand;
  String? model;
  FuelType? fuelType;
  TransmissionType? transmission;
  CarType? carType;
  double? pricePerDay;
  bool available;

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

  void bookCar() {
    // Logic bech ta3mel reservation
  }
}
