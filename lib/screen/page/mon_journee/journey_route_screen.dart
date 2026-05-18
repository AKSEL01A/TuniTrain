import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/mon_journee/journey_route_controller.dart';
import 'package:tuni_train/models/purchase/tickets.dart';

class JourneyRouteScreen extends StatelessWidget {
  final MyTicket ticket;
  const JourneyRouteScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      JourneyRouteController(ticket: ticket),
      tag: ticket.id,
    );

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) return _buildLoading();
              if (ctrl.error.value != null) return _buildError(ctrl);
              return _buildContent(ctrl);
            }),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(JourneyRouteController ctrl) {
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
          padding: const EdgeInsets.fromLTRB(4, 6, 16, 20),
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
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Votre Trajet',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Obx(() {
                          final name =
                              ctrl.line.value?.name ?? ticket.trainLine;
                          return Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.train_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '#${ticket.trainNumber}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // FROM → TO bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.departureTime,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket.fromStation,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${ctrl.totalStops}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  'arrêts',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white60,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 1,
                                color: Colors.white38,
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white54,
                                size: 14,
                              ),
                              Container(
                                width: 20,
                                height: 1,
                                color: Colors.white38,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ticket.arrivalTime,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket.toStation,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
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
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LOADING / ERROR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.blue1),
        const SizedBox(height: 16),
        Text(
          'Chargement du trajet…',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildError(JourneyRouteController ctrl) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Impossible de charger le trajet',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ctrl.error.value ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 11),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: ctrl.load,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.blue1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Réessayer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  CONTENT
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildContent(JourneyRouteController ctrl) {
    final lineColor = ctrl.lineColor();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryStrip(ctrl, lineColor),
          const SizedBox(height: 24),
          _buildStopsSection(ctrl, lineColor),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SUMMARY STRIP
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSummaryStrip(JourneyRouteController ctrl, Color lineColor) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _summaryChip(
              icon: Icons.place_rounded,
              label: 'Arrêts',
              value: '${ctrl.totalStops}',
              color: lineColor,
              bg: lineColor.withValues(alpha: 0.08),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryChip(
              icon: Icons.linear_scale_rounded,
              label: 'Intermédiaires',
              value: '${ctrl.intermediates}',
              color: AppColors.sand,
              bg: AppColors.sandBg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryChip(
              icon: Icons.airline_seat_recline_extra_rounded,
              label: 'Classe',
              value: ticket.ticketClass == '1st' ? '1ère' : '2ème',
              color: AppColors.green,
              bg: AppColors.greenBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STOPS SECTION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStopsSection(JourneyRouteController ctrl, Color lineColor) {
    return Obx(() {
      final stops = ctrl.routeStops;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arrêts du trajet',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'De ${ticket.fromStation} à ${ticket.toStation}',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${ctrl.totalStops} arrêts',
                  style: GoogleFonts.poppins(
                    color: lineColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stop list
          if (stops.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Aucun arrêt trouvé',
                  style: GoogleFonts.poppins(color: AppColors.blue3),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue1.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(stops.length, (i) {
                  final swt = stops[i];
                  final isDep = ctrl.isDeparture(swt);
                  final isArr = ctrl.isArrival(swt);
                  final isKey = isDep || isArr;
                  final isLast = i == stops.length - 1;

                  return _buildStopRow(
                    swt: swt,
                    isDep: isDep,
                    isArr: isArr,
                    isKey: isKey,
                    isLast: isLast,
                    lineColor: lineColor,
                  );
                }),
              ),
            ),
        ],
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SINGLE STOP ROW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStopRow({
    required StationWithTime swt,
    required bool isDep,
    required bool isArr,
    required bool isKey,
    required bool isLast,
    required Color lineColor,
  }) {
    final station = swt.station;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isKey ? 16 : 11,
          ),
          decoration: isKey
              ? BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.vertical(
                    top: isDep ? const Radius.circular(20) : Radius.zero,
                    bottom: isArr ? const Radius.circular(20) : Radius.zero,
                  ),
                )
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left green accent bar ─────────────────────────────────
              Container(
                width: 3,
                height: isKey ? 56 : 0,
                decoration: BoxDecoration(
                  color: isKey ? AppColors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 12),

              // ── Stop number bubble ────────────────────────────────────
              Container(
                width: isKey ? 38 : 28,
                height: isKey ? 38 : 28,
                decoration: BoxDecoration(
                  color: isKey ? AppColors.green : const Color(0xFFEEF2F8),
                  borderRadius: BorderRadius.circular(isKey ? 12 : 8),
                  boxShadow: isKey
                      ? [
                          BoxShadow(
                            color: AppColors.green.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${station.stopOrder}',
                    style: GoogleFonts.poppins(
                      color: isKey ? Colors.white : AppColors.blue3,
                      fontSize: isKey ? 13 : 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ── Station name + label ──────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: GoogleFonts.poppins(
                        color: isKey ? AppColors.blue1 : AppColors.blue3,
                        fontSize: isKey ? 13 : 12,
                        fontWeight: isKey ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),

                    // City (key stations)
                    if (isKey &&
                        station.city.isNotEmpty &&
                        station.city.trim().toLowerCase() !=
                            station.name.trim().toLowerCase()) ...[
                      const SizedBox(height: 2),
                      Text(
                        station.city,
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3,
                          fontSize: 10,
                        ),
                      ),
                    ],

                    // Dep / Arr badge
                    if (isKey) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDep
                                  ? Icons.subdirectory_arrow_right_rounded
                                  : Icons.sports_score_rounded,
                              color: AppColors.green,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isDep
                                  ? 'Station de départ'
                                  : 'Station d\'arrivée',
                              style: GoogleFonts.poppins(
                                color: AppColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Zone for intermediate
                    if (!isKey && station.zoneNumber > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Zone ${station.zoneNumber}',
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3.withValues(alpha: 0.45),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Right: time display ───────────────────────────────────
              if (isKey)
                // Key station: ticket time (large) + scheduled time (small)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isDep ? ticket.departureTime : ticket.arrivalTime,
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(
                      isDep ? 'départ' : 'arrivée',
                      style: GoogleFonts.poppins(
                        color: AppColors.green.withValues(alpha: 0.6),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Scheduled time from trainTimes if different
                    if (swt.displayTime.isNotEmpty &&
                        swt.displayTime !=
                            (isDep
                                ? ticket.departureTime
                                : ticket.arrivalTime)) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '🕐 ${swt.displayTime}',
                          style: GoogleFonts.poppins(
                            color: AppColors.green.withValues(alpha: 0.7),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              else if (swt.displayTime.isNotEmpty)
                // ✅ Intermediate stop: show scheduled time from trainTimes
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    swt.displayTime,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Divider between intermediate stops
        if (!isLast && !isKey)
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Divider(height: 1, color: const Color(0xFFEEF2F8)),
          ),
      ],
    );
  }
}
