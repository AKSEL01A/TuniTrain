import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/search_train_controller.dart';
import 'package:tuni_train/screen/widget/search_train_widgets.dart';

/// Shows a bottom sheet with calendar + time picker.
Future<void> showDateTimePickerSheet(
  BuildContext context, {
  required bool isDeparture,
}) async {
  final controller = Get.find<SearchTrainController>();

  DateTime tempDate = isDeparture
      ? (controller.departureDate.value ?? DateTime.now())
      : (controller.returnDate.value ?? DateTime.now());
  TimeOfDay tempTime = isDeparture
      ? (controller.departureTime.value ?? TimeOfDay.now())
      : (controller.returnTime.value ?? TimeOfDay.now());

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 20,
          right: 20,
          top: 14,
        ),
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
              isDeparture
                  ? 'Date et heure de départ'
                  : 'Date et heure de retour',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.blue1,
              ),
            ),

            const SizedBox(height: 18),

            // Calendar
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.blue1,
                    onPrimary: AppColors.white,
                    onSurface: Color(0xFF1A1F36),
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: tempDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  onDateChanged: (d) => setS(() => tempDate = d),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Time row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  iconBox(Icons.access_time_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Heure de départ',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: tempTime,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.blue1,
                              onPrimary: AppColors.white,
                              onSurface: Color(0xFF1A1F36),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (t != null) setS(() => tempTime = t);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.blue2, AppColors.blue1],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tempTime.format(ctx),
                        style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Confirm
            confirmButton('Confirmer', () {
              final dt = DateTime(
                tempDate.year,
                tempDate.month,
                tempDate.day,
                tempTime.hour,
                tempTime.minute,
              );
              if (isDeparture) {
                controller.departureDate.value = tempDate;
                controller.departureTime.value = tempTime;
                controller.departureDateTime.value = dt;
                controller.selectedTime.value = tempTime;
              } else {
                controller.returnDate.value = tempDate;
                controller.returnTime.value = tempTime;
                controller.returnDateTime.value = dt;
              }
              Get.back();
            }),
          ],
        ),
      ),
    ),
  );
}
