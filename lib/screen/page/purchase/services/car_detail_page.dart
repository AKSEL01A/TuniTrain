import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/purchase/services/car_rental_controller.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/screen/widgets/service_section_header.dart';

class CarDetailPage extends StatelessWidget {
  CarDetailPage({super.key});

  final CarRentalController ctrl = Get.find<CarRentalController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final car = ctrl.selectedCar.value;
      if (car == null) return const Scaffold();
      return Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _CarDetailAppBar(car: car, ctrl: ctrl),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.section,
                      AppSpacing.pagePad,
                      AppSpacing.section,
                      120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CarDetailTitle(car: car),
                        const SizedBox(height: AppSpacing.pagePad),
                        _CarSpecsCard(car: car),
                        const SizedBox(height: AppSpacing.section),
                        _CarAmenitiesCard(car: car),
                        const SizedBox(height: AppSpacing.section),
                        _CarPricingCard(car: car),
                        const SizedBox(height: AppSpacing.section),
                        _CarLocationCard(car: car),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom CTA
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _CarDetailCta(car: car),
            ),
          ],
        ),
      );
    });
  }
}

// ─── App Bar with image ───────────────────────────────────────────────────────

class _CarDetailAppBar extends StatelessWidget {
  final CarRental car;
  final CarRentalController ctrl;

  const _CarDetailAppBar({required this.car, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.blue1,
      leading: GestureDetector(
        onTap: Get.back,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      actions: [
        Obx(
          () => GestureDetector(
            onTap: () => ctrl.toggleFavorite(car.id),
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                ctrl.isFavorite(car.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: ctrl.isFavorite(car.id) ? AppColors.red : Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: car.imageUrls.isNotEmpty
            ? Image.network(
                car.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    color: AppColors.bluePale,
    child: const Center(
      child: Icon(
        Icons.directions_car_rounded,
        color: AppColors.blue3,
        size: 64,
      ),
    ),
  );
}

// ─── Title block ──────────────────────────────────────────────────────────────

class _CarDetailTitle extends StatelessWidget {
  final CarRental car;

  const _CarDetailTitle({required this.car});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                car.displayName,
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${car.pricePerDay.toStringAsFixed(0)} DT',
                  style: GoogleFonts.poppins(
                    color: AppColors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'par jour',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.business_rounded,
              size: 13,
              color: AppColors.blue3,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              car.companyName,
              style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 13),
            ),
            const SizedBox(width: AppSpacing.xl),
            StarRatingWidget(
              rating: car.rating,
              reviewsCount: car.reviewsCount,
              starSize: 13,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: car.available ? AppColors.greenBg : AppColors.redBg,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Text(
            car.available ? 'Disponible maintenant' : 'Indisponible',
            style: GoogleFonts.poppins(
              color: car.available ? AppColors.green : AppColors.red,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Specs card ───────────────────────────────────────────────────────────────

class _CarSpecsCard extends StatelessWidget {
  final CarRental car;

  const _CarSpecsCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Caractéristiques',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3.5,
        crossAxisSpacing: AppSpacing.section,
        mainAxisSpacing: AppSpacing.xl,
        children: [
          _specRow(car.fuelType.icon, 'Carburant', car.fuelType.label),
          _specRow(Icons.settings_rounded, 'Boîte', car.transmission.label),
          _specRow(Icons.person_rounded, 'Places', '${car.seats} places'),
          _specRow(
            Icons.luggage_rounded,
            'Bagages',
            '${car.luggageCapacity} valise(s)',
          ),
          _specRow(Icons.category_rounded, 'Catégorie', car.category.label),
          _specRow(Icons.calendar_today_rounded, 'Année', '${car.year}'),
        ],
      ),
    );
  }

  Widget _specRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.bluePale,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(icon, size: 15, color: AppColors.blue2),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 9),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Amenities card ───────────────────────────────────────────────────────────

class _CarAmenitiesCard extends StatelessWidget {
  final CarRental car;

  const _CarAmenitiesCard({required this.car});

  @override
  Widget build(BuildContext context) {
    if (car.amenities.isEmpty) return const SizedBox.shrink();
    return _DetailCard(
      title: 'Équipements inclus',
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: car.amenities
            .map(
              (a) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bluePale,
                  borderRadius: BorderRadius.circular(AppRadius.circle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: AppColors.blue2,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      a,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Pricing card ─────────────────────────────────────────────────────────────

class _CarPricingCard extends StatelessWidget {
  final CarRental car;

  const _CarPricingCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final price = car.pricePerDay;
    return _DetailCard(
      title: 'Tarifs',
      child: Row(
        children: [
          _priceChip('1 jour', price),
          const SizedBox(width: AppSpacing.md),
          _priceChip('3 jours', price * 3 * 0.9, badge: '-10%'),
          const SizedBox(width: AppSpacing.md),
          _priceChip('7 jours', price * 7 * 0.8, badge: '-20%'),
        ],
      ),
    );
  }

  Widget _priceChip(String label, double total, {String? badge}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.bluePale,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              const SizedBox(height: 14),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${total.toStringAsFixed(0)} DT',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location card ────────────────────────────────────────────────────────────

class _CarLocationCard extends StatelessWidget {
  final CarRental car;

  const _CarLocationCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Point de retrait',
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.blue1,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.location,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Voir sur la carte',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.blue3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CTA ──────────────────────────────────────────────────────────────────────

class _CarDetailCta extends StatelessWidget {
  final CarRental car;

  const _CarDetailCta({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.xl,
        AppSpacing.section,
        30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.cardXl),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Prix par jour',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 11,
                ),
              ),
              Text(
                '${car.pricePerDay.toStringAsFixed(0)} DT',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.pagePad),
          Expanded(
            child: GestureDetector(
              onTap: car.available
                  ? () => Get.snackbar(
                      'Réservation',
                      'Fonctionnalité de réservation bientôt disponible.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColors.bluePale,
                      colorText: AppColors.blue1,
                      duration: AppDurations.snackbar,
                    )
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: car.available
                      ? AppColors.ctaGradient
                      : const LinearGradient(
                          colors: [Color(0xFFCCCCCC), Color(0xFFBBBBBB)],
                        ),
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                  boxShadow: car.available
                      ? [
                          BoxShadow(
                            color: AppColors.blue1.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    car.available ? 'Réserver maintenant' : 'Indisponible',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared detail card wrapper ───────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailCard({required this.title, required this.child});

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
            color: AppColors.blue1.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceSectionHeader(title: title),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}
