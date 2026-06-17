import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/models/purchase/booking.dart';

class BookingController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final RxList<Booking> bookings = <Booking>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  String? get _uid => _auth.currentUser?.uid;

  Future<void> loadBookings() async {
    if (_uid == null) return;
    isLoading.value = true;
    hasError.value = false;
    try {
      final snap = await _db
          .collection('bookings')
          .where('userId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .get();
      bookings.assignAll(snap.docs.map(Booking.fromFirestore).toList());
    } catch (e) {
      debugPrint('BookingController.load: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Crée la réservation + le paiement dans Firestore
  Future<void> reserve({
    required String type, // 'car' | 'place'
    required String itemId,
    required String title,
    required double amount,
    required String method, // 'Carte bancaire' | 'Espèces' | 'Virement'
    String? imageUrl,
  }) async {
    if (_uid == null) throw Exception('Non connecté');

    final now = Timestamp.now();
    final status = amount == 0 ? 'confirmed' : 'pending';

    // ── 1. Booking ────────────────────────────────────────────────────────
    final bookingRef = await _db.collection('bookings').add({
      'userId': _uid,
      'type': type,
      'itemId': itemId,
      'title': title,
      'imageUrl': imageUrl ?? '',
      'amount': amount,
      'method': method,
      'status': status,
      'createdAt': now,
      'updatedAt': now,
    });

    // ── 2. Payment (si montant > 0) ────────────────────────────────────
    if (amount > 0) {
      await _db.collection('payments').add({
        'userId': _uid,
        'bookingId': bookingRef.id,
        'type': type,
        'itemId': itemId,
        'title': title,
        'amount': amount,
        'method': method,
        'status': 'pending', // pending → confirmed par admin
        'createdAt': now,
      });
    }

    await loadBookings();
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': Timestamp.now(),
      });
      await loadBookings();
      Get.snackbar(
        'Annulé',
        'Réservation annulée',
        backgroundColor: const Color(0xFFE65100),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  // ── Derived ───────────────────────────────────────────────────────────────
  List<Booking> get pendingBookings =>
      bookings.where((b) => b.status == 'pending').toList();
  List<Booking> get confirmedBookings =>
      bookings.where((b) => b.status == 'confirmed').toList();
  List<Booking> get cancelledBookings =>
      bookings.where((b) => b.status == 'cancelled').toList();

  double get totalSpent => bookings
      .where((b) => b.status != 'cancelled')
      .fold(0, (sum, b) => sum + b.amount);
}
