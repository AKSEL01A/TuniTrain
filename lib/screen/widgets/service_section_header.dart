import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/core/constants/app_constants.dart';

/// Section header with a bold title on the left and an optional "Voir tout" link.
class ServiceSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ServiceSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.poppins(
                  color: AppColors.blue2,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Star rating row: filled/half/empty stars + numeric label.
class StarRatingWidget extends StatelessWidget {
  final double rating;
  final int reviewsCount;
  final double starSize;
  final bool showCount;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.reviewsCount = 0,
    this.starSize = 12,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = i < rating.floor();
          final half = !filled && i < rating;
          return Icon(
            half
                ? Icons.star_half_rounded
                : filled
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
            color: AppColors.sand,
            size: starSize,
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: starSize - 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (showCount && reviewsCount > 0) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewsCount)',
            style: GoogleFonts.poppins(
              color: AppColors.blue3,
              fontSize: starSize - 2,
            ),
          ),
        ],
      ],
    );
  }
}

/// Pill-shaped filter chip used in list pages.
class ServiceFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ServiceFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPad,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue1 : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.circle),
          border: Border.all(
            color: selected ? AppColors.blue1 : const Color(0xFFDDE6F5),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.blue1.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : AppColors.blue3,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Promotional badge shown on cards with a deal.
class PromoBadge extends StatelessWidget {
  final String text;

  const PromoBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
