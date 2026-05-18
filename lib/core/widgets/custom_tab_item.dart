import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';

/// Animated top-aligned tab chip used in [MyJourneyPage].
/// Highlights in [AppColors.blue1] when selected and animates smoothly.
class JourneyTabItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String label;
  final IconData icon;
  final ValueChanged<int> onTap;

  const JourneyTabItem({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue1 : Colors.transparent,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.blue1 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.blue3,
              size: 13,
            ),
            const SizedBox(width: AppSpacing.xs + 1),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : AppColors.blue3,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
