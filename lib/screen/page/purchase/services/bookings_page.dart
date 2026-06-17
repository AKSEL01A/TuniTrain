import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/purchase/services/booking_controller.dart';
import 'package:tuni_train/models/purchase/booking.dart';
import 'dart:convert';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 140,
            collapsedHeight: 64,
            pinned: true,
            backgroundColor: AppColors.blue1,
            leading: const SizedBox.shrink(),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue1, AppColors.blue2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: Get.back,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mes Réservations',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${c.bookings.length} réservation(s)',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Total spent
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total dépensé',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                                Text(
                                  '${c.totalSpent.toStringAsFixed(3)} DT',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blue1),
            );
          }
          if (c.bookings.isEmpty) {
            return _emptyBookings(c.loadBookings);
          }
          return RefreshIndicator(
            color: AppColors.blue1,
            onRefresh: c.loadBookings,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stats
                _statsRow(c),
                const SizedBox(height: 20),

                // Pending
                if (c.pendingBookings.isNotEmpty) ...[
                  _sectionTitle(
                    'En attente',
                    Icons.pending_rounded,
                    const Color(0xFFE65100),
                  ),
                  const SizedBox(height: 10),
                  ...c.pendingBookings.map(
                    (b) => _BookingCard(booking: b, ctrl: c),
                  ),
                  const SizedBox(height: 20),
                ],

                // Confirmed
                if (c.confirmedBookings.isNotEmpty) ...[
                  _sectionTitle(
                    'Confirmées',
                    Icons.check_circle_rounded,
                    AppColors.green,
                  ),
                  const SizedBox(height: 10),
                  ...c.confirmedBookings.map(
                    (b) => _BookingCard(booking: b, ctrl: c),
                  ),
                  const SizedBox(height: 20),
                ],

                // Cancelled
                if (c.cancelledBookings.isNotEmpty) ...[
                  _sectionTitle(
                    'Annulées',
                    Icons.cancel_rounded,
                    AppColors.red,
                  ),
                  const SizedBox(height: 10),
                  ...c.cancelledBookings.map(
                    (b) => _BookingCard(booking: b, ctrl: c),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _statsRow(BookingController c) => Obx(
    () => Row(
      children: [
        _statCard('${c.bookings.length}', 'Total', AppColors.blue1),
        const SizedBox(width: 10),
        _statCard(
          '${c.pendingBookings.length}',
          'En attente',
          const Color(0xFFE65100),
        ),
        const SizedBox(width: 10),
        _statCard(
          '${c.confirmedBookings.length}',
          'Confirmées',
          AppColors.green,
        ),
      ],
    ),
  );

  Widget _statCard(String v, String l, Color c) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            v,
            style: GoogleFonts.poppins(
              color: c,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            l,
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _sectionTitle(String t, IconData icon, Color c) => Row(
    children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Icon(icon, color: c, size: 16),
      const SizedBox(width: 6),
      Text(
        t,
        style: GoogleFonts.poppins(
          color: AppColors.blue1,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _emptyBookings(Future<void> Function() onRefresh) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.bluePale,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.blue3,
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Aucune réservation',
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Vos réservations apparaîtront ici',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.blue1,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Explorer les services',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final BookingController ctrl;
  const _BookingCard({required this.booking, required this.ctrl});

  static const _statusCfg = {
    'pending': (
      color: Color(0xFFE65100),
      icon: Icons.pending_rounded,
      label: 'En attente',
    ),
    'confirmed': (
      color: AppColors.green,
      icon: Icons.check_circle_rounded,
      label: 'Confirmée',
    ),
    'cancelled': (
      color: AppColors.red,
      icon: Icons.cancel_rounded,
      label: 'Annulée',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cfg =
        _statusCfg[booking.status] ??
        (
          color: AppColors.blue3,
          icon: Icons.help_rounded,
          label: booking.status,
        );
    final isPending = booking.status == 'pending';
    final isCancelled = booking.status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cfg.color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: cfg.color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cfg.color.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(color: cfg.color.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                Icon(cfg.icon, color: cfg.color, size: 14),
                const SizedBox(width: 6),
                Text(
                  cfg.label,
                  style: GoogleFonts.poppins(
                    color: cfg.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  _fmt(booking.createdAt),
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: _thumb(booking.imageUrl, booking.type),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (booking.isCar
                                          ? AppColors.blue1
                                          : AppColors.sand)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.isCar ? 'Voiture' : 'Lieu',
                              style: GoogleFonts.poppins(
                                color: booking.isCar
                                    ? AppColors.blue1
                                    : AppColors.sand,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.title,
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.payment_rounded,
                            size: 12,
                            color: AppColors.blue3,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.method,
                            style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      booking.amount > 0
                          ? '${booking.amount.toStringAsFixed(3)} DT'
                          : 'Gratuit',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _confirmCancel(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.redBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'Annuler',
                            style: GoogleFonts.poppins(
                              color: AppColors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  color: AppColors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Annuler la réservation ?',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Cette action est irréversible.',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.bgPage,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.bluePale),
                        ),
                        child: Center(
                          child: Text(
                            'Retour',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ctrl.cancelBooking(booking.id);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Confirmer',
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
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _thumb(String url, String type) {
    final fallback = Container(
      color: AppColors.bluePale,
      child: Icon(
        type == 'car' ? Icons.directions_car_rounded : Icons.landscape_rounded,
        color: AppColors.blue3,
        size: 28,
      ),
    );
    if (url.isEmpty) return fallback;
    if (url.startsWith('data:image')) {
      try {
        final bytes = base64Decode(url.split(',').last);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
