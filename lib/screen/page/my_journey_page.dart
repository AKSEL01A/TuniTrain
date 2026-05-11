import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/my_journey_controller.dart';

import '../../models/tickets.dart';

class MyJourneyPage extends StatelessWidget {
  MyJourneyPage({super.key});

  final MyJourneyController ctrl = Get.put(MyJourneyController());

  // ── Month names (FR) ───────────────────────────────────────────────────
  static const List<String> _months = [
    '',
    'Jan',
    'Fév',
    'Mar',
    'Avr',
    'Mai',
    'Jun',
    'Jul',
    'Aoû',
    'Sep',
    'Oct',
    'Nov',
    'Déc',
  ];
  static const List<String> _days = [
    '',
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row ─────────────────────────────────────────────────
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mes Voyages',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  // Refresh button
                  GestureDetector(
                    onTap: ctrl.refresh,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Stats row ────────────────────────────────────────────────
              Obx(
                () => Row(
                  children: [
                    _statChip(
                      icon: Icons.confirmation_number_rounded,
                      label: 'Actifs',
                      value: '${ctrl.activeCount}',
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      icon: Icons.history_rounded,
                      label: 'Passés',
                      value: '${ctrl.pastCount}',
                      color: AppColors.sand,
                    ),
                    const SizedBox(width: 10),
                    _statChip(
                      icon: Icons.receipt_long_rounded,
                      label: 'Total',
                      value: '${ctrl.allTickets.length}',
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SEARCH BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.blue1,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.blue3, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => ctrl.searchQuery.value = v,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF1A1F36),
                ),
                decoration: InputDecoration(
                  hintText: 'Chercher par gare, code billet…',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.blue3,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Obx(
              () => ctrl.searchQuery.value.isNotEmpty
                  ? GestureDetector(
                      onTap: () => ctrl.searchQuery.value = '',
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.blue3,
                        size: 16,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TAB BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Obx(
        () => Row(
          children: [
            _tab(
              index: 0,
              label: 'Actifs & à venir',
              icon: Icons.upcoming_rounded,
            ),
            const SizedBox(width: 10),
            _tab(index: 1, label: 'Historique', icon: Icons.history_rounded),
          ],
        ),
      ),
    );
  }

  Widget _tab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final selected = ctrl.selectedTab.value == index;
    return GestureDetector(
      onTap: () => ctrl.selectedTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue1 : Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : AppColors.blue3,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BODY
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBody() {
    return Obx(() {
      if (ctrl.isLoading.value) return _buildSkeleton();
      if (ctrl.hasError.value) return _buildError();
      if (ctrl.displayedTickets.isEmpty) return _buildEmpty();

      return RefreshIndicator(
        color: AppColors.blue1,
        onRefresh: ctrl.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          itemCount: ctrl.displayedTickets.length,
          itemBuilder: (_, i) {
            final ticket = ctrl.displayedTickets[i];
            // Group by month: show month header when month changes
            final showHeader =
                i == 0 ||
                _differentMonth(
                  ctrl.displayedTickets[i - 1].travelDate,
                  ticket.travelDate,
                );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHeader) _buildMonthHeader(ticket.travelDate),
                _buildTicketCard(ticket),
              ],
            );
          },
        ),
      );
    });
  }

  bool _differentMonth(DateTime a, DateTime b) =>
      a.year != b.year || a.month != b.month;

  // ══════════════════════════════════════════════════════════════════════════
  //  MONTH HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMonthHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_months[date.month]} ${date.year}',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: const Color(0xFFDDE6F5))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TICKET CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTicketCard(Ticket ticket) {
    final isPast = ctrl.minutesUntilDeparture(ticket) == null;
    final countdownLabel = ctrl.countdownLabel(ticket);
    final countdownColor = ctrl.countdownColor(ticket);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isPast
                ? Colors.black.withOpacity(0.04)
                : AppColors.blue1.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Opacity(
        opacity: isPast ? 0.65 : 1.0,
        child: Column(
          children: [
            // ── TOP: line badge + status + countdown ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  // Line badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPast
                          ? const Color(0xFFF0F0F0)
                          : AppColors.bluePale,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ticket.trainLine.isNotEmpty ? ticket.trainLine : 'SNCFT',
                      style: GoogleFonts.poppins(
                        color: isPast ? Colors.grey : AppColors.blue1,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Ticket code
                  Text(
                    ticket.ticketCode,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  // Countdown / status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPast
                          ? const Color(0xFFF0F0F0)
                          : countdownColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPast
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                          color: isPast ? Colors.grey : countdownColor,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          countdownLabel,
                          style: GoogleFonts.poppins(
                            color: isPast ? Colors.grey : countdownColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── ROUTE ROW ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // FROM
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.departureTime,
                          style: GoogleFonts.poppins(
                            color: isPast
                                ? Colors.grey.shade600
                                : AppColors.blue1,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          ticket.fromStation,
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

                  // CENTER
                  Column(
                    children: [
                      // Date pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPast
                              ? const Color(0xFFF0F0F0)
                              : AppColors.sandBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _shortDate(ticket.travelDate),
                          style: GoogleFonts.poppins(
                            color: isPast ? Colors.grey : AppColors.sand,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isPast
                                  ? Colors.grey.shade300
                                  : AppColors.blue3,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 26,
                            height: 1,
                            color: isPast
                                ? Colors.grey.shade200
                                : const Color(0xFFB0C8E8),
                          ),
                          Icon(
                            Icons.train_rounded,
                            color: isPast
                                ? Colors.grey.shade400
                                : AppColors.blue2,
                            size: 18,
                          ),
                          Container(
                            width: 26,
                            height: 1,
                            color: isPast
                                ? Colors.grey.shade200
                                : const Color(0xFFB0C8E8),
                          ),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isPast
                                  ? Colors.grey.shade300
                                  : AppColors.blue3,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // TO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ticket.arrivalTime,
                          style: GoogleFonts.poppins(
                            color: isPast
                                ? Colors.grey.shade600
                                : AppColors.blue1,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          ticket.toStation,
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

            // ── RETURN LEG (if round trip) ────────────────────────────────
            if (ticket.isRoundTrip && ticket.returnFromStation != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.sand.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.replay_circle_filled_rounded,
                        color: Color(0xFFE65100),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Retour: ${ticket.returnDepartureTime ?? '--'} · ${ticket.returnFromStation} → ${ticket.returnToStation}',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE65100),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (ticket.returnDate != null)
                        Text(
                          _shortDate(ticket.returnDate!),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE65100),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // ── DASHED DIVIDER ────────────────────────────────────────────
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

            // ── INFO CHIPS ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoChip(
                    Icons.airline_seat_recline_extra_rounded,
                    'CLASSE',
                    ticket.ticketClass == '1st' ? '1ère CL' : '2ème CL',
                    AppColors.blue1,
                    AppColors.bluePale,
                    isPast: isPast,
                  ),
                  _chipDiv(),
                  _infoChip(
                    Icons.people_alt_rounded,
                    'PASSAGERS',
                    '${ticket.passengers}',
                    AppColors.green,
                    AppColors.greenBg,
                    isPast: isPast,
                  ),
                  _chipDiv(),
                  _infoChip(
                    Icons.monetization_on_rounded,
                    'PRIX',
                    '${ticket.price?.toStringAsFixed(3)} DT',
                    AppColors.sand,
                    AppColors.sandBg,
                    isPast: isPast,
                  ),
                  _chipDiv(),
                  _infoChip(
                    _payIcon(ticket.paymentMethod),
                    'PAIEMENT',
                    _payLabel(ticket.paymentMethod),
                    const Color(0xFF7B2FBE),
                    const Color(0xFFF3E8FF),
                    isPast: isPast,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── BOTTOM CTA ────────────────────────────────────────────────
            _buildCardCta(ticket, isPast),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CARD CTA  (bottom strip)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCardCta(Ticket ticket, bool isPast) {
    if (isPast) {
      // Past ticket → just show "Terminé" grey strip
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F0F0),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.grey,
              size: 15,
            ),
            const SizedBox(width: 8),
            Text(
              'Voyage terminé',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Active ticket → "Voir billet" + cancel button
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          // View QR / ticket button
          Expanded(
            child: GestureDetector(
              onTap: () => _showTicketDetail(ticket),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Voir le billet',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(width: 1, height: 20, color: Colors.white.withOpacity(0.2)),

          // Cancel button
          GestureDetector(
            onTap: () => _confirmCancel(ticket),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    color: Colors.white60,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Annuler',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
  //  TICKET DETAIL BOTTOM SHEET  (QR placeholder + full info)
  // ══════════════════════════════════════════════════════════════════════════
  void _showTicketDetail(Ticket ticket) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bgPage,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Text(
                  'Billet électronique',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.ticketCode,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 24),

                // QR code placeholder
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.bluePale, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue1.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.blue1,
                        size: 100,
                      ),
                      Text(
                        ticket.ticketCode,
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDE6F5)),
                  ),
                  child: Column(
                    children: [
                      _detailRow2(
                        'Trajet',
                        '${ticket.fromStation} → ${ticket.toStation}',
                      ),
                      _detailRow2('Date', _fullDate(ticket.travelDate)),
                      _detailRow2('Départ', ticket.departureTime),
                      _detailRow2('Arrivée', ticket.arrivalTime),
                      _detailRow2('Train', '#${ticket.trainNumber}'),
                      _detailRow2('Ligne', ticket.trainLine),
                      _detailRow2(
                        'Classe',
                        ticket.ticketClass == '1st'
                            ? '1ère classe'
                            : '2ème classe',
                      ),
                      _detailRow2('Passagers', '${ticket.passengers}'),
                      Divider(color: Colors.grey.shade100, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total payé',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${ticket.price?.toStringAsFixed(3)} DT',
                            style: GoogleFonts.poppins(
                              color: AppColors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Return leg info if round trip
                if (ticket.isRoundTrip && ticket.returnFromStation != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.sand.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.replay_circle_filled_rounded,
                              color: Color(0xFFE65100),
                              size: 15,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Trajet Retour',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFE65100),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _detailRow2(
                          'Trajet retour',
                          '${ticket.returnFromStation} → ${ticket.returnToStation}',
                          valueColor: const Color(0xFFE65100),
                        ),
                        if (ticket.returnDate != null)
                          _detailRow2(
                            'Date retour',
                            _fullDate(ticket.returnDate!),
                            valueColor: const Color(0xFFE65100),
                          ),
                        _detailRow2(
                          'Départ retour',
                          ticket.returnDepartureTime ?? '--',
                          valueColor: const Color(0xFFE65100),
                        ),
                        _detailRow2(
                          'Arrivée retour',
                          ticket.returnArrivalTime ?? '--',
                          valueColor: const Color(0xFFE65100),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow2(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                color: valueColor ?? AppColors.blue1,
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
  //  CANCEL CONFIRM DIALOG
  // ══════════════════════════════════════════════════════════════════════════
  void _confirmCancel(Ticket ticket) {
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
                  Icons.cancel_rounded,
                  color: AppColors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Annuler le billet ?',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cette action est irréversible.\nRemboursement sous 3–5 jours ouvrés.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sandBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Frais d\'annulation: 10%',
                  style: GoogleFonts.poppins(
                    color: AppColors.sand,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
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
                            'Garder',
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
                        Get.back();
                        ctrl.cancelTicket(ticket);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Annuler',
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
  //  SKELETON LOADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      itemCount: 4,
      itemBuilder: (_, __) => _skeletonCard(),
    );
  }

  Widget _skeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _shimmer(width: 60, height: 26, radius: 10),
                const SizedBox(width: 10),
                _shimmer(width: 100, height: 14, radius: 7),
                const Spacer(),
                _shimmer(width: 80, height: 24, radius: 8),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmer(width: 70, height: 30, radius: 6),
                    const SizedBox(height: 4),
                    _shimmer(width: 90, height: 12, radius: 5),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    _shimmer(width: 70, height: 18, radius: 6),
                    const SizedBox(height: 6),
                    _shimmer(width: 100, height: 10, radius: 5),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _shimmer(width: 70, height: 30, radius: 6),
                    const SizedBox(height: 4),
                    _shimmer(width: 90, height: 12, radius: 5),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F8),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildEmpty() {
    final isActive = ctrl.selectedTab.value == 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              isActive
                  ? Icons.confirmation_number_outlined
                  : Icons.history_toggle_off_rounded,
              color: AppColors.blue3,
              size: 50,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isActive ? 'Aucun voyage à venir' : 'Aucun voyage passé',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive
                ? 'Réservez votre prochain train\npour le voir ici.'
                : 'Vos trajets terminés\napparaîtront ici.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 13),
          ),
          if (isActive) ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Get.toNamed('/searchtrain'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.blue2, AppColors.blue1],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue1.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rechercher un train',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ERROR STATE
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.red,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Erreur de chargement',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vérifiez votre connexion et réessayez.',
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: ctrl.refresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.blue1,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Réessayer',
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
  //  SMALL HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _infoChip(
    IconData icon,
    String label,
    String value,
    Color color,
    Color bg, {
    required bool isPast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isPast ? const Color(0xFFF5F5F5) : bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isPast ? Colors.grey : color, size: 12),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isPast ? Colors.grey : color,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: isPast ? Colors.grey : color,
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

  Widget _chipDiv() =>
      Container(width: 1, height: 26, color: const Color(0xFFDDE6F5));

  IconData _payIcon(String method) {
    switch (method) {
      case 'google':
        return Icons.g_mobiledata_rounded;
      case 'apple':
        return Icons.apple_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'd17':
        return Icons.smartphone_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String _payLabel(String method) {
    switch (method) {
      case 'google':
        return 'G Pay';
      case 'apple':
        return 'Apple Pay';
      case 'card':
        return 'Carte';
      case 'd17':
        return 'D17';
      default:
        return 'Wallet';
    }
  }

  String _shortDate(DateTime d) =>
      '${_days[d.weekday]}. ${d.day} ${_months[d.month]}';

  String _fullDate(DateTime d) =>
      '${_days[d.weekday]} ${d.day} ${_months[d.month]} ${d.year}';
}
