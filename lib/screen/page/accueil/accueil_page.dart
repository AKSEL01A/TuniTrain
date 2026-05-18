import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/auth/auth_controller.dart';
import 'package:tuni_train/controller/accueil/accueil_controller.dart';
import 'package:tuni_train/controller/purchase/services/car_rental_controller.dart';
import 'package:tuni_train/controller/purchase/services/place_controller.dart';
import 'package:tuni_train/data/data.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/models/services/place.dart';

class AccueilPageScreen extends StatelessWidget {
  const AccueilPageScreen({super.key});

  String get _todayStr =>
      DateFormat('EEEE, d MMMM yyyy', 'fr_FR').format(DateTime.now());

  AccueilController get _ctrl => Get.put(AccueilController());

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.blue1,
          onRefresh: ctrl.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(_todayStr),
                const SizedBox(height: 20),
                _buildSearchCard(),
                const SizedBox(height: 24),
                _buildNewsSection(ctrl),
                const SizedBox(height: 24),
                _buildSectionTitle('Nos Services'),
                const SizedBox(height: 14),
                _buildServicesRow(),
                const SizedBox(height: 24),
                _buildFeaturedCars(ctrl),
                const SizedBox(height: 24),
                _buildFeaturedPlaces(ctrl),
                const SizedBox(height: 24),
                _buildSectionTitle('Services à bord'),
                const SizedBox(height: 10),
                RfrLineEImportCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader(String dateStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Obx(() {
              final firstName =
                  Get.find<AuthController>().client.value?.firstName ?? '';
              return Text(
                'Bonjour $firstName 👋',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              );
            }),
          ],
        ),
        Obx(() {
          final user = Get.find<AuthController>().client.value;
          return CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.blue1,
            child: Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName[0].toUpperCase()
                  : '?',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── SEARCH CARD ──────────────────────────────────────────────────────────
  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.train_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Réserver un billet',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildStationsWidget(),
          const SizedBox(height: 16),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildStationsWidget() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4F8A), Color(0xFF2E6DB4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Station de départ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: Colors.white24)),
              GestureDetector(
                onTap: () => Get.toNamed('/searchtrain'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 25,
                    color: Color(0xFF1B4F8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Station d'arrivée",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => Get.toNamed('/searchtrain'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded, color: AppColors.bgPage, size: 20),
            const SizedBox(width: 8),
            Text(
              'Rechercher un train',
              style: GoogleFonts.poppins(
                color: AppColors.bgPage,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── NEWS ─────────────────────────────────────────────────────────────────
  Widget _buildNewsSection(AccueilController ctrl) {
    return Obx(() {
      if (ctrl.isLoadingNews.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Actualités'),
            const SizedBox(height: 12),
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.blue1),
              ),
            ),
          ],
        );
      }

      final news = ctrl.visibleNews;

      if (news.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Actualités'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greenBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tout va bien !',
                          style: GoogleFonts.poppins(
                            color: AppColors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Aucune perturbation sur le réseau.',
                          style: GoogleFonts.poppins(
                            color: AppColors.green.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionTitle('Actualités'),
              const SizedBox(width: 8),
              if (ctrl.hasAlerts)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ALERTE',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...news.map((item) => _buildNewsCard(item, ctrl)),
        ],
      );
    });
  }

  Widget _buildNewsCard(NewsItem item, AccueilController ctrl) {
    Color bg, border, iconColor, textColor;
    IconData icon;
    switch (item.type) {
      case 'warning':
        bg = AppColors.redBg;
        border = AppColors.red.withValues(alpha: 0.3);
        iconColor = AppColors.red;
        textColor = AppColors.red;
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        bg = AppColors.greenBg;
        border = AppColors.green.withValues(alpha: 0.3);
        iconColor = AppColors.green;
        textColor = AppColors.green;
        icon = Icons.celebration_rounded;
        break;
      default:
        bg = AppColors.bluePale;
        border = AppColors.blue1.withValues(alpha: 0.2);
        iconColor = AppColors.blue1;
        textColor = AppColors.blue1;
        icon = Icons.info_rounded;
    }
    final diff = DateTime.now().difference(item.date);
    final timeAgo = diff.inMinutes < 60
        ? 'Il y a ${diff.inMinutes} min'
        : diff.inHours < 24
        ? 'Il y a ${diff.inHours}h'
        : 'Il y a ${diff.inDays}j';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: GoogleFonts.poppins(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: GoogleFonts.poppins(
                    color: textColor.withValues(alpha: 0.85),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ctrl.dismissNews(item.id),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.close_rounded,
                color: textColor.withValues(alpha: 0.5),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SERVICES ROW (horizontal scroll) ────────────────────────────────────
  Widget _buildServicesRow() {
    final items = [
      _Svc(
        Icons.directions_car_rounded,
        'Voitures',
        const Color(0xFF1565C0),
        '/services/cars',
      ),
      _Svc(
        Icons.place_rounded,
        'Tourisme',
        const Color(0xFF00796B),
        '/services/places',
      ),
      _Svc(
        Icons.confirmation_number_rounded,
        'Billets',
        const Color(0xFF6A1B9A),
        '/my-journeys',
      ),
      // ✅ Fixed route — goes to StationsMapPage
      _Svc(
        Icons.map_rounded,
        'Carte Gares',
        const Color(0xFFE65100),
        '/TunisiaTrainData',
      ),
      _Svc(
        Icons.card_membership_rounded,
        'Abonnements',
        const Color(0xFF00838F),
        '/subscription',
      ),
      _Svc(
        Icons.grid_view_rounded,
        'Tous',
        const Color(0xFF37474F),
        '/services',
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          return GestureDetector(
            onTap: () => Get.toNamed(item.route),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── FEATURED CARS ────────────────────────────────────────────────────────
  Widget _buildFeaturedCars(AccueilController ctrl) {
    return Obx(() {
      if (ctrl.isLoadingData.value) return const SizedBox.shrink();
      if (ctrl.featuredCars.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Location de Voitures'),
              GestureDetector(
                onTap: () => Get.toNamed('/services/cars'),
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue2,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ctrl.featuredCars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _buildCarCard(ctrl.featuredCars[i]),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCarCard(CarRental car) {
    return GestureDetector(
      onTap: () {
        // Put controller then navigate to detail
        final c = Get.put(CarRentalController());
        c.selectCar(car);
        Get.toNamed('/services/cars/detail');
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: car.imageUrls.isNotEmpty
                  ? Image.network(
                      car.imageUrls.first,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _carImgPlaceholder(),
                    )
                  : _carImgPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${car.pricePerDay.toStringAsFixed(0)} DT/j',
                        style: GoogleFonts.poppins(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: car.available
                              ? AppColors.greenBg
                              : AppColors.redBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          car.available ? 'Dispo' : 'Indispo',
                          style: GoogleFonts.poppins(
                            color: car.available
                                ? AppColors.green
                                : AppColors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carImgPlaceholder() => Container(
    height: 80,
    width: double.infinity,
    color: AppColors.bluePale,
    child: const Icon(
      Icons.directions_car_rounded,
      color: AppColors.blue3,
      size: 32,
    ),
  );

  // ─── FEATURED PLACES ──────────────────────────────────────────────────────
  Widget _buildFeaturedPlaces(AccueilController ctrl) {
    return Obx(() {
      if (ctrl.isLoadingData.value) return const SizedBox.shrink();
      if (ctrl.featuredPlaces.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Lieux Touristiques'),
              GestureDetector(
                onTap: () => Get.toNamed('/services/places'),
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue2,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ctrl.featuredPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _buildPlaceCard(ctrl.featuredPlaces[i]),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPlaceCard(Place place) {
    return GestureDetector(
      onTap: () {
        final c = Get.put(PlaceController());
        c.selectPlace(place);
        Get.toNamed('/services/places/detail');
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: place.imageUrls.isNotEmpty
                  ? Image.network(
                      place.imageUrls.first,
                      height: 96,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeImgPlaceholder(),
                    )
                  : _placeImgPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_rounded,
                        size: 11,
                        color: AppColors.blue3,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          place.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue3,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  (place.price ?? 0) > 0
                      ? Text(
                          '${place.price!.toStringAsFixed(3)} DT',
                          style: GoogleFonts.poppins(
                            color: AppColors.sand,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Text(
                          'Gratuit',
                          style: GoogleFonts.poppins(
                            color: AppColors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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

  Widget _placeImgPlaceholder() => Container(
    height: 96,
    width: double.infinity,
    color: AppColors.bluePale,
    child: const Icon(Icons.place_rounded, color: AppColors.blue3, size: 32),
  );

  // ─── SECTION TITLE ────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.blue1,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Service shortcut data ────────────────────────────────────────────────────
class _Svc {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _Svc(this.icon, this.label, this.color, this.route);
}
