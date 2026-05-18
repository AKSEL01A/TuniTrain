import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/trains/search_train_controller.dart';
import 'package:tuni_train/screen/widgets/search_train_widgets.dart';

/// Shows a bottom sheet to pick number of adults & babies.
void showPassengersSheet(BuildContext context) {
  final controller = Get.find<SearchTrainController>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            sheetHandle(),
            const SizedBox(height: 16),

            Text(
              'Passagers',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.blue1,
              ),
            ),

            const SizedBox(height: 20),

            _passengerRow(
              setS: setS,
              label: 'Adultes',
              sublabel: null,
              count: controller.adults.value,
              min: 1,
              onDec: () => setS(() => controller.adults.value--),
              onInc: () => setS(() => controller.adults.value++),
            ),

            Divider(color: AppColors.bluePale),

            Divider(color: AppColors.bluePale),

            _passengerRow(
              setS: setS,
              label: 'Bébés',
              sublabel: 'Moins de 2 ans · Gratuit',
              count: controller.babies.value,
              min: 0,
              onDec: () => setS(() => controller.babies.value--),
              onInc: () => setS(() => controller.babies.value++),
            ),

            const SizedBox(height: 22),

            confirmButton('Confirmer', () => Get.back()),
          ],
        ),
      ),
    ),
  );
}

Widget _passengerRow({
  required StateSetter setS,
  required String label,
  required String? sublabel,
  required int count,
  required int min,
  required VoidCallback onDec,
  required VoidCallback onInc,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: const Color(0xFF1A1F36),
              ),
            ),
            if (sublabel != null)
              Text(
                sublabel,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.blue3,
                ),
              ),
          ],
        ),
        const Spacer(),
        _counterBtn(Icons.remove_rounded, count <= min ? null : onDec),
        SizedBox(
          width: 36,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: AppColors.blue1,
            ),
          ),
        ),
        _counterBtn(Icons.add_rounded, onInc),
      ],
    ),
  );
}

Widget _counterBtn(IconData icon, VoidCallback? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: onTap == null ? const Color(0xFFF0F0F0) : AppColors.bluePale,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18,
        color: onTap == null ? Colors.grey.shade400 : AppColors.blue1,
      ),
    ),
  );
}
