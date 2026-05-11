import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/search_train_controller.dart';
import 'package:tuni_train/models/train_journey.dart';

class SearchResultPage extends StatelessWidget {
  SearchResultPage({super.key});

  final SearchTrainController ctrl = Get.find<SearchTrainController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(context),
          _buildStepBanner(),
          _buildCountStrip(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STEP BANNER  ─  shows "Choisissez ALLER" or "Choisissez RETOUR"
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStepBanner() {
    return Obx(() {
      final isAller = ctrl.bookingStep.value == 'ALLER';
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAller
                ? [const Color(0xFF1565C0), const Color(0xFF1976D2)]
                : [const Color(0xFFE65100), const Color(0xFFF57C00)],
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAller
                  ? Icons.arrow_circle_right_rounded
                  : Icons.replay_circle_filled_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAller
                    ? 'Étape 1 / ${ctrl.isRoundTrip ? "2" : "1"}  –  Choisissez votre train ALLER'
                    : 'Étape 2 / 2  –  Choisissez votre train RETOUR',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // If already picked aller and doing round-trip, show a mini chip
            if (!isAller)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Aller sélectionné',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HEADER
  // ══════════════════════════════════════════════════════════════════════════

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
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  const Spacer(),
                  Obx(
                    () => Text(
                      ctrl.isRoundTrip ? 'Aller-retour' : 'Aller simple',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _headerAction(
                    Icons.home_rounded,
                    () => Get.offAllNamed('/home'),
                  ),
                  _headerAction(
                    Icons.shopping_bag_rounded,
                    () => Get.toNamed('/panel'),
                  ),
                ],
              ),
            ),

            // Route banner
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DÉPART',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ctrl.bookingStep.value == 'RETOUR'
                                ? ctrl.to.value
                                : ctrl.from.value.isEmpty
                                ? '—'
                                : ctrl.from.value,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppColors.sand.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 1,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.train_rounded,
                              color: AppColors.sand,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 18,
                              height: 1,
                              color: Colors.white38,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ARRIVÉE',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ctrl.bookingStep.value == 'RETOUR'
                                ? ctrl.from.value
                                : ctrl.to.value.isEmpty
                                ? '—'
                                : ctrl.to.value,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Meta row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metaChip(
                        Icons.calendar_today_rounded,
                        _formatDate(
                          ctrl.bookingStep.value == 'RETOUR'
                              ? (ctrl.returnDateTime.value ?? DateTime.now())
                              : (ctrl.departureDateTime.value ??
                                    DateTime.now()),
                        ),
                      ),
                      _metaDivider(),
                      _metaChip(
                        Icons.access_time_rounded,
                        ctrl.selectedTime.value?.format(Get.context!) ?? '—',
                      ),
                      _metaDivider(),
                      _metaChip(
                        Icons.person_rounded,
                        '${ctrl.adults.value} Ad · ${ctrl.babies.value} Bé',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _metaDivider() => Container(
    width: 1,
    height: 14,
    // ignore: deprecated_member_use
    color: Colors.white.withValues(alpha: 0.2),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  COUNT STRIP
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCountStrip() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bluePale,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ctrl.nextTrains.length}',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'trains disponibles',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LIST
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildList() {
    return Obx(() {
      if (ctrl.searchLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.blue1,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Recherche en cours…',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }
      if (ctrl.nextTrains.isEmpty) return _buildEmptyState();
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: ctrl.nextTrains.length,
        itemBuilder: (_, i) => _buildTrainCard(ctrl.nextTrains[i]),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TRAIN CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTrainCard(TrainJourney t) {
    final trainInfo = ctrl.getTrainById(t.trainId);
    final status = ctrl.getTrainStatus(t, trainInfo);
    final statusColor = ctrl.getTrainStatusColor(status);
    final statusBg = ctrl.getTrainStatusBg(status);

    return GestureDetector(
      onTap: () => _onTrainSelected(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: AppColors.blue1.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card top
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bluePale,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      trainInfo?.lineId ?? 'LINE',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          status.contains('Retard')
                              ? Icons.schedule_rounded
                              : status == 'Pas encore parti'
                              ? Icons.access_time_filled_rounded
                              : Icons.check_circle_rounded,
                          color: statusColor,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: GoogleFonts.poppins(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${t.trainId}',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Route row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.departureTime,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          t.fromStation,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue3,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        ctrl.calcDuration(t.departureTime, t.arrivalTime),
                        style: GoogleFonts.poppins(
                          color: AppColors.sand,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.blue3,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 1,
                            color: const Color(0xFFB0C8E8),
                          ),
                          const Icon(
                            Icons.train_rounded,
                            color: AppColors.blue2,
                            size: 18,
                          ),
                          Container(
                            width: 28,
                            height: 1,
                            color: const Color(0xFFB0C8E8),
                          ),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.blue3,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ctrl.getStopsText(t),
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          t.arrivalTime,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          t.toStation,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue3,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Dashed divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (_, c) {
                  final n = (c.maxWidth / 8).floor();
                  return Row(
                    children: List.generate(
                      n,
                      (_) => Expanded(
                        child: Container(
                          height: 1,
                          color: (n % 2 == 0)
                              ? const Color(0xFFDDE6F5)
                              : Colors.transparent,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Info chips
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoChip(
                    Icons.speed_rounded,
                    'VITESSE',
                    trainInfo != null ? '${trainInfo.currentSpeed} km/h' : '--',
                    AppColors.blue1,
                    AppColors.bluePale,
                  ),
                  _chipDivider(),
                  _infoChip(
                    Icons.event_seat_rounded,
                    'PLACES',
                    trainInfo != null
                        ? '${trainInfo.occupiedSeats}/${trainInfo.totalCapacity}'
                        : '--',
                    AppColors.green,
                    AppColors.greenBg,
                  ),
                  _chipDivider(),
                  _infoChip(
                    Icons.monetization_on_rounded,
                    'À PARTIR DE',
                    '5.600 DT',
                    AppColors.sand,
                    AppColors.sandBg,
                  ),
                ],
              ),
            ),

            // CTA strip
            Container(
              decoration: const BoxDecoration(
                color: AppColors.blue1,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      ctrl.bookingStep.value == 'ALLER'
                          ? 'Sélectionner ce train aller'
                          : 'Sélectionner ce train retour',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Core selection logic ────────────────────────────────────────────────
  void _onTrainSelected(TrainJourney t) {
    final trainInfo = ctrl.getTrainById(t.trainId);

    if (ctrl.bookingStep.value == 'ALLER') {
      // ── ALLER selected ──────────────────────────────────────────────────
      ctrl.selectedAller.value = t;
      ctrl.selectedTrain.value = trainInfo;

      if (ctrl.isRoundTrip) {
        // Round-trip: switch to RETOUR step, swap stations, reload
        ctrl.bookingStep.value = 'RETOUR';
        ctrl.searchMode.value = 'RETOUR';

        // Swap from/to for return journey display
        final tmpFrom = ctrl.from.value;
        final tmpFromId = ctrl.fromId.value;
        ctrl.from.value = ctrl.to.value;
        ctrl.fromId.value = ctrl.toId.value;
        ctrl.to.value = tmpFrom;
        ctrl.toId.value = tmpFromId;

        // Use return date/time for the search
        ctrl.departureDateTime.value = ctrl.returnDateTime.value;
        if (ctrl.returnDateTime.value != null) {
          ctrl.selectedTime.value = TimeOfDay(
            hour: ctrl.returnDateTime.value!.hour,
            minute: ctrl.returnDateTime.value!.minute,
          );
        }

        ctrl.search();
      } else {
        // One-way: go directly to panel
        Get.toNamed('/panel');
      }
    } else {
      // ── RETOUR selected ─────────────────────────────────────────────────
      ctrl.selectRetour(t, trainInfo);
    }
  }

  Widget _infoChip(
    IconData icon,
    String label,
    String value,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipDivider() =>
      Container(width: 1, height: 28, color: const Color(0xFFDDE6F5));

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.train_outlined,
              color: AppColors.blue3,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun train disponible',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Essayez un autre jour ou un autre trajet',
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue2, AppColors.blue1],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Modifier la recherche',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }
}
