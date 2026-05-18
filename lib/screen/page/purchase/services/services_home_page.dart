import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/purchase/services/car_rental_controller.dart';
import 'package:tuni_train/controller/purchase/services/place_controller.dart';
import 'package:tuni_train/controller/purchase/services/services_home_controller.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/models/services/place.dart';
import 'package:tuni_train/screen/widgets/car_card.dart';
import 'package:tuni_train/screen/widgets/place_card.dart';
import 'package:tuni_train/screen/widgets/service_section_header.dart';
import 'package:tuni_train/screen/widgets/services_skeleton.dart';

class ServicesHomePage extends StatelessWidget {
  ServicesHomePage({super.key});

  final ServicesHomeController ctrl = Get.put(ServicesHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _ServicesHeader(),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) return const ServicesHomeSkeleton();
              if (ctrl.hasError.value)
                return _ErrorState(onRetry: ctrl.reloadData);
              return _ServicesBody(ctrl: ctrl);
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ServicesHeader extends StatelessWidget {
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
                    child: Text(
                      'Nos Services',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/services/bookings'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.confirmation_num_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Mes Résa',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardPad,
                  vertical: AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.cardXl),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Text(
                      'Rechercher un service…',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 14,
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

// ─── Body ─────────────────────────────────────────────────────────────────────

class _ServicesBody extends StatelessWidget {
  final ServicesHomeController ctrl;

  const _ServicesBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.blue1,
      onRefresh: ctrl.reloadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.section,
          AppSpacing.pagePad,
          AppSpacing.section,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promotions banner
            _PromoBannerSection(),
            const SizedBox(height: AppSpacing.pagePad),

            // Categories grid
            ServiceSectionHeader(title: 'Catégories de Services'),
            const SizedBox(height: AppSpacing.xl),
            const _CategoriesGrid(),
            const SizedBox(height: AppSpacing.pagePad),

            // Featured cars
            Obx(
              () => ctrl.featuredCars.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ServiceSectionHeader(
                          title: 'Voitures en Vedette',
                          actionLabel: 'Voir tout',
                          onAction: () => Get.toNamed('/services/cars'),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _FeaturedCarsRow(cars: ctrl.featuredCars),
                        const SizedBox(height: AppSpacing.pagePad),
                      ],
                    ),
            ),

            // Featured places
            Obx(
              () => ctrl.featuredPlaces.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ServiceSectionHeader(
                          title: 'À Découvrir',
                          actionLabel: 'Voir tout',
                          onAction: () => Get.toNamed('/services/places'),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _FeaturedPlacesRow(places: ctrl.featuredPlaces),
                        const SizedBox(height: AppSpacing.pagePad),
                      ],
                    ),
            ),

            // My bookings CTA
            _MyBookingsCta(),
          ],
        ),
      ),
    );
  }
}

// ─── Promo Banner ─────────────────────────────────────────────────────────────

class _PromoBannerSection extends StatelessWidget {
  static const _promos = [
    _PromoItem(
      title: '20% sur les billets El Djem',
      subtitle: 'Offre valable jusqu\'au 30 juin',
      color1: Color(0xFF6B4EFF),
      color2: Color(0xFF9B6BFF),
      icon: Icons.local_activity_rounded,
    ),
    _PromoItem(
      title: 'Location voiture dès 45 DT/j',
      subtitle: 'Réservez 3 jours, économisez 15%',
      color1: AppColors.blue1,
      color2: AppColors.blue2,
      icon: Icons.directions_car_rounded,
    ),
    _PromoItem(
      title: 'Découvrez Sidi Bou Saïd',
      subtitle: 'Visite guidée incluse ce week-end',
      color1: Color(0xFF1D9E75),
      color2: Color(0xFF2DB38A),
      icon: Icons.place_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: PageView.builder(
        itemCount: _promos.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: AppSpacing.section),
          child: _PromoBannerCard(item: _promos[i]),
        ),
      ),
    );
  }
}

class _PromoItem {
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final IconData icon;

  const _PromoItem({
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.icon,
  });
}

class _PromoBannerCard extends StatelessWidget {
  final _PromoItem item;

  const _PromoBannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.color1, item.color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: item.color1.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                  ),
                  child: Text(
                    'En profiter',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            item.icon,
            color: Colors.white.withValues(alpha: 0.25),
            size: 64,
          ),
        ],
      ),
    );
  }
}

// ─── Categories Grid ─────────────────────────────────────────────────────────

class _ServiceCategory {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback action;

  const _ServiceCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.action,
  });
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();

  List<_ServiceCategory> _categories() => [
    _ServiceCategory(
      label: 'Location Voiture',
      icon: Icons.directions_car_rounded,
      color: AppColors.blue1,
      background: AppColors.bluePale,
      action: () => Get.toNamed('/services/cars'),
    ),
    _ServiceCategory(
      label: 'Lieux Touristiques',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFFC8A96E),
      background: const Color(0xFFFAEEDA),
      action: () {
        final ctrl = Get.find<PlaceController>();
        ctrl.setCategoryFilter(PlaceCategory.historicSite);
        Get.toNamed('/services/places');
      },
    ),
    _ServiceCategory(
      label: 'Hôtels',
      icon: Icons.hotel_rounded,
      color: const Color(0xFF7B2FBE),
      background: const Color(0xFFF3E8FF),
      action: () {
        final ctrl = Get.find<PlaceController>();
        ctrl.setCategoryFilter(PlaceCategory.hotel);
        Get.toNamed('/services/places');
      },
    ),
    _ServiceCategory(
      label: 'Restaurants',
      icon: Icons.restaurant_rounded,
      color: AppColors.green,
      background: AppColors.greenBg,
      action: () {
        final ctrl = Get.find<PlaceController>();
        ctrl.setCategoryFilter(PlaceCategory.restaurant);
        Get.toNamed('/services/places');
      },
    ),
    _ServiceCategory(
      label: 'Divertissement',
      icon: Icons.attractions_rounded,
      color: const Color(0xFFE91E8C),
      background: const Color(0xFFFCE4F3),
      action: () {
        final ctrl = Get.find<PlaceController>();
        ctrl.setCategoryFilter(PlaceCategory.entertainment);
        Get.toNamed('/services/places');
      },
    ),
    _ServiceCategory(
      label: 'Aventure',
      icon: Icons.landscape_rounded,
      color: const Color(0xFF00897B),
      background: const Color(0xFFE0F2F1),
      action: () {
        final ctrl = Get.find<PlaceController>();
        ctrl.setCategoryFilter(PlaceCategory.adventure);
        Get.toNamed('/services/places');
      },
    ),
    _ServiceCategory(
      label: 'Offres Promo',
      icon: Icons.local_offer_rounded,
      color: AppColors.orange,
      background: AppColors.sandBg,
      action: () => Get.toNamed('/services/places'),
    ),
    _ServiceCategory(
      label: 'Abonnements',
      icon: Icons.card_membership_rounded,
      color: AppColors.blue2,
      background: AppColors.bluePale,
      action: () => Get.toNamed('/subscription'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cats = _categories();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.78,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.xl,
      ),
      itemCount: cats.length,
      itemBuilder: (_, i) => _CategoryCard(category: cats[i]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _ServiceCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: category.action,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: category.background,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: category.color.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(category.icon, color: category.color, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            category.label,
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Featured Cars Row ────────────────────────────────────────────────────────

class _FeaturedCarsRow extends StatelessWidget {
  final List<CarRental> cars;

  const _FeaturedCarsRow({required this.cars});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        itemBuilder: (_, i) => CarCardHorizontal(
          car: cars[i],
          onTap: () {
            final carCtrl = Get.find<CarRentalController>();
            carCtrl.selectCar(cars[i]);
          },
        ),
      ),
    );
  }
}

// ─── Featured Places Row ──────────────────────────────────────────────────────

class _FeaturedPlacesRow extends StatelessWidget {
  final List<Place> places;

  const _FeaturedPlacesRow({required this.places});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        itemBuilder: (_, i) => PlaceCardHorizontal(
          place: places[i],
          onTap: () {
            final placeCtrl = Get.find<PlaceController>();
            placeCtrl.selectPlace(places[i]);
          },
        ),
      ),
    );
  }
}

// ─── My Bookings CTA ─────────────────────────────────────────────────────────

class _MyBookingsCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/services/bookings'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPad),
        decoration: BoxDecoration(
          gradient: AppColors.ctaGradient,
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.confirmation_num_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.cardPad),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Réservations',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Gérez vos locations et billets',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.pagePad),
          Text(
            'Erreur de chargement',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vérifiez votre connexion et réessayez.',
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.pagePad),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: AppSpacing.buttonPadding,
              decoration: BoxDecoration(
                color: AppColors.blue1,
                borderRadius: BorderRadius.circular(AppRadius.lg),
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
}
