import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/core/constants/date_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/controller/purchase/panel_controller.dart';
import 'package:tuni_train/models/trains/train.dart';
import 'package:tuni_train/models/trains/train_journey.dart';

class PanelPage extends StatelessWidget {
  PanelPage({super.key});

  final PanelController ctrl = Get.put(PanelController());

  @override
  Widget build(BuildContext context) {
    // Refresh from search controller every time this page is shown
    ctrl.refresh();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.blue1,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Détails du Voyage',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (!ctrl.hasAller) return _buildEmptyState();
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Aller ticket ──────────────────────────────────────────
              _buildTicketSection(
                label: 'ALLER',
                labelColor: const Color(0xFF1565C0),
                labelBg: const Color(0xFFE3F2FD),
                icon: Icons.arrow_circle_right_rounded,
                journey: ctrl.journeyAller.value!,
                train: ctrl.trainAller.value,
                durationText: ctrl.durationAllerText,
                onDelete: () => _confirmDelete(isAller: true),
              ),

              // ── Retour ticket (if exists) ─────────────────────────────
              if (ctrl.hasRetour) ...[
                const SizedBox(height: 20),
                _buildTicketSection(
                  label: 'RETOUR',
                  labelColor: const Color(0xFFE65100),
                  labelBg: const Color(0xFFFFF3E0),
                  icon: Icons.replay_circle_filled_rounded,
                  journey: ctrl.journeyRetour.value!,
                  train: ctrl.trainRetour.value,
                  durationText: ctrl.durationRetourText,
                  onDelete: () => _confirmDelete(isAller: false),
                ),
              ],

              const SizedBox(height: 28),

              // ── Class picker ─────────────────────────────────────────
              _sectionHeader(
                icon: Icons.airline_seat_recline_extra_rounded,
                label: 'Choisir la classe',
              ),
              const SizedBox(height: 12),
              Obx(
                () => _classCard(
                  label: '2ème Classe',
                  desc: 'Confort standard · Places garanties',
                  price: '5.600 DT',
                  icon: Icons.chair_alt_rounded,
                  color: AppColors.blue2,
                  badge: null,
                  selected: ctrl.selectedClass.value == '2nd',
                  onTap: () => ctrl.selectClass('2nd'),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => _classCard(
                  label: '1ère Classe',
                  desc: 'Confort premium · Espace & tranquillité',
                  price: '8.900 DT',
                  icon: Icons.star_rounded,
                  color: AppColors.sand,
                  badge: 'PREMIUM',
                  selected: ctrl.selectedClass.value == '1st',
                  onTap: () => ctrl.selectClass('1st'),
                ),
              ),

              const SizedBox(height: 28),

              // ── Offers ───────────────────────────────────────────────
              _sectionHeader(
                icon: Icons.local_offer_rounded,
                label: 'Offres disponibles',
              ),
              const SizedBox(height: 12),
              Obx(
                () => _offerCard(
                  title: 'TARIF ORDINAIRE',
                  subtitle: 'Valide toute la journée',
                  detail: 'Sans restriction d\'horaire',
                  icon: Icons.confirmation_num_rounded,
                  color: AppColors.green,
                  colorBg: AppColors.greenBg,
                  selected: ctrl.selectedOffer.value == 'ORDINAIRE',
                  onTap: () => ctrl.selectOffer('ORDINAIRE'),
                ),
              ),

              const SizedBox(height: 28),

              // ── Summary ──────────────────────────────────────────────
              _buildSummaryCard(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (!ctrl.hasAller) return const SizedBox.shrink();
        return _buildBottomBar();
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TICKET SECTION  (reusable for aller + retour)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTicketSection({
    required String label,
    required Color labelColor,
    required Color labelBg,
    required IconData icon,
    required TrainJourney journey,
    required Train? train,
    required String durationText,
    required VoidCallback onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header row with delete button
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: labelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(icon, color: labelColor, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: labelColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.red,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Supprimer',
                      style: GoogleFonts.poppins(
                        color: AppColors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTicketCard(
          journey: journey,
          train: train,
          durationText: durationText,
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TICKET CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTicketCard({
    required TrainJourney journey,
    required Train? train,
    required String durationText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.blue1.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    train?.lineId ?? 'LINE',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.train_rounded,
                      color: Colors.white54,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Train #${train?.trainNumber ?? '--'}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Route row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journey.departureTime,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        journey.fromStation,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppColors.sand.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        durationText,
                        style: GoogleFonts.poppins(
                          color: AppColors.sand,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(width: 36, height: 1, color: Colors.white30),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white54,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        journey.arrivalTime,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        journey.toStation,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Dashed divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.bgPage,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, c) {
                      final n = (c.maxWidth / 10).floor();
                      return Row(
                        children: List.generate(
                          n,
                          (_) => Expanded(
                            child: Container(
                              height: 1,
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.25),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.bgPage,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ticketChip(
                  Icons.calendar_today_rounded,
                  formatFrDate(journey.travelDate ?? DateTime.now()),
                ),
                _vDivider(),
                _ticketChip(Icons.event_seat_rounded, '2ème CL'),
                _vDivider(),
                _ticketChip(
                  Icons.person_rounded,
                  '${ctrl.totalPassengers} passagers',
                ),
                _vDivider(),
                _ticketChip(
                  Icons.route_rounded,
                  ctrl.searchCtrl.getStopsText(journey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketChip(IconData icon, String label) => Row(
    children: [
      Icon(icon, color: Colors.white54, size: 13),
      const SizedBox(width: 5),
      Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _vDivider() => Container(
    width: 1,
    height: 16,
    // ignore: deprecated_member_use
    color: Colors.white.withOpacity(0.2),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  CLASS CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _classCard({
    required String label,
    required String desc,
    required String price,
    required IconData icon,
    required Color color,
    required String? badge,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.bluePale : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.blue1 : const Color(0xFFDDE6F5),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.blue1.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : const Color(0xFFF2F5FA),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: selected ? color : Colors.grey.shade400,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sandBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.poppins(
                              color: AppColors.sand,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.blue1 : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.blue1 : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  OFFER CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _offerCard({
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
    required Color color,
    required Color colorBg,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? colorBg : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : const Color(0xFFDDE6F5),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : const Color(0xFFF2F5FA),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: selected ? color : Colors.grey.shade400,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    detail,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(
                  color: selected ? color : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SUMMARY CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE6F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.blue3,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Récapitulatif',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),

          // Aller row
          if (ctrl.hasAller) ...[
            _summaryRow(
              'Aller',
              '${ctrl.journeyAller.value!.fromStation} → ${ctrl.journeyAller.value!.toStation}',
            ),
            _summaryRow('Départ aller', ctrl.journeyAller.value!.departureTime),
          ],

          // Retour row
          if (ctrl.hasRetour) ...[
            const SizedBox(height: 4),
            _summaryRow(
              'Retour',
              '${ctrl.journeyRetour.value!.fromStation} → ${ctrl.journeyRetour.value!.toStation}',
            ),
            _summaryRow(
              'Départ retour',
              ctrl.journeyRetour.value!.departureTime,
            ),
          ],

          Obx(
            () => _summaryRow(
              'Classe',
              ctrl.selectedClass.value == '1st' ? '1ère classe' : '2ème classe',
            ),
          ),
          Obx(() => _summaryRow('Offre', ctrl.selectedOffer.value)),
          _summaryRow('Passagers', '${ctrl.totalPassengers}'),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Obx(
                () => Text(
                  '${ctrl.totalPrice.value.toStringAsFixed(3)} DT',
                  style: GoogleFonts.poppins(
                    color: AppColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BOTTOM BAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppColors.blue1.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total à payer',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    '${ctrl.totalPrice.value.toStringAsFixed(3)} DT',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: ctrl.proceedToPayment,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue2, AppColors.blue1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.blue1.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Payer',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 48,
              color: AppColors.blue3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun billet sélectionné',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez un trajet pour continuer',
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 13),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.blue1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Retour',
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

  // ══════════════════════════════════════════════════════════════════════════
  //  DELETE CONFIRM DIALOG
  // ══════════════════════════════════════════════════════════════════════════

  void _confirmDelete({required bool isAller}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAller
                    ? 'Supprimer le billet aller'
                    : 'Supprimer le billet retour',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAller
                    ? 'Cela supprimera aussi le billet retour s\'il existe.'
                    : 'Voulez-vous retirer le train retour ?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.bluePale,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Annuler',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isAller) {
                          ctrl.deleteAllerTicket();
                        } else {
                          ctrl.deleteRetourTicket();
                        }
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Supprimer',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _sectionHeader({required IconData icon, required String label}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.bluePale,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.blue1, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
