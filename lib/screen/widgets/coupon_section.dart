import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/trains/search_train_controller.dart';

/// Collapsible coupon code section (collapsed → "Vous avez un code promo ?", expanded → input + validate).
class CouponSection extends GetView<SearchTrainController> {
  const CouponSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showCouponField.value) return _buildCollapsed();
      return _buildExpanded();
    });
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onTap: () => controller.showCouponField.value = true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.sandBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.sand.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.sand.withOpacity(0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: AppColors.sand,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code promo',
                    style: GoogleFonts.poppins(
                      color: AppColors.sand,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Vous avez un code promo ?',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF8A6020),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_rounded,
              color: AppColors.sand.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input field
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: AppColors.blue1.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.local_offer_rounded,
                  color: AppColors.blue1,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.couponTextCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F36),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Entrez votre code promo',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFB0C8E8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                // Validate button
                GestureDetector(
                  onTap: () {
                    controller.couponCode.value = controller.couponTextCtrl.text
                        .trim();
                    FocusScope.of(Get.context!).unfocus();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Valider',
                      style: GoogleFonts.poppins(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Applied badge
          Obx(() {
            if (controller.couponCode.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.green,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Code « ${controller.couponCode.value} » appliqué',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Cancel link
          TextButton.icon(
            onPressed: () => controller.cancelCoupon(),
            icon: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.red,
            ),
            label: Text(
              'Annuler',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
