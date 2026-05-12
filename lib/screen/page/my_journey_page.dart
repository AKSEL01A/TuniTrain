import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/my_journey_controller.dart';
import 'package:tuni_train/models/tickets.dart';
import 'package:tuni_train/screen/page/journey_route_screen.dart';
import 'package:tuni_train/screen/page/qr_screen.dart';

class MyJourneyPage extends StatelessWidget {
  MyJourneyPage({super.key});

  final MyJourneyController ctrl = Get.put(
    MyJourneyController(),
    permanent: false,
  );

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
                  GestureDetector(
                    onTap: ctrl.refresh,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
              color: AppColors.blue1.withValues(alpha: 0.15),
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
      // ── Loading ──────────────────────────────────────────────────────────
      if (ctrl.isLoading.value) return _buildSkeleton();

      // ── Error ────────────────────────────────────────────────────────────
      if (ctrl.hasError.value) return _buildError();

      // ── Access selectedTab & searchQuery inside Obx so it reacts ────────
      final tab = ctrl.selectedTab.value;
      final query = ctrl.searchQuery.value;
      final tickets = ctrl.displayedTickets;

      // ── Empty ────────────────────────────────────────────────────────────
      if (tickets.isEmpty) return _buildEmpty(tab);

      // ── List ─────────────────────────────────────────────────────────────
      return RefreshIndicator(
        color: AppColors.blue1,
        onRefresh: ctrl.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          itemCount: tickets.length,
          itemBuilder: (_, i) {
            final ticket = tickets[i];
            final showHeader =
                i == 0 ||
                _differentMonth(tickets[i - 1].travelDate, ticket.travelDate);
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
  Widget _buildTicketCard(MyTicket ticket) {
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
                ? Colors.black.withValues(alpha: 0.04)
                : AppColors.blue1.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Opacity(
        opacity: isPast ? 0.65 : 1.0,
        child: Column(
          children: [
            // ── TOP ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
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
                  Text(
                    ticket.ticketCode,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPast
                          ? const Color(0xFFF0F0F0)
                          : countdownColor.withValues(alpha: 0.10),
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

            // ── RETURN LEG ────────────────────────────────────────────────
            if (ticket.isRoundTrip && ticket.returnFromStation != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.sand.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.replay_circle_filled_rounded,
                        color: Color(0xFFE65100),
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Retour: ${ticket.returnDepartureTime ?? '--'} · ${ticket.returnFromStation} → ${ticket.returnToStation}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE65100),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                    '${ticket.totalPrice.toStringAsFixed(3)} DT',
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
  //  CARD CTA
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCardCta(MyTicket ticket, bool isPast) {
    if (isPast) {
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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: GestureDetector(
        onTap: () => Get.to(
          () => QrTicketScreen(directTicket: ticket),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 350),
        ),
        child: Row(
          children: [
            // ── "Voir le billet" (QR) button ─────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: () => Get.to(
                  () => QrTicketScreen(directTicket: ticket),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 350),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
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

            // ── Vertical divider ─────────────────────────────────────────────
            Container(
              width: 1,
              height: 22,
              color: Colors.white.withValues(alpha: 0.25),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),

            // ── "Voir Votre Trajet" text link ─────────────────────────────────
            GestureDetector(
              onTap: () => Get.to(
                () => JourneyRouteScreen(ticket: ticket),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 350),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.route_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Voir Votre Trajet',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SKELETON
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
  Widget _buildEmpty(int tab) {
    final isActive = tab == 0;
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
                      color: AppColors.blue1.withValues(alpha: 0.3),
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
  //  HELPERS
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
