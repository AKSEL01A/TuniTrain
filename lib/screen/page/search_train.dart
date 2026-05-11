import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/search_train_controller.dart';
import 'package:tuni_train/data/data.dart';
import 'package:tuni_train/screen/page/search_result_page.dart';

class SearchTrainPage extends StatefulWidget {
  const SearchTrainPage({super.key});
  @override
  State<SearchTrainPage> createState() => _SearchTrainPageState();
}

class _SearchTrainPageState extends State<SearchTrainPage> {
  String? couponCode;
  final TextEditingController _couponcontroller = TextEditingController();
  final controller = Get.find<SearchTrainController>();
  bool showCouponField = false; // El etat mta3 el affichage
  // Stations (à brancher avec ton controller)

  @override
  void dispose() {
    _couponcontroller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,

      body: Column(
        children: [
          // ───────── HEADER ─────────
          _buildHeader(context),

          // ───────── MAIN CONTENT ─────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───────── DATE SECTION ─────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTile(context, isDeparture: true),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Obx(() {
                          return controller.hasReturn.value
                              ? _buildDateTile(context, isDeparture: false)
                              : _buildAddReturnBtn();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ───────── PASSENGERS ─────────
                  _buildPassengersTile(context),

                  const SizedBox(height: 16),

                  // ───────── COUPON ─────────
                  _buildCouponSection(),
                ],
              ),
            ),
          ),

          // ───────── FOOTER ─────────
          _buildFooter(context),
        ],
      ),
    );
  }

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
            // ── Top bar ───────────────────────────────
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

            // ── Line chips ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 0, 0),
              child: SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.lines.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Obx(
                        () => _lineChip(
                          label: 'Tous',
                          selected: controller.selectedNetwork.value == 'ALL',
                          onTap: () => controller.changeNetwork('ALL'),
                        ),
                      );
                    }

                    final line = controller.lines[i - 1];

                    return Obx(
                      () => _lineChip(
                        label: line.name,
                        selected: controller.selectedNetwork.value == line.id,
                        onTap: () => controller.changeNetwork(line.id),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Stations card ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => _buildStationsCard()),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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

  Widget _buildDateTile(BuildContext context, {required bool isDeparture}) {
    return GestureDetector(
      onTap: () => _pickDateTime(context, isDeparture: isDeparture),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: _tileDeco(),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                isDeparture
                    ? Icons.calendar_today_rounded
                    : Icons.calendar_month_rounded,
                color: AppColors.blue1,
                size: 16,
              ),
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
                          onTap: () {
                            controller.hasReturn.value = false;
                            controller.returnDate.value = null;
                            controller.returnTime.value = null;
                            controller.returnDateTime.value = null;
                          },
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
                      _fmtDateTime(date, time),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: date == null ? AppColors.blue1 : AppColors.blue1,
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

  // ══════════════════════════════════════════════════════════════════════════
  //  DATE-TIME BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _pickDateTime(
    BuildContext context, {
    required bool isDeparture,
  }) async {
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
              // Handle
              _sheetHandle(),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.bluePale,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.blue1,
                        size: 17,
                      ),
                    ),
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
              _confirmButton('Confirmer', () {
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

  // ══════════════════════════════════════════════════════════════════════════
  //  PASSENGERS TILE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildPassengersTile(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPassengersSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: _tileDeco(),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: AppColors.blue1,
                size: 16,
              ),
            ),
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
                      _passengersLabel(),
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

  // ══════════════════════════════════════════════════════════════════════════
  //  PASSENGERS BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════════════

  void _showPassengersSheet(BuildContext context) {
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
              _sheetHandle(),
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

              _confirmButton('Confirmer', () => Get.back()),
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

  // ══════════════════════════════════════════════════════════════════════════
  //  COUPON SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCouponSection() {
    return Obx(() {
      if (!controller.showCouponField.value) {
        // ── Collapsed: "Vous avez un code promo ?" ─────────────────────
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

      // ── Expanded: input + validate ─────────────────────────────────
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  // Validate button
                  GestureDetector(
                    onTap: () {
                      controller.couponCode.value = controller
                          .couponTextCtrl
                          .text
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
              if (controller.couponCode.value.isEmpty)
                return const SizedBox.shrink();
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
              onPressed: () {
                controller.showCouponField.value = false;
                controller.couponCode.value = '';
                controller.couponTextCtrl.clear();
              },
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
    });
  }

  // ────────────────────────────────────────────────────────────────
  // STATIONS CARD
  // ────────────────────────────────────────────────────────────────
  Widget _buildStationsCard() {
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
            label: 'De',
            hint: controller.from.value.isEmpty
                ? 'Gare de départ'
                : controller.from.value,
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
                label: 'À',
                hint: controller.to.value.isEmpty
                    ? 'Gare d\'arrivée'
                    : controller.to.value,
                icon: Icons.location_on_rounded,
              ),
              Positioned(
                right: 16,
                child: GestureDetector(
                  onTap: _swapStations,
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

  Widget _buildStationRow({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _openStationPicker(isFrom: label == 'De'),
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

                // 🔥 IMPORTANT FIX HERE
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

  // ────────────────────────────────────────────────────────────────
  // SEARCH BUTTON
  // ────────────────────────────────────────────────────────────────

  // ────────────────────────────────────────────────────────────────
  // STATION PICKER  (à brancher avec ton controller)
  // ────────────────────────────────────────────────────────────────
  void _openStationPicker({required bool isFrom}) {
    // ───────────────────────────────
    // 1. PREPARE DATA ONCE (NO REBUILD LOOP)
    // ───────────────────────────────
    final isAll = controller.selectedNetwork.value == 'ALL';

    final List<String> allStations = isAll
        ? controller.stations.map((e) => e.name).toList()
        : controller.filteredStations.map((e) => e.name).toList();

    final ValueNotifier<List<String>> filtered = ValueNotifier<List<String>>(
      allStations,
    );

    void filter(String query) {
      final q = query.toLowerCase();
      filtered.value = allStations
          .where((s) => s.toLowerCase().contains(q))
          .toList();
    }

    // ───────────────────────────────
    // 2. SHOW SHEET
    // ───────────────────────────────
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (ctx, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ── HANDLE ──
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── TITLE ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.train, color: AppColors.blue1),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(() {
                              final isAll =
                                  controller.selectedNetwork.value == 'ALL';
                              final line = controller.getSelectedLine();

                              return Text(
                                isAll
                                    ? "Toutes les stations"
                                    : "Stations de ${line?.name ?? ''}",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── SEARCH FIELD ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une station...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: filter,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── LIST ──
                  Expanded(
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: filtered,
                      builder: (_, list, __) {
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final station = list[i];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: AppColors.blue1,
                                  ),
                                  title: Text(
                                    station,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  onTap: () {
                                    controller.selectStation(isFrom, station);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────
  // SWAP STATIONS
  // ────────────────────────────────────────────────────────────────
  void _swapStations() {
    controller.swapStations();
    setState(() {});
  }

  Widget _sheetHandle() => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: const Color(0xFFDDE6F5),
      borderRadius: BorderRadius.circular(4),
    ),
  );

  Widget _confirmButton(String label, VoidCallback onTap) {
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
  // ══════════════════════════════════════════════════════════════════════════
  //  FOOTER  (notice + search button)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: AppColors.bgPage,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Avant de procéder à l\'achat, consultez les changements de trafic ferroviaire prévus.',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Search button
          Obx(
            () => GestureDetector(
              onTap: controller.searchLoading.value
                  ? null
                  : () async {
                      debugPrint("════════════════════════════");
                      debugPrint("SEARCH BUTTON CLICKED");

                      // ── LOADING STATE ──
                      controller.searchLoading.value = true;

                      try {
                        // ── DATE CHECK ──
                        if (controller.departureDateTime.value == null) {
                          Get.snackbar(
                            "Erreur",
                            "Sélectionnez la date et l'heure",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: AppColors.white,
                            margin: const EdgeInsets.all(12),
                            borderRadius: 14,
                          );
                          return;
                        }

                        // ── TIME SET ──
                        final activeDate = controller.activeDate;

                        controller.selectedTime.value = TimeOfDay(
                          hour: activeDate.hour,
                          minute: activeDate.minute,
                        );

                        debugPrint("FROM: ${controller.from.value}");
                        debugPrint("TO: ${controller.to.value}");

                        // ── STATION CHECK ──
                        if (controller.from.value.isEmpty ||
                            controller.to.value.isEmpty) {
                          Get.snackbar(
                            "Erreur",
                            "Choisissez les stations",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: AppColors.white,
                          );
                          return;
                        }

                        // ── SEARCH ──
                        await controller.search();

                        debugPrint("🚆 FOUND: ${controller.nextTrains.length}");

                        // ── NAVIGATION ──
                        if (controller.nextTrains.isNotEmpty) {
                          Get.to(
                            () => SearchResultPage(),
                            arguments: {
                              "from": controller.from.value,
                              "to": controller.to.value,
                              "date": controller.departureDateTime.value,
                              "adults": controller.adults.value,
                              "children": controller.children.value,
                              "babies": controller.babies.value,
                              "coupon": controller.couponCode.value,
                            },
                          );
                        } else {
                          Get.snackbar(
                            "Aucun train",
                            "Aucun trajet disponible",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                            borderRadius: 14,
                          );
                        }
                      } finally {
                        controller.searchLoading.value = false;
                      }
                    },

              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: controller.searchLoading.value
                        ? [Colors.grey, Colors.grey]
                        : [AppColors.blue2, AppColors.blue1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue1.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: controller.searchLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Rechercher des trains',
                              style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _tileDeco() => BoxDecoration(
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

  // ══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  String _fmtDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return 'Sélectionner';
    final d =
        '${date.day.toString().padLeft(2, '0')} ${DaysData.months[date.month - 1]}';
    final t = time != null
        ? ' · ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : '';
    return '$d$t';
  }

  String _passengersLabel() {
    final parts = <String>[];
    if (controller.adults.value > 0) {
      parts.add(
        '${controller.adults.value} Adulte${controller.adults.value > 1 ? 's' : ''}',
      );
    }

    if (controller.babies.value > 0) {
      parts.add(
        '${controller.babies.value} Bébé${controller.babies.value > 1 ? 's' : ''}',
      );
    }
    return parts.isEmpty ? '1 Adulte' : parts.join(' · ');
  }
}
