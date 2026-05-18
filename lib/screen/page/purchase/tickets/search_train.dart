import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/trains/search_train_controller.dart';
import 'package:tuni_train/screen/widgets/coupon_section.dart';
import 'package:tuni_train/screen/widgets/date_time_picker_sheet.dart';
import 'package:tuni_train/screen/widgets/passengers_sheet.dart';
import 'package:tuni_train/screen/widgets/search_footer.dart';
import 'package:tuni_train/screen/widgets/search_train_widgets.dart';
import 'package:tuni_train/screen/widgets/station_picker_sheet.dart';

class SearchTrainPage extends GetView<SearchTrainController> {
  const SearchTrainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              children: [
                // Date section
                Row(
                  children: [
                    Expanded(child: _buildDateTile(context, isDeparture: true)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => controller.hasReturn.value
                            ? _buildDateTile(context, isDeparture: false)
                            : _buildAddReturnBtn(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPassengersTile(context),
                const SizedBox(height: 16),
                const CouponSection(),
              ],
            ),
          ),
          const SearchFooter(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HEADER
  // ══════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue1, AppColors.blue2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Trouver votre trajet',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Line chips
            Obx(() {
              final selected = controller.selectedNetwork.value;

              return SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.lines.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return _lineChip(
                        label: 'Tous',
                        selected: selected == 'ALL',
                        onTap: () => controller.changeNetwork('ALL'),
                      );
                    }

                    final line = controller.lines[i - 1];

                    return _lineChip(
                      label: line.name,
                      selected: selected == line.id,
                      onTap: () => controller.changeNetwork(line.id),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            // Stations card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStationsCard(context),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LINE CHIP
  // ══════════════════════════════════════════════════════════════

  Widget _lineChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: selected ? AppColors.blue1 : AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  DATE TILE
  // ══════════════════════════════════════════════════════════════

  Widget _buildDateTile(BuildContext context, {required bool isDeparture}) {
    return GestureDetector(
      onTap: () => showDateTimePickerSheet(context, isDeparture: isDeparture),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: tileDeco(),
        child: Row(
          children: [
            iconBox(
              isDeparture
                  ? Icons.calendar_today_rounded
                  : Icons.calendar_month_rounded,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isDeparture ? 'Aller' : 'Retour',
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (!isDeparture)
                        GestureDetector(
                          onTap: () => controller.clearReturn(),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.red,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Obx(() {
                    final date = isDeparture
                        ? controller.departureDate.value
                        : controller.returnDate.value;
                    final time = isDeparture
                        ? controller.departureTime.value
                        : controller.returnTime.value;
                    return Text(
                      controller.fmtDateTime(date, time),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blue1,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  ADD RETURN BUTTON
  // ══════════════════════════════════════════════════════════════

  Widget _buildAddReturnBtn() {
    return GestureDetector(
      onTap: () => controller.hasReturn.value = true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.blue2, width: 1.4),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: AppColors.blue1.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: AppColors.blue2, size: 16),
            const SizedBox(width: 6),
            Text(
              'Retour',
              style: GoogleFonts.poppins(
                color: AppColors.blue2,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PASSENGERS TILE
  // ══════════════════════════════════════════════════════════════

  Widget _buildPassengersTile(BuildContext context) {
    return GestureDetector(
      onTap: () => showPassengersSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: tileDeco(),
        child: Row(
          children: [
            iconBox(Icons.people_alt_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passagers',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Obx(
                    () => Text(
                      controller.passengersLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1F36),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.blue3,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  STATIONS CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildStationsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStationRow(
            context,
            label: 'De',
            icon: Icons.trip_origin_rounded,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.bluePale),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              _buildStationRow(
                context,
                label: 'À',
                icon: Icons.location_on_rounded,
              ),
              Positioned(
                right: 16,
                child: GestureDetector(
                  onTap: () => controller.swapStations(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.blue1,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: AppColors.blue1,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationRow(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => showStationPickerSheet(context, isFrom: label == 'De'),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue1, size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Obx(() {
                  final text = (label == 'De')
                      ? (controller.from.value.isEmpty
                            ? 'Gare de départ'
                            : controller.from.value)
                      : (controller.to.value.isEmpty
                            ? 'Gare d\'arrivée'
                            : controller.to.value);
                  return Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
