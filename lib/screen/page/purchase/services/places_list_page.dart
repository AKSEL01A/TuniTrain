import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/purchase/services/place_controller.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/place.dart';
import 'package:tuni_train/screen/widgets/place_card.dart';
import 'package:tuni_train/screen/widgets/service_section_header.dart';
import 'package:tuni_train/screen/widgets/services_skeleton.dart';
import 'package:tuni_train/core/widgets/app_empty_state.dart';

class PlacesListPage extends StatelessWidget {
  PlacesListPage({super.key});

  final PlaceController ctrl = Get.put(PlaceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _PlacesHeader(ctrl: ctrl),
          _PlacesFilterBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) return const PlaceListSkeleton();
              if (ctrl.hasError.value) {
                return AppErrorState(onRetry: ctrl.reloadPlaces);
              }
              if (ctrl.displayedPlaces.isEmpty) {
                return AppEmptyState(
                  icon: Icons.place_rounded,
                  title: 'Aucun lieu trouvé',
                  body: 'Essayez de modifier vos filtres.',
                  actionLabel: 'Réinitialiser les filtres',
                  actionIcon: Icons.filter_alt_off_rounded,
                  onAction: ctrl.clearFilter,
                );
              }
              return RefreshIndicator(
                color: AppColors.blue1,
                onRefresh: ctrl.reloadPlaces,
                child: Obx(
                  () => ListView.builder(
                    padding: AppSpacing.listPadding,
                    itemCount: ctrl.displayedPlaces.length,
                    itemBuilder: (_, i) {
                      final place = ctrl.displayedPlaces[i];
                      return Obx(
                        () => PlaceCard(
                          place: place,
                          isFavorite: ctrl.isFavorite(place.id),
                          onTap: () => ctrl.selectPlace(place),
                          onFavorite: () => ctrl.toggleFavorite(place.id),
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

class _PlacesHeader extends StatelessWidget {
  final PlaceController ctrl;

  const _PlacesHeader({required this.ctrl});

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
                      'Lieux Touristiques',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${ctrl.displayedPlaces.length} lieu(x) disponible(s)',
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
                () => ctrl.hasActiveFilter
                    ? GestureDetector(
                        onTap: ctrl.clearFilter,
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

class _PlacesFilterBar extends StatelessWidget {
  final PlaceController ctrl;

  const _PlacesFilterBar({required this.ctrl});

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
              ServiceFilterChip(
                label: 'Recommandé',
                selected: ctrl.recommendedOnly.value,
                onTap: ctrl.toggleRecommendedOnly,
              ),
              const SizedBox(width: AppSpacing.md),
              ServiceFilterChip(
                label: 'Gratuit',
                selected: ctrl.freeOnly.value,
                onTap: ctrl.toggleFreeOnly,
              ),
              const SizedBox(width: AppSpacing.md),
              ...PlaceCategory.values.map(
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
