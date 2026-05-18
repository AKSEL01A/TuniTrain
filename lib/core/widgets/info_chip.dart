import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuni_train/core/constants/app_constants.dart';

/// Small labelled chip with an icon, a category label, and a value.
/// Used in ticket cards to display class, passengers, price, and payment method.
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;
  final bool muted;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = muted ? Colors.grey : color;
    final effectiveBg = muted ? const Color(0xFFF5F5F5) : background;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppRadius.xs + 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: effectiveColor, size: 12),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: effectiveColor,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: effectiveColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Thin vertical divider used between [InfoChip] widgets in a row.
class InfoChipDivider extends StatelessWidget {
  const InfoChipDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      color: const Color(0xFFDDE6F5),
    );
  }
}
