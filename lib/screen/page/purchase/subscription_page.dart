import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/purchase/subscription_controller.dart';
import 'package:tuni_train/screen/page/payments/payment_page.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with SingleTickerProviderStateMixin {
  final SubscriptionController ctrl = Get.put(SubscriptionController());

  // QR countdown
  late AnimationController _qrAnim;
  int _secondsLeft = 30;

  static const _stepTitles = [
    'Choisir un plan',
    'Ligne de train',
    'Stations',
    'Vos informations',
    'Récapitulatif',
  ];
  static const _stepSubs = [
    'Sélectionnez la durée',
    'Choisissez la ligne',
    'Sélectionnez votre trajet',
    'Renseignez vos coordonnées',
    'Vérifiez et confirmez',
  ];
  static const _stepLabels = ['Plan', 'Ligne', 'Trajet', 'Profil', 'Confirm'];

  // ─── ROOT ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blue1),
          );
        }
        return _buildStepFlow(context);
      }),
    );
  }

  // ─── STEP FLOW ───────────────────────────────────────────────────────────
  Widget _buildStepFlow(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildStepIndicator(),
        Expanded(
          child: Obx(() {
            switch (ctrl.currentStep.value) {
              case 0:
                return _buildStepPlan();
              case 1:
                return _buildStepLine();
              case 2:
                return _buildStepStations();
              case 3:
                return _buildStepPersonal();
              case 4:
                return _buildStepReview();
              default:
                return const SizedBox.shrink();
            }
          }),
        ),
        _buildBottomNav(context),
      ],
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.fromLTRB(4, 6, 16, 18),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () =>
                    ctrl.currentStep.value > 0 ? ctrl.prevStep() : Get.back(),
              ),
              Expanded(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stepTitles[ctrl.currentStep.value.clamp(0, 4)],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _stepSubs[ctrl.currentStep.value.clamp(0, 4)],
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                final p = ctrl.currentPrice;
                if (p == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${p.toStringAsFixed(2)} DT',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STEP INDICATOR ──────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(
        () => Row(
          children: List.generate(_stepLabels.length, (i) {
            final done = i < ctrl.currentStep.value;
            final current = i == ctrl.currentStep.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => ctrl.goToStep(i),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? AppColors.green
                                  : current
                                  ? AppColors.blue1
                                  : const Color(0xFFE8EEF7),
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : Text(
                                      '${i + 1}',
                                      style: GoogleFonts.poppins(
                                        color: current
                                            ? Colors.white
                                            : AppColors.blue3,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _stepLabels[i],
                            style: GoogleFonts.poppins(
                              color: current
                                  ? AppColors.blue1
                                  : AppColors.blue3,
                              fontSize: 9,
                              fontWeight: current
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < _stepLabels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          color: done
                              ? AppColors.green
                              : const Color(0xFFE8EEF7),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── STEP 0 — PLAN ───────────────────────────────────────────────────────
  Widget _buildStepPlan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student toggle
          Obx(
            () => GestureDetector(
              onTap: ctrl.toggleStudent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ctrl.isStudent.value
                      ? AppColors.blue1.withValues(alpha: 0.07)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ctrl.isStudent.value
                        ? AppColors.blue1.withValues(alpha: 0.5)
                        : const Color(0xFFE0E9F8),
                    width: ctrl.isStudent.value ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.blue1.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppColors.blue1,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tarif étudiant',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '50% de réduction — vérification requise',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: ctrl.isStudent.value,
                      onChanged: (_) => ctrl.toggleStudent(),
                      activeThumbColor: AppColors.blue1,
                      activeTrackColor: AppColors.blue1.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Durée de l\'abonnement',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (ctrl.plans.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.blue1),
              );
            }
            const icons = {
              'weekly': Icons.date_range_rounded,
              'monthly': Icons.calendar_month_rounded,
              'annual': Icons.workspace_premium_rounded,
            };
            return Column(
              children: ctrl.plans.map((plan) {
                final icon = icons[plan.type] ?? Icons.calendar_today_rounded;
                final isAnnual = plan.type == 'annual';
                return Obx(() {
                  final sel = ctrl.selectedPlan.value?.id == plan.id;
                  final price = plan.priceFor(ctrl.isStudent.value);
                  return GestureDetector(
                    onTap: () => ctrl.selectPlan(plan),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.blue1 : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: sel
                              ? AppColors.blue1
                              : const Color(0xFFE0E9F8),
                          width: sel ? 2 : 1,
                        ),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: AppColors.blue1.withValues(alpha: 0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: sel
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppColors.blue1.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              icon,
                              color: sel ? Colors.white : AppColors.blue1,
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
                                      plan.label,
                                      style: GoogleFonts.poppins(
                                        color: sel
                                            ? Colors.white
                                            : AppColors.blue1,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (isAnnual) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: sel
                                              ? Colors.white.withValues(
                                                  alpha: 0.25,
                                                )
                                              : AppColors.sand.withValues(
                                                  alpha: 0.15,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Économique',
                                          style: GoogleFonts.poppins(
                                            color: sel
                                                ? Colors.white
                                                : AppColors.sand,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  plan.duration,
                                  style: GoogleFonts.poppins(
                                    color: sel
                                        ? Colors.white70
                                        : AppColors.blue3,
                                    fontSize: 12,
                                  ),
                                ),
                                if (plan.description.isNotEmpty)
                                  Text(
                                    plan.description,
                                    style: GoogleFonts.poppins(
                                      color: sel
                                          ? Colors.white54
                                          : AppColors.blue3.withValues(
                                              alpha: 0.6,
                                            ),
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${price.toStringAsFixed(2)} DT',
                                style: GoogleFonts.poppins(
                                  color: sel ? Colors.white : AppColors.blue1,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (ctrl.isStudent.value) ...[
                                Text(
                                  'étudiant',
                                  style: GoogleFonts.poppins(
                                    color: sel
                                        ? Colors.white70
                                        : AppColors.green,
                                    fontSize: 9,
                                  ),
                                ),
                                Text(
                                  '(${plan.price.toStringAsFixed(2)} DT)',
                                  style: GoogleFonts.poppins(
                                    color: sel
                                        ? Colors.white38
                                        : AppColors.blue3.withValues(
                                            alpha: 0.5,
                                          ),
                                    fontSize: 8,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
              }).toList(),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blue1.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.blue1.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.blue1,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Voyages illimités sur la ligne choisie pendant toute la durée de validité.',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 1 — LINE ───────────────────────────────────────────────────────
  Widget _buildStepLine() {
    return Obx(() {
      if (ctrl.lines.isEmpty) {
        return Center(
          child: Text(
            'Aucune ligne',
            style: GoogleFonts.poppins(color: AppColors.blue3),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: ctrl.lines.length,
        itemBuilder: (_, i) {
          final line = ctrl.lines[i];
          Color lc;
          try {
            lc = Color(
              int.parse('FF${line.color.replaceAll('#', '')}', radix: 16),
            );
          } catch (_) {
            lc = AppColors.blue1;
          }
          return Obx(() {
            final sel = ctrl.selectedLine.value?.id == line.id;
            return GestureDetector(
              onTap: () => ctrl.selectLine(line),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sel ? lc.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel ? lc : const Color(0xFFE0E9F8),
                    width: sel ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: lc.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          line.code,
                          style: GoogleFonts.poppins(
                            color: lc,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.name,
                            style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${line.startStation} → ${line.endStation}',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _lineTag(
                                '${line.totalStations} gares',
                                Icons.place_rounded,
                                lc,
                              ),
                              const SizedBox(width: 6),
                              _lineTag(
                                '${line.totalDistanceKm.toStringAsFixed(0)} km',
                                Icons.straighten_rounded,
                                lc,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (sel)
                      Icon(Icons.check_circle_rounded, color: lc, size: 24),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _lineTag(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 10),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  // ─── STEP 2 — STATIONS ───────────────────────────────────────────────────
  Widget _buildStepStations() {
    return Obx(() {
      final stations = ctrl.filteredStations;
      return Column(
        children: [
          if (ctrl.fromStation.value != null || ctrl.toStation.value != null)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue1.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _stationPill(
                      'Départ',
                      ctrl.fromStation.value?.name ?? 'Non sélectionné',
                      AppColors.green,
                      Icons.trip_origin_rounded,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.blue3,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: _stationPill(
                      'Arrivée',
                      ctrl.toStation.value?.name ?? 'Non sélectionné',
                      AppColors.red,
                      Icons.location_on_rounded,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Row(
              children: [
                Text(
                  'Sélectionnez votre trajet :',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (ctrl.fromStation.value == null)
                  _stationTag('1. Départ', AppColors.green)
                else if (ctrl.toStation.value == null)
                  _stationTag('2. Arrivée', AppColors.red)
                else
                  _stationTag('✓ Terminé', AppColors.green),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: stations.length,
              itemBuilder: (_, i) {
                final s = stations[i];
                final isFrom = ctrl.fromStation.value?.id == s.id;
                final isTo = ctrl.toStation.value?.id == s.id;
                Color ac = AppColors.blue1;
                if (isFrom) ac = AppColors.green;
                if (isTo) ac = AppColors.red;
                return GestureDetector(
                  onTap: () {
                    if (ctrl.fromStation.value == null) {
                      ctrl.selectFromStation(s);
                    } else if (ctrl.toStation.value == null &&
                        ctrl.fromStation.value?.id != s.id) {
                      ctrl.selectToStation(s);
                    } else if (isFrom) {
                      ctrl.selectFromStation(s);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: (isFrom || isTo)
                          ? ac.withValues(alpha: 0.07)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isFrom || isTo)
                            ? ac.withValues(alpha: 0.4)
                            : const Color(0xFFE8EEF7),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isFrom || isTo)
                                ? ac
                                : const Color(0xFFE8EEF7),
                          ),
                          child: Center(
                            child: isFrom
                                ? const Icon(
                                    Icons.trip_origin_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  )
                                : isTo
                                ? const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  )
                                : Text(
                                    '${s.stopOrder}',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.blue3,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: GoogleFonts.poppins(
                                  color: (isFrom || isTo)
                                      ? ac
                                      : AppColors.blue1,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (s.city.isNotEmpty)
                                Text(
                                  s.city,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.blue3,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (isFrom || isTo)
                                ? ac.withValues(alpha: 0.12)
                                : const Color(0xFFE8EEF7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Z${s.zoneNumber}',
                            style: GoogleFonts.poppins(
                              color: (isFrom || isTo) ? ac : AppColors.blue3,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isFrom || isTo) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle_rounded, color: ac, size: 18),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _stationPill(String label, String name, Color color, IconData icon) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _stationTag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: GoogleFonts.poppins(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  // ─── STEP 3 — PERSONAL ───────────────────────────────────────────────────
  Widget _buildStepPersonal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Obx(
                  () => GestureDetector(
                    onTap: ctrl.pickUserPhoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.blue1.withValues(alpha: 0.08),
                            border: Border.all(
                              color: AppColors.blue1.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: ctrl.userPhotoFile.value != null
                              ? ClipOval(
                                  child: Image.file(
                                    ctrl.userPhotoFile.value!,
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 110,
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.blue1,
                                  size: 52,
                                ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.blue1,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Photo de profil (apparaît sur l\'abonnement)',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blue1.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.blue1.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.security_rounded,
                  color: AppColors.blue1,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vos données sont sécurisées.',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Informations personnelles',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _formField(
            'Prénom',
            ctrl.firstNameCtrl,
            Icons.person_rounded,
            TextInputType.name,
          ),
          _formField(
            'Nom',
            ctrl.lastNameCtrl,
            Icons.badge_rounded,
            TextInputType.name,
          ),
          _formField(
            'Email',
            ctrl.emailCtrl,
            Icons.email_rounded,
            TextInputType.emailAddress,
          ),
          _formField(
            'Téléphone',
            ctrl.phoneCtrl,
            Icons.phone_rounded,
            TextInputType.phone,
          ),
          Obx(() {
            if (!ctrl.isStudent.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.sand.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.sand.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.sand,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Abonnement en attente jusqu\'à validation par l\'administration.',
                          style: GoogleFonts.poppins(
                            color: AppColors.sand,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Informations étudiantes',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _formField(
                  'Université / École',
                  ctrl.universityCtrl,
                  Icons.account_balance_rounded,
                  TextInputType.text,
                ),
                _formField(
                  'Numéro étudiant',
                  ctrl.studentIdCtrl,
                  Icons.numbers_rounded,
                  TextInputType.text,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController c,
    IconData icon,
    TextInputType type,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: c,
        keyboardType: type,
        style: GoogleFonts.poppins(color: AppColors.blue1, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.blue3, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    ),
  );

  // ─── STEP 4 — REVIEW ─────────────────────────────────────────────────────
  Widget _buildStepReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.blue1.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.blue1.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    child: ctrl.userPhotoFile.value != null
                        ? ClipOval(
                            child: Image.file(
                              ctrl.userPhotoFile.value!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            color: AppColors.blue1,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ctrl.firstNameCtrl.text} ${ctrl.lastNameCtrl.text}',
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ctrl.emailCtrl.text,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue3,
                            fontSize: 11,
                          ),
                        ),
                        if (ctrl.isStudent.value)
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blue1.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Étudiant · ${ctrl.universityCtrl.text}',
                              style: GoogleFonts.poppins(
                                color: AppColors.blue1,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _reviewSection('Abonnement', [
              _reviewRow('Plan', ctrl.typeName, Icons.calendar_today_rounded),
              _reviewRow('Durée', ctrl.durationLabel, Icons.schedule_rounded),
              _reviewRow(
                'Statut',
                ctrl.isStudent.value
                    ? 'En attente de validation'
                    : 'Actif immédiatement',
                Icons.verified_rounded,
              ),
            ]),
            const SizedBox(height: 12),
            _reviewSection('Trajet', [
              _reviewRow(
                'Ligne',
                ctrl.selectedLine.value?.name ?? '',
                Icons.train_rounded,
              ),
              _reviewRow(
                'Départ',
                ctrl.fromStation.value?.name ?? '',
                Icons.trip_origin_rounded,
              ),
              _reviewRow(
                'Arrivée',
                ctrl.toStation.value?.name ?? '',
                Icons.location_on_rounded,
              ),
            ]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue1, AppColors.blue2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue1.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total à payer',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${ctrl.currentPrice.toStringAsFixed(2)} DT',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (ctrl.isStudent.value)
                          Text(
                            'Tarif étudiant (-50%)',
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'En confirmant, vous acceptez nos conditions générales et la politique de non-remboursement.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewSection(String title, List<Widget> rows) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Divider(height: 16),
        ...rows,
      ],
    ),
  );

  Widget _reviewRow(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: AppColors.blue3, size: 16),
        const SizedBox(width: 10),
        Text(
          '$label :',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
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

  // ─── BOTTOM NAV ──────────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Obx(() {
      final isLast = ctrl.currentStep.value == 4;
      return Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (ctrl.currentStep.value > 0)
              GestureDetector(
                onTap: ctrl.prevStep,
                child: Container(
                  width: 48,
                  height: 52,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgPage,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDDE6F5)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.blue3,
                    size: 20,
                  ),
                ),
              ),
            Expanded(
              child: GestureDetector(
                onTap: isLast
                    ? () => Get.to(
                        () => const PaymentPage(type: PaymentType.subscription),
                      )
                    : ctrl.nextStep,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.blue2, AppColors.blue1],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue1.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ctrl.isSaving.value
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
                              Icon(
                                isLast
                                    ? Icons.payment_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isLast ? 'Confirmer l\'achat' : 'Continuer',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
    });
  }

  // ─── SUCCESS VIEW ────────────────────────────────────────────────────────
  Widget _buildSuccess(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final isPending = ctrl.isStudent.value;
          return Column(
            children: [
              const SizedBox(height: 16),

              // ── Abonnement Card ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0D2B6B),
                      Color(0xFF1565C0),
                      Color(0xFF1976D2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue1.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -10,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.train_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TuniTrain',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? AppColors.sand.withValues(alpha: 0.25)
                                      : AppColors.green.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isPending
                                        ? AppColors.sand.withValues(alpha: 0.5)
                                        : AppColors.green.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  isPending ? 'En attente' : 'Actif',
                                  style: GoogleFonts.poppins(
                                    color: isPending
                                        ? AppColors.sand
                                        : AppColors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                ),
                                child: ctrl.userPhotoBase64.value.isNotEmpty
                                    ? ClipOval(
                                        child: Image.memory(
                                          base64Decode(
                                            ctrl.userPhotoBase64.value,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white70,
                                        size: 28,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${ctrl.firstNameCtrl.text} ${ctrl.lastNameCtrl.text}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      ctrl.emailCtrl.text,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (ctrl.isStudent.value &&
                                        ctrl.universityCtrl.text.isNotEmpty)
                                      Text(
                                        ctrl.universityCtrl.text,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Divider(color: Colors.white.withValues(alpha: 0.15)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _cardInfo(
                                  'Type',
                                  ctrl.typeName,
                                  Icons.calendar_today_rounded,
                                ),
                              ),
                              Expanded(
                                child: _cardInfo(
                                  'Durée',
                                  ctrl.durationLabel,
                                  Icons.schedule_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.trip_origin_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ctrl.fromStation.value?.name ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white38,
                                  size: 14,
                                ),
                                Expanded(
                                  child: Text(
                                    ctrl.toStation.value?.name ?? '',
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                '${ctrl.currentPrice.toStringAsFixed(2)} DT',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Réf.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white38,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Text(
                                    ctrl.savedSubId.value.length > 12
                                        ? ctrl.savedSubId.value.substring(0, 12)
                                        : ctrl.savedSubId.value,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── QR / Pending ─────────────────────────────────────────────────
              if (!isPending)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.blue1,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'QR Code de contrôle',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Présentez ce code au contrôleur',
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.blue1.withValues(alpha: 0.15),
                            ),
                          ),
                          child: ctrl.liveQrCode.value.isEmpty
                              ? const SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: CircularProgressIndicator(
                                    color: AppColors.blue1,
                                  ),
                                )
                              : QrImageView(
                                  data: ctrl.liveQrCode.value,
                                  version: QrVersions.auto,
                                  size: 180,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _qrAnim,
                            builder: (_, _) => SizedBox(
                              width: 42,
                              height: 42,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: 1 - _qrAnim.value,
                                    strokeWidth: 3,
                                    backgroundColor: const Color(0xFFE8EEF7),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _secondsLeft <= 5
                                          ? AppColors.red
                                          : AppColors.blue1,
                                    ),
                                  ),
                                  Text(
                                    '$_secondsLeft',
                                    style: GoogleFonts.poppins(
                                      color: _secondsLeft <= 5
                                          ? AppColors.red
                                          : AppColors.blue1,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Actualisation automatique',
                                style: GoogleFonts.poppins(
                                  color: AppColors.blue1,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Le QR change toutes les 30 secondes',
                                style: GoogleFonts.poppins(
                                  color: AppColors.blue3,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shield_rounded,
                              color: AppColors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Code sécurisé anti-fraude',
                              style: GoogleFonts.poppins(
                                color: AppColors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sand.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.sand.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.hourglass_top_rounded,
                        color: AppColors.sand,
                        size: 36,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'En attente de validation',
                        style: GoogleFonts.poppins(
                          color: AppColors.sand,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'L\'administration vérifiera votre carte étudiante.\nVous recevrez votre QR code dès validation.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.sand,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  ctrl.reset();
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.blue2, AppColors.blue1],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue1.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Retour à l\'accueil',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _cardInfo(String label, String value, IconData icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
      ),
      const SizedBox(height: 3),
      Row(
        children: [
          Icon(icon, color: Colors.white60, size: 12),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
}
