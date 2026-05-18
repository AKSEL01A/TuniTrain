import 'package:tuni_train/models/services/booking.dart';

// ─── Abstract repository ──────────────────────────────────────────────────────

abstract class ServiceBookingRepository {
  Future<List<Booking>> getUserBookings(String userId);
  Future<Booking?> getBookingById(String id);
  Future<Booking> createBooking(Booking booking);
  Future<bool> cancelBooking(String id, {String? reason});
}

// ─── Mock implementation ──────────────────────────────────────────────────────

class MockServiceBookingRepository implements ServiceBookingRepository {
  final List<Booking> _bookings = [
    Booking(
      id: 'bk001',
      reference: 'TT-2024-0892',
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      subtotal: 110.0,
      taxes: 11.0,
      totalPrice: 121.0,
      type: BookingType.carRental,
      status: BookingStatus.confirmed,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: 'card',
      qrCodeData: 'TT-2024-0892|carRental|VW Golf|Europcar',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 5)),
      userId: 'user1',
      userName: 'Ahmed Bensalah',
      serviceDetails: {
        'vehicle': 'Volkswagen Golf 2023',
        'company': 'Europcar Tunis',
        'pickup': 'Gare de Tunis',
        'carId': 1,
      },
    ),
    Booking(
      id: 'bk002',
      reference: 'TT-2024-0754',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      subtotal: 24.0,
      taxes: 0.0,
      totalPrice: 24.0,
      type: BookingType.ticket,
      status: BookingStatus.confirmed,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: 'd17',
      qrCodeData: "TT-2024-0754|ticket|ElDjem|AdulteX2",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 10)),
      userId: 'user1',
      serviceDetails: {
        'place': "Amphithéâtre d'El Djem",
        'placeId': 1,
        'visitors': 2,
        'ticketType': 'Adulte',
      },
    ),
    Booking(
      id: 'bk003',
      reference: 'TT-2024-0643',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 8)),
      subtotal: 290.0,
      taxes: 29.0,
      discount: 58.0,
      totalPrice: 261.0,
      type: BookingType.carRental,
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: 'google',
      qrCodeData: 'TT-2024-0643|carRental|BMW Serie3|Hertz',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      userId: 'user1',
      serviceDetails: {
        'vehicle': 'BMW Série 3 2023',
        'company': 'Hertz Tunisia',
        'pickup': 'Aéroport Tunis-Carthage',
        'carId': 2,
      },
    ),
    Booking(
      id: 'bk004',
      reference: 'TT-2024-0521',
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      endDate: DateTime.now().subtract(const Duration(days: 20)),
      subtotal: 22.0,
      taxes: 0.0,
      totalPrice: 22.0,
      type: BookingType.ticket,
      status: BookingStatus.completed,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: 'card',
      qrCodeData: 'TT-2024-0521|ticket|Bardo|AdulteX2',
      createdAt: DateTime.now().subtract(const Duration(days: 22)),
      userId: 'user1',
      serviceDetails: {
        'place': 'Musée du Bardo',
        'placeId': 5,
        'visitors': 2,
        'ticketType': 'Adulte',
      },
    ),
    Booking(
      id: 'bk005',
      reference: 'TT-2024-0389',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 3)),
      subtotal: 75.0,
      taxes: 7.5,
      totalPrice: 82.5,
      type: BookingType.carRental,
      status: BookingStatus.cancelled,
      paymentStatus: PaymentStatus.refunded,
      paymentMethod: 'card',
      qrCodeData: '',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      cancellationReason: 'Changement de plans',
      userId: 'user1',
      serviceDetails: {
        'vehicle': 'Toyota Corolla 2022',
        'company': 'Budget Car Rental',
        'carId': 3,
      },
    ),
  ];

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _bookings.where((b) => b.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Booking?> getBookingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<bool> cancelBooking(String id, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx == -1) return false;
    _bookings[idx] = _bookings[idx].copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: reason,
      updatedAt: DateTime.now(),
    );
    return true;
  }
}
