import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/mon_journee/my_journey_abonnement_tab.dart';
import 'package:tuni_train/controller/mon_journee/my_journey_controller.dart';
import 'package:tuni_train/core/constants/date_constants.dart';
import 'package:tuni_train/screen/widgets/journey_state_widgets.dart';
import 'package:tuni_train/screen/widgets/journey_ticket_card.dart';

class MyJourneyPage extends StatelessWidget {
  MyJourneyPage({super.key});

  final MyJourneyController ctrl = Get.put(
    MyJourneyController(),
    permanent: false,
  );

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
  //  SEARCH BAR — hidden on the abonnements tab
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Obx(() {
      if (ctrl.selectedTab.value == 2) return const SizedBox.shrink();
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
              const Icon(
                Icons.search_rounded,
                color: AppColors.blue3,
                size: 18,
              ),
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
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TAB BAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _tab(
                index: 0,
                label: 'Actifs & à venir',
                icon: Icons.upcoming_rounded,
              ),
              const SizedBox(width: 8),
              _tab(
                index: 2,
                label: 'Abonnements',
                icon: Icons.card_membership_rounded,
              ),
              const SizedBox(width: 8),
              _tab(index: 1, label: 'Historique', icon: Icons.history_rounded),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : AppColors.blue3,
                fontSize: 11,
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
      // Tab 2 → Abonnements (has its own controller + loading state)
      if (ctrl.selectedTab.value == 2) {
        return const MyJourneyAbonnementTab();
      }

      if (ctrl.isLoading.value) return const JourneySkeletonList();
      if (ctrl.hasError.value) return JourneyErrorState(onRetry: ctrl.refresh);

      final tab = ctrl.selectedTab.value;
      final tickets = ctrl.displayedTickets;

      if (tickets.isEmpty) return JourneyEmptyState(tab: tab);

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
                JourneyTicketCard(ticket: ticket, ctrl: ctrl),
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
              '${kFrMonths[date.month]} ${date.year}',
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
}
