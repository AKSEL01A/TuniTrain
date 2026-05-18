import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tuni_train/controller/purchase/services/service_booking_controller.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/constants/date_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/booking.dart';
import 'package:tuni_train/screen/widgets/booking_card.dart';

class BookingDetailPage extends StatelessWidget {
  BookingDetailPage({super.key});

  final ServiceBookingController ctrl = Get.find<ServiceBookingController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final booking = ctrl.selectedBooking.value;
      if (booking == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.blue1),
          ),
        );
      }
      return _BookingDetailScaffold(booking: booking, ctrl: ctrl);
    });
  }
}

class _BookingDetailScaffold extends StatelessWidget {
  final Booking booking;
  final ServiceBookingController ctrl;

  const _BookingDetailScaffold({required this.booking, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _BookingDetailHeader(booking: booking),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.section,
                AppSpacing.section,
                AppSpacing.section,
                AppSpacing.pagePad,
              ),
              child: Column(
                children: [
                  _BookingStatusBanner(booking: booking),
                  const SizedBox(height: AppSpacing.section),
                  if (booking.isActive && booking.qrCodeData.isNotEmpty)
                    _BookingQrCard(booking: booking),
                  if (booking.isActive && booking.qrCodeData.isNotEmpty)
                    const SizedBox(height: AppSpacing.section),
                  _BookingInfoCard(booking: booking),
                  const SizedBox(height: AppSpacing.section),
                  _BookingServiceDetailsCard(booking: booking),
                  const SizedBox(height: AppSpacing.section),
                  _BookingPricingCard(booking: booking),
                  if (booking.isActive) ...[
                    const SizedBox(height: AppSpacing.section),
                    _CancelButton(booking: booking, ctrl: ctrl),
                  ],
                  const SizedBox(height: AppSpacing.pagePad),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _BookingDetailHeader extends StatelessWidget {
  final Booking booking;

  const _BookingDetailHeader({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.section,
            AppSpacing.sm,
            AppSpacing.section,
            AppSpacing.pagePad,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détail Réservation',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Réf: ${booking.reference}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              BookingStatusChip(status: booking.status),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status banner ────────────────────────────────────────────────────────────

class _BookingStatusBanner extends StatelessWidget {
  final Booking booking;

  const _BookingStatusBanner({required this.booking});

  Color get _bg => switch (booking.status) {
    BookingStatus.confirmed => AppColors.greenBg,
    BookingStatus.pending => AppColors.sandBg,
    BookingStatus.cancelled => AppColors.redBg,
    BookingStatus.completed => AppColors.bluePale,
    BookingStatus.expired => const Color(0xFFF0F0F0),
  };

  Color get _fg => switch (booking.status) {
    BookingStatus.confirmed => AppColors.green,
    BookingStatus.pending => AppColors.sand,
    BookingStatus.cancelled => AppColors.red,
    BookingStatus.completed => AppColors.blue2,
    BookingStatus.expired => AppColors.blue3,
  };

  IconData get _icon => switch (booking.status) {
    BookingStatus.confirmed => Icons.check_circle_rounded,
    BookingStatus.pending => Icons.schedule_rounded,
    BookingStatus.cancelled => Icons.cancel_rounded,
    BookingStatus.completed => Icons.done_all_rounded,
    BookingStatus.expired => Icons.timer_off_rounded,
  };

  String get _message => switch (booking.status) {
    BookingStatus.confirmed => 'Votre réservation est confirmée.',
    BookingStatus.pending => 'En attente de confirmation.',
    BookingStatus.cancelled =>
      booking.cancellationReason != null
          ? 'Annulée : ${booking.cancellationReason}'
          : 'Réservation annulée.',
    BookingStatus.completed => 'Réservation terminée.',
    BookingStatus.expired => 'Réservation expirée.',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        border: Border.all(color: _fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _fg, size: 22),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Text(
              _message,
              style: GoogleFonts.poppins(
                color: _fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QR Card ──────────────────────────────────────────────────────────────────

class _BookingQrCard extends StatelessWidget {
  final Booking booking;

  const _BookingQrCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Scannez ce QR Code',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Présentez-le au moment du service',
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.section),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDE6F5), width: 2),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: QrImageView(
              data: booking.qrCodeData,
              version: QrVersions.auto,
              size: 200,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.blue1,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.blue1,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            booking.reference,
            style: GoogleFonts.poppins(
              color: AppColors.blue3,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Info ─────────────────────────────────────────────────────────────

class _BookingInfoCard extends StatelessWidget {
  final Booking booking;

  const _BookingInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final title =
        booking.serviceDetails['vehicle'] as String? ??
        booking.serviceDetails['place'] as String? ??
        booking.type.label;

    return _Card(
      title: 'Informations',
      child: Column(
        children: [
          _row('Service', booking.type.label),
          _row('Désignation', title),
          _row('Référence', booking.reference),
          _row('Date début', formatFrDateFull(booking.startDate)),
          if (booking.endDate != booking.startDate)
            _row('Date fin', formatFrDateFull(booking.endDate)),
          _row('Créé le', formatFrDateFull(booking.createdAt)),
          _row('Paiement', booking.paymentMethod),
          _row('Statut paiement', booking.paymentStatus.label),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.blue3,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Service Details ──────────────────────────────────────────────────────────

class _BookingServiceDetailsCard extends StatelessWidget {
  final Booking booking;

  const _BookingServiceDetailsCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    if (booking.serviceDetails.isEmpty) return const SizedBox.shrink();

    return _Card(
      title: 'Détails du service',
      child: Column(
        children: booking.serviceDetails.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _humanize(e.key),
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${e.value}',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _humanize(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .toLowerCase()
        .replaceFirst(key[0].toLowerCase(), key[0].toUpperCase());
  }
}

// ─── Pricing ──────────────────────────────────────────────────────────────────

class _BookingPricingCard extends StatelessWidget {
  final Booking booking;

  const _BookingPricingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _pricingRow('Sous-total', booking.subtotal),
          if (booking.taxes > 0) _pricingRow('Taxes', booking.taxes),
          if (booking.discount > 0)
            _pricingRow('Remise', -booking.discount, isDiscount: true),
          Divider(
            color: Colors.white.withValues(alpha: 0.2),
            height: AppSpacing.pagePad,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${booking.totalPrice.toStringAsFixed(3)} DT',
                style: GoogleFonts.poppins(
                  color: AppColors.sand,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pricingRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
          Text(
            '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(3)} DT',
            style: GoogleFonts.poppins(
              color: isDiscount ? AppColors.green : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cancel button ────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  final Booking booking;
  final ServiceBookingController ctrl;

  const _CancelButton({required this.booking, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: ctrl.isCancelling.value
            ? null
            : () => ctrl.cancelBooking(booking.id),
        child: Container(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          decoration: BoxDecoration(
            color: AppColors.redBg,
            borderRadius: BorderRadius.circular(AppRadius.cardLg),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: ctrl.isCancelling.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.red,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.red,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Annuler la réservation',
                        style: GoogleFonts.poppins(
                          color: AppColors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared card shell ────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}
