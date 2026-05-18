import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/purchase/services/car_rental_controller.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/screen/widgets/car_card.dart';
import 'package:tuni_train/screen/widgets/service_section_header.dart';
import 'package:tuni_train/screen/widgets/services_skeleton.dart';
import 'package:tuni_train/core/widgets/app_empty_state.dart';

class CarRentalListPage extends StatelessWidget {
  CarRentalListPage({super.key});

  final CarRentalController ctrl = Get.put(CarRentalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _CarListHeader(ctrl: ctrl),
          _CarFilterBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) return const CarListSkeleton();
              if (ctrl.hasError.value) {
                return AppErrorState(onRetry: ctrl.reloadCars);
              }
              if (ctrl.displayedCars.isEmpty) {
                return AppEmptyState(
                  icon: Icons.directions_car_rounded,
                  title: 'Aucune voiture trouvée',
                  body: 'Essayez de modifier vos filtres.',
                  actionLabel: 'Réinitialiser les filtres',
                  actionIcon: Icons.filter_alt_off_rounded,
                  onAction: ctrl.clearFilters,
                );
              }
              return RefreshIndicator(
                color: AppColors.blue1,
                onRefresh: ctrl.reloadCars,
                child: Obx(
                  () => ListView.builder(
                    padding: AppSpacing.listPadding,
                    itemCount: ctrl.displayedCars.length,
                    itemBuilder: (_, i) {
                      final car = ctrl.displayedCars[i];
                      return Obx(
                        () => CarCard(
                          car: car,
                          isFavorite: ctrl.isFavorite(car.id),
                          onTap: () => ctrl.selectCar(car),
                          onFavorite: () => ctrl.toggleFavorite(car.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _CarListHeader extends StatelessWidget {
  final CarRentalController ctrl;

  const _CarListHeader({required this.ctrl});

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
                      'Location de Voitures',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${ctrl.displayedCars.length} véhicule(s) disponible(s)',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => ctrl.hasActiveFilters
                    ? GestureDetector(
                        onTap: ctrl.clearFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'Effacer',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────

class _CarFilterBar extends StatelessWidget {
  final CarRentalController ctrl;

  const _CarFilterBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.section,
          vertical: AppSpacing.xl,
        ),
        child: Obx(
          () => Row(
            children: [
              // Availability
              ServiceFilterChip(
                label: 'Disponible',
                selected: ctrl.availableOnly.value,
                onTap: ctrl.toggleAvailableOnly,
              ),
              const SizedBox(width: AppSpacing.md),
              // Fuel types
              ...FuelType.values.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: ServiceFilterChip(
                    label: f.label,
                    selected: ctrl.selectedFuelType.value == f,
                    onTap: () => ctrl.setFuelFilter(
                      ctrl.selectedFuelType.value == f ? null : f,
                    ),
                  ),
                ),
              ),
              // Categories
              ...CarCategory.values.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: ServiceFilterChip(
                    label: c.label,
                    selected: ctrl.selectedCategory.value == c,
                    onTap: () => ctrl.setCategoryFilter(
                      ctrl.selectedCategory.value == c ? null : c,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
