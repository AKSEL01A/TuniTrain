import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/screen/widgets/service_section_header.dart';

class CarCard extends StatelessWidget {
  final CarRental car;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const CarCard({
    super.key,
    required this.car,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.section),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CarImageSection(
              car: car,
              isFavorite: isFavorite,
              onFavorite: onFavorite,
            ),
            _CarInfoSection(car: car),
          ],
        ),
      ),
    );
  }
}

class _CarImageSection extends StatelessWidget {
  final CarRental car;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const _CarImageSection({
    required this.car,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.cardLg),
          ),
          child: car.imageUrls.isNotEmpty
              ? Image.network(
                  car.imageUrls.first,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _PlaceholderImage(),
                )
              : _PlaceholderImage(),
        ),
        // Availability badge
        if (!car.available)
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                'INDISPONIBLE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        // Featured badge
        if (car.featured && car.available)
          Positioned(
            top: AppSpacing.lg,
            left: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                'VEDETTE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        // Favorite button
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: GestureDetector(
            onTap: onFavorite,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? AppColors.red : AppColors.blue3,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarInfoSection extends StatelessWidget {
  final CarRental car;

  const _CarInfoSection({required this.car});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  car.displayName,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${car.pricePerDay.toStringAsFixed(0)} DT',
                style: GoogleFonts.poppins(
                  color: AppColors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.business_rounded,
                size: 11,
                color: AppColors.blue3,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  car.companyName,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '/jour',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _spec(car.fuelType.icon, car.fuelType.label),
              const SizedBox(width: AppSpacing.xl),
              _spec(Icons.settings_rounded, car.transmission.label),
              const SizedBox(width: AppSpacing.xl),
              _spec(Icons.person_rounded, '${car.seats} places'),
              const Spacer(),
              StarRatingWidget(
                rating: car.rating,
                reviewsCount: car.reviewsCount,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 12,
                color: AppColors.blue3,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  car.location,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spec(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppColors.blue3),
      const SizedBox(width: 3),
      Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.blue3,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      color: AppColors.bluePale,
      child: const Icon(
        Icons.directions_car_rounded,
        color: AppColors.blue3,
        size: 48,
      ),
    );
  }
}

/// Compact horizontal card for featured car sliders.
class CarCardHorizontal extends StatelessWidget {
  final CarRental car;
  final VoidCallback onTap;

  const CarCardHorizontal({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: AppSpacing.section),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.cardLg),
              ),
              child: car.imageUrls.isNotEmpty
                  ? Image.network(
                      car.imageUrls.first,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 120,
                        color: AppColors.bluePale,
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.blue3,
                          size: 36,
                        ),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: AppColors.bluePale,
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.blue3,
                        size: 36,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    car.companyName,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        '${car.pricePerDay.toStringAsFixed(0)} DT',
                        style: GoogleFonts.poppins(
                          color: AppColors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '/jour',
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      StarRatingWidget(
                        rating: car.rating,
                        showCount: false,
                        starSize: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
