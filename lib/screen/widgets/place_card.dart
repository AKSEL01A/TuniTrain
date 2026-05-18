import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/place.dart';
import 'package:tuni_train/screen/widgets/service_section_header.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const PlaceCard({
    super.key,
    required this.place,
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
            _PlaceImageSection(
              place: place,
              isFavorite: isFavorite,
              onFavorite: onFavorite,
            ),
            _PlaceInfoSection(place: place),
          ],
        ),
      ),
    );
  }
}

class _PlaceImageSection extends StatelessWidget {
  final Place place;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const _PlaceImageSection({
    required this.place,
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
          child: place.imageUrls.isNotEmpty
              ? Image.network(
                  place.imageUrls.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _PlaceholderImage(place.category),
                )
              : _PlaceholderImage(place.category),
        ),
        // Gradient overlay at bottom of image for text legibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.cardLg),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Category badge
        Positioned(
          top: AppSpacing.lg,
          left: AppSpacing.lg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs + 1,
            ),
            decoration: BoxDecoration(
              color: AppColors.blue1.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              place.category.label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        // Promo badge
        if (place.promotionText != null)
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            child: PromoBadge(text: place.promotionText!),
          ),
        // Recommended badge
        if (place.isRecommended)
          Positioned(
            top: AppSpacing.lg,
            right: AppSpacing.section + 34 + AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                'RECOMMANDÉ',
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

class _PlaceInfoSection extends StatelessWidget {
  final Place place;

  const _PlaceInfoSection({required this.place});

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
                  place.name,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (place.price != null && place.price! > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${place.price!.toStringAsFixed(0)} DT',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'par personne',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 9,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'GRATUIT',
                    style: GoogleFonts.poppins(
                      color: AppColors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
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
                  place.location,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (place.openingHours != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AppColors.blue3,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  place.openingHours!,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              StarRatingWidget(
                rating: place.rating,
                reviewsCount: place.reviewsCount,
              ),
              const Spacer(),
              if (place.hasBooking)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xxs + 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bluePale,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'Réservable',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue2,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final PlaceCategory category;

  const _PlaceholderImage(this.category);

  IconData get _icon => switch (category) {
    PlaceCategory.historicSite => Icons.account_balance_rounded,
    PlaceCategory.restaurant => Icons.restaurant_rounded,
    PlaceCategory.hotel => Icons.hotel_rounded,
    PlaceCategory.adventure => Icons.landscape_rounded,
    PlaceCategory.entertainment => Icons.attractions_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.bluePale,
      child: Icon(_icon, color: AppColors.blue3, size: 48),
    );
  }
}

/// Compact card for horizontal scroll sections on the home page.
class PlaceCardHorizontal extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceCardHorizontal({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
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
              child: place.imageUrls.isNotEmpty
                  ? Image.network(
                      place.imageUrls.first,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 120,
                        color: AppColors.bluePale,
                        child: const Icon(
                          Icons.place_rounded,
                          color: AppColors.blue3,
                          size: 36,
                        ),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: AppColors.bluePale,
                      child: const Icon(
                        Icons.place_rounded,
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
                    place.name,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 10,
                        color: AppColors.blue3,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          place.location,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue3,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  StarRatingWidget(
                    rating: place.rating,
                    showCount: false,
                    starSize: 10,
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
