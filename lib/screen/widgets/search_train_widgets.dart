import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';

// ══════════════════════════════════════════════════════════════════════════
//  SHARED UI HELPERS — used across search train page & its bottom sheets
// ══════════════════════════════════════════════════════════════════════════

/// Drag handle shown at top of every bottom sheet.
Widget sheetHandle() => Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE6F5),
        borderRadius: BorderRadius.circular(4),
      ),
    );

/// Full-width gradient confirm button.
Widget confirmButton(String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blue2, AppColors.blue1],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.blue1.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

/// Standard tile card decoration (white + subtle shadow).
BoxDecoration tileDeco() => BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: AppColors.blue1.withOpacity(0.07),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );

/// 34×34 rounded icon box (repeated pattern).
Widget iconBox(IconData icon, {Color color = AppColors.blue1, Color bg = AppColors.bluePale}) {
  return Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Icon(icon, color: color, size: 16),
  );
}
