import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/trains/train_statuts_controller.dart';
import 'package:tuni_train/models/trains/train.dart';

class TrainStatusPage extends StatelessWidget {
  const TrainStatusPage({super.key});

  TrainStatusController get ctrl => Get.put(TrainStatusController());

  @override
  Widget build(BuildContext context) {
    final c = ctrl;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(c),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Obx(() {
                if (!c.hasSearched.value) return _buildInitialState();
                if (c.isSearching.value) return _buildLoading();
                if (c.notFound.value) return _buildNotFound(c);
                final train = c.foundTrain.value;
                if (train == null) return const SizedBox.shrink();
                return _buildResult(c, train);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader(TrainStatusController c) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4F8A), Color(0xFF2E6DB4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suivi en direct',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Position & programme du train',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bluePale,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'N',
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: c.searchCtrl,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: (_) => c.searchTrain(),
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: '505, N101, 202…',
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blue3,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => c.hasSearched.value
                          ? GestureDetector(
                              onTap: c.clearSearch,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.blue3,
                                  size: 18,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Obx(
                      () => GestureDetector(
                        onTap: c.isSearching.value ? null : c.searchTrain,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E6DB4), Color(0xFF1B4F8A)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: c.isSearching.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Chercher',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ex: N505 · N101 · 202 (avec ou sans N)',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── INITIAL ──────────────────────────────────────────────────────────────
  Widget _buildInitialState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: AppColors.bluePale,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.train_rounded,
            color: AppColors.blue1,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Suivre un train',
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez le numéro du train (ex: N505)\npour voir tous les arrêts et leur statut.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppColors.blue3,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        ...[
          [
            Icons.location_on_rounded,
            'Position en temps réel',
            'Où se trouve le train maintenant',
          ],
          [
            Icons.schedule_rounded,
            'Statut par arrêt',
            'Passé · En cours · Pas encore parti',
          ],
          [
            Icons.table_rows_rounded,
            'Horaires complets',
            'Heure de départ et d\'arrivée à chaque gare',
          ],
        ].map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue1.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bluePale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      t[0] as IconData,
                      color: AppColors.blue1,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t[1] as String,
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        t[2] as String,
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() => const Center(
    child: Padding(
      padding: EdgeInsets.only(top: 80),
      child: CircularProgressIndicator(color: AppColors.blue1),
    ),
  );

  Widget _buildNotFound(TrainStatusController c) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.redBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search_off_rounded,
            color: AppColors.red,
            size: 38,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Train introuvable',
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aucun train avec ce numéro.\nVérifiez et réessayez.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 13),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: c.clearSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E6DB4), Color(0xFF1B4F8A)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Nouvelle recherche',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── RESULT ───────────────────────────────────────────────────────────────
  Widget _buildResult(TrainStatusController c, Train train) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Train info card ────────────────────────────────────────────────
        _buildTrainInfoCard(c, train),
        const SizedBox(height: 16),

        // ── Progress bar ───────────────────────────────────────────────────
        _buildProgressCard(c, train),
        const SizedBox(height: 20),

        // ── Full stop timeline ─────────────────────────────────────────────
        _buildStopTimeline(c),

        const SizedBox(height: 16),
        // Live indicator
        Obx(
          () => Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  c.lastUpdatedLabel,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── TRAIN INFO CARD ──────────────────────────────────────────────────────
  Widget _buildTrainInfoCard(TrainStatusController c, Train train) {
    return Obx(() {
      final lc = c.lineColor;
      final isOnTime = !train.isDelayed && train.isActive;
      final statusColor = !train.isActive
          ? AppColors.sand
          : isOnTime
          ? AppColors.green
          : AppColors.red;
      final statusBg = !train.isActive
          ? AppColors.sandBg
          : isOnTime
          ? AppColors.greenBg
          : AppColors.redBg;
      final statusIcon = !train.isActive
          ? Icons.schedule_rounded
          : isOnTime
          ? Icons.check_circle_rounded
          : Icons.warning_amber_rounded;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lc, lc.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: lc.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1: number + line + status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    c.displayTrainNumber,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line name
                      if (c.foundLine.value != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                c.foundLine.value!.code,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                c.foundLine.value!.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 3),
                      Text(
                        '${train.startStation} → ${train.endStation}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        c.statusLabel,
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),

            // Row 2: current position
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  // Animated dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          train.isActive
                              ? 'Position actuelle'
                              : 'Départ depuis',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          train.isActive
                              ? (train.currentStation.isNotEmpty
                                    ? train.currentStation
                                    : 'En route…')
                              : train.startStation,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Speed
                  if (train.isActive && train.currentSpeed > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${train.currentSpeed.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'km/h',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Delay banner
            if (train.isDelayed) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Retard de ${train.delayMinutes} minutes',
                      style: GoogleFonts.poppins(
                        color: AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ─── PROGRESS BAR ─────────────────────────────────────────────────────────
  Widget _buildProgressCard(TrainStatusController c, Train train) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(() {
        final progress = c.routeProgress;
        final lc = c.lineColor;
        return Column(
          children: [
            Row(
              children: [
                // Departure
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      train.startStation,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      train.firstDeparture,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.bluePale,
                            valueColor: AlwaysStoppedAnimation<Color>(lc),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          train.isActive
                              ? '${(progress * 100).toStringAsFixed(0)}% du trajet'
                              : 'Pas encore parti',
                          style: GoogleFonts.poppins(
                            color: train.isActive ? lc : AppColors.sand,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Arrival
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      train.endStation,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      train.lastDeparture,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  // ─── STOP TIMELINE ────────────────────────────────────────────────────────
  Widget _buildStopTimeline(TrainStatusController c) {
    return Obx(() {
      if (c.isLoadingStops.value) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.blue1),
          ),
        );
      }

      final enriched = c.enrichedStops;
      if (enriched.isEmpty) return const SizedBox.shrink();

      final lc = c.lineColor;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lc.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.route_rounded, color: lc, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Tous les arrêts',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${enriched.length} gares',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Row(
                children: [
                  _legendItem(
                    AppColors.green,
                    Icons.check_circle_rounded,
                    'Passé',
                  ),
                  const SizedBox(width: 14),
                  _legendItem(
                    lc,
                    Icons.radio_button_checked_rounded,
                    'En cours',
                  ),
                  const SizedBox(width: 14),
                  _legendItem(
                    const Color(0xFFBBCADC),
                    Icons.radio_button_unchecked_rounded,
                    'Pas encore parti',
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Stop list
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                children: enriched.asMap().entries.map((entry) {
                  final i = entry.key;
                  final info = entry.value;
                  final isLast = i == enriched.length - 1;
                  return _buildStopRow(info, i, isLast, lc, enriched.length);
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStopRow(
    StopInfo info,
    int index,
    bool isLast,
    Color lc,
    int total,
  ) {
    final stop = info.trainTime;
    final state = info.state;

    // Colors by state
    Color dotColor;
    Color textColor;
    Color timeColor;
    Color lineColor;
    double dotSize;
    Color stateBg;
    Color stateText;
    String stateLabel;
    IconData stateIcon;

    switch (state) {
      case StopState.passed:
        dotColor = AppColors.green;
        textColor = AppColors.blue3;
        timeColor = AppColors.blue3;
        lineColor = AppColors.green.withValues(alpha: 0.4);
        dotSize = 12;
        stateBg = AppColors.greenBg;
        stateText = AppColors.green;
        stateLabel = 'Passé';
        stateIcon = Icons.check_rounded;
        break;
      case StopState.current:
        dotColor = lc;
        textColor = AppColors.blue1;
        timeColor = lc;
        lineColor = lc.withValues(alpha: 0.3);
        dotSize = 16;
        stateBg = lc.withValues(alpha: 0.1);
        stateText = lc;
        stateLabel = 'En cours';
        stateIcon = Icons.train_rounded;
        break;
      case StopState.notDeparted:
        dotColor = const Color(0xFFCDD8E8);
        textColor = AppColors.blue3;
        timeColor = AppColors.blue3;
        lineColor = const Color(0xFFDDE6F5);
        dotSize = 10;
        stateBg = AppColors.bgPage;
        stateText = AppColors.blue3;
        stateLabel = 'Pas encore parti';
        stateIcon = Icons.schedule_rounded;
        break;
    }

    // First and last special labels
    final isFirst = index == 0;
    final isLastStop = index == total - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline column ──────────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top line
                if (!isFirst)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2.5,
                        color: index == 0 || state == StopState.current
                            ? lineColor
                            : (info.state == StopState.passed
                                  ? AppColors.green.withValues(alpha: 0.4)
                                  : const Color(0xFFDDE6F5)),
                      ),
                    ),
                  ),

                // Dot
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: state == StopState.current
                        ? lc
                        : state == StopState.passed
                        ? AppColors.green
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: state == StopState.current ? 0 : 2.5,
                    ),
                    boxShadow: state == StopState.current
                        ? [
                            BoxShadow(
                              color: lc.withValues(alpha: 0.45),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: state == StopState.passed
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: dotSize * 0.65,
                        )
                      : state == StopState.current
                      ? Icon(
                          Icons.train_rounded,
                          color: Colors.white,
                          size: dotSize * 0.6,
                        )
                      : null,
                ),

                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2.5,
                        color: state == StopState.passed && index < total - 1
                            ? AppColors.green.withValues(alpha: 0.4)
                            : const Color(0xFFDDE6F5),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // ── Content column ───────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : 10,
                bottom: isLast ? 0 : 10,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: state == StopState.current
                      ? lc.withValues(alpha: 0.06)
                      : state == StopState.passed
                      ? AppColors.bgPage
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state == StopState.current
                        ? lc.withValues(alpha: 0.25)
                        : state == StopState.passed
                        ? AppColors.green.withValues(alpha: 0.15)
                        : const Color(0xFFF0F4FA),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Station name
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stop.stationName,
                                  style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontSize: state == StopState.current
                                        ? 14
                                        : 13,
                                    fontWeight: state == StopState.current
                                        ? FontWeight.w800
                                        : state == StopState.passed
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                              // First / Last labels
                              if (isFirst)
                                _stopBadge(
                                  'DÉPART',
                                  AppColors.blue1,
                                  AppColors.bluePale,
                                )
                              else if (isLastStop)
                                _stopBadge(
                                  'DESTINATION',
                                  AppColors.green,
                                  AppColors.greenBg,
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Times row
                          Row(
                            children: [
                              // Arrival time
                              if (stop.arrivalTime != null) ...[
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 11,
                                  color: timeColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  stop.arrivalTime!,
                                  style: GoogleFonts.poppins(
                                    color: timeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              // Departure time
                              if (stop.departureTime != null) ...[
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 11,
                                  color: state == StopState.current
                                      ? lc
                                      : AppColors.blue3,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  stop.departureTime!,
                                  style: GoogleFonts.poppins(
                                    color: state == StopState.current
                                        ? lc
                                        : AppColors.blue3,
                                    fontSize: 12,
                                    fontWeight: state == StopState.current
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (stop.arrivalTime == null &&
                                  stop.departureTime == null)
                                Text(
                                  '—',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.blue3.withValues(
                                      alpha: 0.5,
                                    ),
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // State badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stateBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(stateIcon, color: stateText, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            stateLabel,
                            style: GoogleFonts.poppins(
                              color: stateText,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopBadge(String label, Color textColor, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _legendItem(Color color, IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 4),
      Text(
        label,
        style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 10),
      ),
    ],
  );
}
