import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/purchase/services/service_booking_controller.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/screen/widgets/booking_card.dart';
import 'package:tuni_train/screen/widgets/services_skeleton.dart';
import 'package:tuni_train/core/widgets/app_empty_state.dart';

class MyBookingsPage extends StatelessWidget {
  MyBookingsPage({super.key});

  final ServiceBookingController ctrl = Get.put(ServiceBookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _BookingsHeader(ctrl: ctrl),
          _BookingsTabBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) return const BookingListSkeleton();
              if (ctrl.hasError.value) {
                return AppErrorState(onRetry: ctrl.reloadBookings);
              }
              return Obx(() {
                final list = ctrl.selectedTab.value == 0
                    ? ctrl.activeBookings
                    : ctrl.pastBookings;
                if (list.isEmpty) {
                  final isActive = ctrl.selectedTab.value == 0;
                  return AppEmptyState(
                    icon: isActive
                        ? Icons.event_available_rounded
                        : Icons.history_toggle_off_rounded,
                    title: isActive
                        ? 'Aucune réservation active'
                        : 'Aucune réservation passée',
                    body: isActive
                        ? 'Réservez un service\npour le voir ici.'
                        : 'Vos réservations terminées\napparaîtront ici.',
                    actionLabel: isActive ? 'Explorer les services' : null,
                    actionIcon: isActive ? Icons.explore_rounded : null,
                    onAction: isActive ? () => Get.toNamed('/services') : null,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.blue1,
                  onRefresh: ctrl.reloadBookings,
                  child: ListView.builder(
                    padding: AppSpacing.listPadding,
                    itemCount: list.length,
                    itemBuilder: (_, i) => BookingCard(
                      booking: list[i],
                      onTap: () => ctrl.selectBooking(list[i]),
                    ),
                  ),
                );
              });
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _BookingsHeader extends StatelessWidget {
  final ServiceBookingController ctrl;

  const _BookingsHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.section,
            AppSpacing.sm,
            AppSpacing.section,
            AppSpacing.pagePad,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Réservations',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${ctrl.activeCount} active(s)',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
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
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class _BookingsTabBar extends StatelessWidget {
  final ServiceBookingController ctrl;

  const _BookingsTabBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Obx(
        () => Row(
          children: [
            _tab(label: 'Actives', index: 0, count: ctrl.activeCount),
            _tab(label: 'Historique', index: 1, count: ctrl.pastCount),
          ],
        ),
      ),
    );
  }

  Widget _tab({required String label, required int index, required int count}) {
    return Obx(() {
      final selected = ctrl.selectedTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => ctrl.setTab(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? AppColors.blue1 : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: selected ? AppColors.blue1 : AppColors.blue3,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.blue1 : AppColors.bluePale,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.poppins(
                        color: selected ? Colors.white : AppColors.blue2,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
