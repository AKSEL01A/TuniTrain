import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/data/services/service_booking_repository.dart';
import 'package:tuni_train/models/services/booking.dart';

class ServiceBookingController extends GetxController {
  final ServiceBookingRepository _repo;

  ServiceBookingController({ServiceBookingRepository? repo})
    : _repo = repo ?? MockServiceBookingRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final hasError = false.obs;
  final isCancelling = false.obs;

  final allBookings = <Booking>[].obs;
  final selectedBooking = Rx<Booking?>(null);
  final selectedTab = 0.obs;

  // ── Derived ───────────────────────────────────────────────────────────────
  List<Booking> get activeBookings =>
      allBookings.where((b) => b.isActive).toList();

  List<Booking> get pastBookings => allBookings.where((b) => b.isPast).toList();

  int get activeCount => activeBookings.length;
  int get pastCount => pastBookings.length;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> loadBookings() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final bookings = await _repo.getUserBookings('user1');
      allBookings.assignAll(bookings);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reloadBookings() async => loadBookings();

  // ── Tab management ────────────────────────────────────────────────────────
  void setTab(int index) => selectedTab.value = index;

  // ── Selection ─────────────────────────────────────────────────────────────
  void selectBooking(Booking booking) {
    selectedBooking.value = booking;
    Get.toNamed('/services/booking-detail');
  }

  // ── Cancellation ──────────────────────────────────────────────────────────
  Future<void> cancelBooking(String id) async {
    final confirmed = await _showCancelDialog();
    if (!confirmed) return;

    isCancelling.value = true;
    try {
      final success = await _repo.cancelBooking(
        id,
        reason: 'Annulé par le client',
      );
      if (success) {
        await loadBookings();
        Get.snackbar(
          'Réservation annulée',
          'Votre réservation a été annulée avec succès.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.greenBg,
          colorText: AppColors.green,
          duration: const Duration(seconds: 3),
          titleText: Text(
            'Réservation annulée',
            style: GoogleFonts.poppins(
              color: AppColors.green,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          messageText: Text(
            'Votre réservation a été annulée avec succès.',
            style: GoogleFonts.poppins(color: AppColors.green, fontSize: 12),
          ),
        );
        if (Get.currentRoute == '/services/booking-detail') Get.back();
      }
    } catch (_) {
      Get.snackbar(
        'Erreur',
        "Impossible d'annuler la réservation.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.redBg,
        colorText: AppColors.red,
      );
    } finally {
      isCancelling.value = false;
    }
  }

  Future<bool> _showCancelDialog() async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Annuler la réservation ?',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cette action est irréversible. Voulez-vous continuer ?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(result: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.bluePale,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Non',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(result: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Annuler',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }
}

class ServiceBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ServiceBookingController());
  }
}
