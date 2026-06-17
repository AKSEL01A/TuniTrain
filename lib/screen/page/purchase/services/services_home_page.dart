import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/screen/page/accueil/car_details_page.dart';
import 'package:tuni_train/screen/page/accueil/place_details_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/purchase/services/car_rental_controller.dart';
import 'package:tuni_train/controller/purchase/services/place_controller.dart';
import 'package:tuni_train/controller/purchase/services/booking_controller.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/models/services/place.dart';

class ServicesHomePage extends StatefulWidget {
  const ServicesHomePage({super.key});
  @override
  State<ServicesHomePage> createState() => _ServicesHomePageState();
}

class _ServicesHomePageState extends State<ServicesHomePage>
    with SingleTickerProviderStateMixin {
  late final CarRentalController _carCtrl;
  late final PlaceController _placeCtrl;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _carCtrl = Get.put(CarRentalController());
    _placeCtrl = Get.put(PlaceController());
    Get.put(BookingController());
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgPage,
    body: NestedScrollView(
      headerSliverBuilder: (_, __) => [_sliverHeader()],
      body: Column(
        children: [
          _tabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _CarsTab(ctrl: _carCtrl),
                _PlacesTab(ctrl: _placeCtrl),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  SliverAppBar _sliverHeader() => SliverAppBar(
    expandedHeight: 200,
    collapsedHeight: 72,
    pinned: true,
    backgroundColor: AppColors.blue1,
    leading: const SizedBox.shrink(),
    flexibleSpace: FlexibleSpaceBar(
      collapseMode: CollapseMode.pin,
      background: _headerBackground(),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(0),
      child: SizedBox.shrink(),
    ),
  );

  Widget _headerBackground() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: Get.back,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
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
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Mes Réservations',
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
                  const SizedBox(height: 18),
                  Text(
                    'Que recherchez-vous ?',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.blue2,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Voitures, lieux touristiques…',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bluePale,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.blue1,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() => Container(
    color: AppColors.white,
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
    child: Row(
      children: [
        _tabPill(0, Icons.directions_car_rounded, 'Voitures'),
        const SizedBox(width: 10),
        _tabPill(1, Icons.place_rounded, 'Lieux & Tourisme'),
      ],
    ),
  );

  Widget _tabPill(int index, IconData icon, String label) {
    final active = _tabCtrl.index == index;
    return GestureDetector(
      onTap: () => _tabCtrl.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.blue1 : AppColors.bluePale,
          borderRadius: BorderRadius.circular(24),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.blue1.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? Colors.white : AppColors.blue2,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: active ? Colors.white : AppColors.blue2,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  CARS TAB
// ═══════════════════════════════════════════════════════════════════════════

class _CarsTab extends StatefulWidget {
  final CarRentalController ctrl;
  const _CarsTab({required this.ctrl});
  @override
  State<_CarsTab> createState() => _CarsTabState();
}

class _CarsTabState extends State<_CarsTab> {
  CarCategory? _activeFilter;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _statsRibbon(),
      _categoryFilters(),
      Expanded(
        child: Obx(() {
          if (widget.ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blue1),
            );
          }
          if (widget.ctrl.hasError.value) {
            return _errorState(widget.ctrl.reloadData);
          }
          final cars = _activeFilter == null
              ? widget.ctrl.cars
              : widget.ctrl.cars
                    .where((c) => c.category == _activeFilter)
                    .toList();
          if (cars.isEmpty) return _emptyState('Aucune voiture disponible');
          return RefreshIndicator(
            color: AppColors.blue1,
            onRefresh: widget.ctrl.reloadData,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              itemCount: cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _CarCard(car: cars[i], ctrl: widget.ctrl),
            ),
          );
        }),
      ),
    ],
  );

  Widget _statsRibbon() => Obx(() {
    final total = widget.ctrl.cars.length;
    final available = widget.ctrl.availableCars.length;
    final featured = widget.ctrl.featuredCars.length;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          _stat('$total', 'Total', AppColors.blue1),
          _div(),
          _stat('$available', 'Dispo', AppColors.green),
          _div(),
          _stat('$featured', 'Vedette', AppColors.orange),
        ],
      ),
    );
  });

  Widget _stat(String v, String l, Color c) => Expanded(
    child: Column(
      children: [
        Text(
          v,
          style: GoogleFonts.poppins(
            color: c,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          l,
          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 10),
        ),
      ],
    ),
  );

  Widget _div() => Container(width: 1, height: 30, color: AppColors.bgPage);

  Widget _categoryFilters() => Container(
    color: AppColors.white,
    padding: const EdgeInsets.only(bottom: 12),
    child: SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _chip(null, 'Tous'),
          ...CarCategory.values.map((c) => _chip(c, c.label)),
        ],
      ),
    ),
  );

  Widget _chip(CarCategory? cat, String label) {
    final active = _activeFilter == cat;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.blue1 : AppColors.bgPage,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.blue1 : AppColors.bluePale,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: active ? Colors.white : AppColors.blue2,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Car Card ─────────────────────────────────────────────────────────────────

class _CarCard extends StatelessWidget {
  final CarRental car;
  final CarRentalController ctrl;
  const _CarCard({required this.car, required this.ctrl});

  Future<void> _callPhone() async {
    final phone = car.phone;
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp() async {
    final wa = car.whatsapp;
    if (wa == null) return;
    final number = wa.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.blue1.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image ──────────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Stack(
            children: [
              _netImg(
                car.imageUrls.isNotEmpty ? car.imageUrls.first : null,
                height: 190,
                placeholder: Icons.directions_car_rounded,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _badge(car.category.label, AppColors.blue1),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _badge(
                  car.available ? '● Disponible' : '● Indispo',
                  car.available ? AppColors.green : AppColors.red,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue1.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${car.pricePerDay.toStringAsFixed(0)} DT / jour',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Info ───────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      car.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _starRating(car.rating, car.reviewsCount),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.business_rounded,
                    size: 13,
                    color: AppColors.blue3,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      car.companyName,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: AppColors.blue3,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      car.location,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _specChip(Icons.event_seat_rounded, '${car.seats} sièges'),
                  _specChip(car.fuelType.icon, car.fuelType.label),
                  _specChip(
                    Icons.settings_rounded,
                    car.transmission == TransmissionType.automatic
                        ? 'Auto'
                        : 'Manuel',
                  ),
                  _specChip(
                    Icons.luggage_rounded,
                    '${car.luggageCapacity} bagages',
                  ),
                ],
              ),

              if (car.amenities.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: car.amenities
                      .take(3)
                      .map(
                        (a) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sandBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            a,
                            style: GoogleFonts.poppins(
                              color: AppColors.sand,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: 16),

              // ── Actions — 2 buttons identiques aux Places ─────────────────
              Row(
                children: [
                  // Voir détails
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ctrl.selectCar(car);
                        Get.to(() => const CarDetailPage());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bluePale,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.blue3.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Voir détails',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Réserver OU Voir plus
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _CarMoreSheet.show(context, car),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue1, AppColors.blue2],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue1.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Réserver',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (car.phone != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _callPhone,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: AppColors.green,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                  if (car.whatsapp != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _openWhatsApp,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6FFF5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: Color(0xFF25D366),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PLACES TAB
// ═══════════════════════════════════════════════════════════════════════════

class _PlacesTab extends StatefulWidget {
  final PlaceController ctrl;
  const _PlacesTab({required this.ctrl});
  @override
  State<_PlacesTab> createState() => _PlacesTabState();
}

class _PlacesTabState extends State<_PlacesTab> {
  PlaceCategory? _activeFilter;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _statsRibbon(),
      _categoryFilters(),
      Expanded(
        child: Obx(() {
          if (widget.ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blue1),
            );
          }
          if (widget.ctrl.hasError.value) {
            return _errorState(widget.ctrl.reloadData);
          }
          final places = _activeFilter == null
              ? widget.ctrl.places
              : widget.ctrl.places
                    .where((p) => p.category == _activeFilter)
                    .toList();
          if (places.isEmpty) return _emptyState('Aucun lieu disponible');
          return RefreshIndicator(
            color: AppColors.blue1,
            onRefresh: widget.ctrl.reloadData,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) =>
                  _PlaceCard(place: places[i], ctrl: widget.ctrl),
            ),
          );
        }),
      ),
    ],
  );

  Widget _statsRibbon() => Obx(() {
    final total = widget.ctrl.places.length;
    final recommended = widget.ctrl.recommendedPlaces.length;
    final bookable = widget.ctrl.bookablePlaces.length;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          _stat('$total', 'Total', AppColors.blue1),
          _div(),
          _stat('$recommended', 'Recommandés', AppColors.sand),
          _div(),
          _stat('$bookable', 'Réservables', AppColors.green),
        ],
      ),
    );
  });

  Widget _stat(String v, String l, Color c) => Expanded(
    child: Column(
      children: [
        Text(
          v,
          style: GoogleFonts.poppins(
            color: c,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          l,
          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _div() => Container(width: 1, height: 30, color: AppColors.bgPage);

  Widget _categoryFilters() => Container(
    color: AppColors.white,
    padding: const EdgeInsets.only(bottom: 12),
    child: SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _chip(null, 'Tous', Icons.apps_rounded),
          ...PlaceCategory.values.map((c) => _chip(c, c.label, _catIcon(c))),
        ],
      ),
    ),
  );

  Widget _chip(PlaceCategory? cat, String label, IconData icon) {
    final active = _activeFilter == cat;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.blue1 : AppColors.bgPage,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.blue1 : AppColors.bluePale,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: active ? Colors.white : AppColors.blue2,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: active ? Colors.white : AppColors.blue2,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _catIcon(PlaceCategory c) => switch (c) {
    PlaceCategory.historicSite => Icons.account_balance_rounded,
    PlaceCategory.restaurant => Icons.restaurant_rounded,
    PlaceCategory.hotel => Icons.hotel_rounded,
    PlaceCategory.adventure => Icons.landscape_rounded,
    PlaceCategory.entertainment => Icons.attractions_rounded,
  };
}

// ─── Place Card ───────────────────────────────────────────────────────────────

class _PlaceCard extends StatelessWidget {
  final Place place;
  final PlaceController ctrl;
  const _PlaceCard({required this.place, required this.ctrl});

  Future<void> _callPhone() async {
    final phone = place.phone;
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.blue1.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image ──────────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Stack(
            children: [
              _netImg(
                place.imageUrls.isNotEmpty ? place.imageUrls.first : null,
                height: 200,
                placeholder: Icons.landscape_rounded,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _badge(place.category.label, AppColors.sand),
              ),
              if (place.isRecommended)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _badge('⭐ Recommandé', AppColors.orange),
                ),
              if (place.promotionText != null)
                Positioned(
                  top: place.isRecommended ? 46 : 12,
                  right: 12,
                  child: _badge(place.promotionText!, AppColors.red),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white70,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  place.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _starRating(place.rating, place.reviewsCount, dark: false),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Info ───────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (place.description.isNotEmpty)
                Text(
                  place.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

              if (place.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: place.tags
                      .take(4)
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bluePale,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#$t',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue2,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: 12),

              Row(
                children: [
                  if (place.openingHours != null) ...[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppColors.blue3,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.openingHours!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppColors.blue3,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  if (place.price != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${place.price!.toStringAsFixed(0)} DT',
                        style: GoogleFonts.poppins(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Actions — identiques aux Cars ─────────────────────────────
              Row(
                children: [
                  // Voir détails
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ctrl.selectPlace(place);
                        Get.to(() => const PlaceDetailPage());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bluePale,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.blue3.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Voir détails',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Réserver → ouvre le sheet
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _PlaceMoreSheet.show(context, place),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue1, AppColors.blue2],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue1.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Réserver',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (place.phone != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _callPhone,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: AppColors.green,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  CAR MORE SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _CarMoreSheet {
  static void show(BuildContext context, CarRental car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CarMoreSheetWidget(car: car),
    );
  }
}

class _CarMoreSheetWidget extends StatefulWidget {
  final CarRental car;
  const _CarMoreSheetWidget({required this.car});
  @override
  State<_CarMoreSheetWidget> createState() => _CarMoreSheetWidgetState();
}

class _CarMoreSheetWidgetState extends State<_CarMoreSheetWidget> {
  int _imgIdx = 0;
  bool _paying = false;

  Future<void> _callPhone() async {
    final phone = widget.car.phone;
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp() async {
    final wa = widget.car.whatsapp;
    if (wa == null) return;
    final number = wa.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onReserve() {
    Navigator.pop(context);
    _PaymentDialog.show(
      context,
      title: widget.car.displayName,
      subtitle: '${widget.car.pricePerDay.toStringAsFixed(0)} DT / jour',
      amount: widget.car.pricePerDay,
      type: 'car',
      itemId: widget.car.id,
      imageUrl: widget.car.imageUrls.isNotEmpty
          ? widget.car.imageUrls.first
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final imgs = car.imageUrls;

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6F5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Hero ──────────────────────────────────────────────────────
            SizedBox(
              height: 230,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: imgs.isNotEmpty
                        ? _netImg(
                            imgs[_imgIdx],
                            height: 230,
                            placeholder: Icons.directions_car_rounded,
                          )
                        : Container(
                            color: AppColors.bluePale,
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: AppColors.blue3,
                              size: 70,
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Row(
                      children: [
                        _badge(car.category.label, AppColors.blue1),
                        const SizedBox(width: 6),
                        _badge(
                          car.available ? '● Disponible' : '● Indispo',
                          car.available ? AppColors.green : AppColors.red,
                        ),
                      ],
                    ),
                  ),
                  if (imgs.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imgs.length > 6 ? 6 : imgs.length,
                          (i) {
                            final active = i == _imgIdx;
                            return GestureDetector(
                              onTap: () => setState(() => _imgIdx = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: active ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 60,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.displayName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 2,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              color: Colors.white70,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                car.companyName,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white70,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                car.location,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue1.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${car.pricePerDay.toStringAsFixed(0)} DT/j',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFF9A825,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF9A825),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${car.rating}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFE65100),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '  (${car.reviewsCount} avis)',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (car.featured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.orange,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'En vedette',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.orange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _sheetSection(
                      'Caractéristiques',
                      Icons.directions_car_rounded,
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.8,
                      children: [
                        _specTile(
                          Icons.event_seat_rounded,
                          'Sièges',
                          '${car.seats}',
                        ),
                        _specTile(
                          car.fuelType.icon,
                          'Carburant',
                          car.fuelType.label,
                        ),
                        _specTile(
                          Icons.settings_rounded,
                          'Transmission',
                          car.transmission == TransmissionType.automatic
                              ? 'Automatique'
                              : 'Manuelle',
                        ),
                        _specTile(
                          Icons.luggage_rounded,
                          'Bagages',
                          '${car.luggageCapacity} valise(s)',
                        ),
                        _specTile(
                          Icons.calendar_today_rounded,
                          'Année',
                          '${car.year}',
                        ),
                        _specTile(
                          Icons.category_rounded,
                          'Catégorie',
                          car.category.label,
                        ),
                      ],
                    ),

                    if (car.description != null &&
                        car.description!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _sheetSection('Description', Icons.notes_rounded),
                      const SizedBox(height: 8),
                      Text(
                        car.description!,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.65,
                        ),
                      ),
                    ],

                    if (car.amenities.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _sheetSection(
                        'Équipements',
                        Icons.check_circle_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: car.amenities
                            .map(
                              (a) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.sandBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.sand.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_rounded,
                                      color: AppColors.sand,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      a,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.sand,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    if (imgs.length > 1) ...[
                      const SizedBox(height: 18),
                      _sheetSection(
                        'Galerie (${imgs.length} photos)',
                        Icons.photo_library_rounded,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imgs.length,
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => setState(() => _imgIdx = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: i == _imgIdx
                                      ? AppColors.blue1
                                      : AppColors.bluePale,
                                  width: i == _imgIdx ? 2.5 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: SizedBox(
                                  width: 100,
                                  height: 80,
                                  child: _netImg(
                                    imgs[i],
                                    height: 80,
                                    placeholder: Icons.directions_car_rounded,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // ── Footer ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.bluePale)),
              ),
              child: Row(
                children: [
                  if (car.phone != null) ...[
                    GestureDetector(
                      onTap: _callPhone,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: AppColors.green,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (car.whatsapp != null) ...[
                    GestureDetector(
                      onTap: _openWhatsApp,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6FFF5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: Color(0xFF25D366),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.bluePale,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.blue3.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Fermer',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _onReserve,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue1, AppColors.blue2],
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Réserver',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetSection(String t, IconData icon) => Row(
    children: [
      Container(
        width: 3,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.blue1,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Icon(icon, color: AppColors.blue1, size: 15),
      const SizedBox(width: 6),
      Text(
        t,
        style: GoogleFonts.poppins(
          color: AppColors.blue1,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _specTile(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.bgPage,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.bluePale),
    ),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.blue1.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.blue1, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 9),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PLACE MORE SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _PlaceMoreSheet {
  static void show(BuildContext context, Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaceMoreSheetWidget(place: place),
    );
  }
}

class _PlaceMoreSheetWidget extends StatefulWidget {
  final Place place;
  const _PlaceMoreSheetWidget({required this.place});
  @override
  State<_PlaceMoreSheetWidget> createState() => _PlaceMoreSheetWidgetState();
}

class _PlaceMoreSheetWidgetState extends State<_PlaceMoreSheetWidget> {
  int _imgIdx = 0;

  void _onReserve() {
    Navigator.pop(context);
    _PaymentDialog.show(
      context,
      title: widget.place.name,
      subtitle: widget.place.price != null
          ? '${widget.place.price!.toStringAsFixed(3)} DT'
          : 'Entrée gratuite',
      amount: widget.place.price ?? 0,
      type: 'place',
      itemId: widget.place.id,
      imageUrl: widget.place.imageUrls.isNotEmpty
          ? widget.place.imageUrls.first
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final imgs = place.imageUrls;

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6F5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Hero ──────────────────────────────────────────────────────
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: imgs.isNotEmpty
                        ? _netImg(
                            imgs[_imgIdx],
                            height: 220,
                            placeholder: Icons.landscape_rounded,
                          )
                        : Container(
                            color: AppColors.bluePale,
                            child: const Icon(
                              Icons.landscape_rounded,
                              color: AppColors.blue3,
                              size: 60,
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                  if (imgs.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imgs.length > 6 ? 6 : imgs.length,
                          (i) {
                            final active = i == _imgIdx;
                            return GestureDetector(
                              onTap: () => setState(() => _imgIdx = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: active ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Positioned(
                    left: 18,
                    right: 60,
                    bottom: 26,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 2,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white70,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                place.location,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
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

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFF9A825,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF9A825),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${place.rating}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFE65100),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '  (${place.reviewsCount})',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (place.price != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${place.price!.toStringAsFixed(3)} DT',
                              style: GoogleFonts.poppins(
                                color: AppColors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Entrée gratuite',
                              style: GoogleFonts.poppins(
                                color: AppColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _placeBadge(place.category.label, AppColors.sand),
                        if (place.isRecommended)
                          _placeBadge('⭐ Recommandé', AppColors.orange),
                        if (place.isTicketingEnabled)
                          _placeBadge('🎫 Billetterie', AppColors.blue1),
                        if (place.hasBooking)
                          _placeBadge('📅 Réservation', AppColors.green),
                      ],
                    ),

                    if (place.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _sheetSection('Description', Icons.notes_rounded),
                      const SizedBox(height: 8),
                      Text(
                        place.description,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.65,
                        ),
                      ),
                    ],

                    if (place.openingHours != null ||
                        place.phone != null ||
                        place.email != null ||
                        place.externalLink != null) ...[
                      const SizedBox(height: 16),
                      _sheetSection(
                        'Infos pratiques',
                        Icons.info_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgPage,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.bluePale),
                        ),
                        child: Column(
                          children: [
                            if (place.openingHours != null)
                              _infoRow(
                                Icons.access_time_rounded,
                                'Horaires',
                                place.openingHours!,
                              ),
                            if (place.phone != null)
                              _infoRow(
                                Icons.phone_rounded,
                                'Téléphone',
                                place.phone!,
                              ),
                            if (place.email != null)
                              _infoRow(
                                Icons.email_rounded,
                                'Email',
                                place.email!,
                              ),
                            if (place.externalLink != null)
                              _infoRow(
                                Icons.language_rounded,
                                'Site web',
                                place.externalLink!,
                              ),
                          ],
                        ),
                      ),
                    ],

                    if (imgs.length > 1) ...[
                      const SizedBox(height: 16),
                      _sheetSection(
                        'Galerie (${imgs.length} photos)',
                        Icons.photo_library_rounded,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imgs.length,
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => setState(() => _imgIdx = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: i == _imgIdx
                                      ? AppColors.blue1
                                      : AppColors.bluePale,
                                  width: i == _imgIdx ? 2.5 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: SizedBox(
                                  width: 100,
                                  height: 80,
                                  child: _netImg(
                                    imgs[i],
                                    height: 80,
                                    placeholder: Icons.landscape_rounded,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (place.promotionText != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_offer_rounded,
                              color: AppColors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                place.promotionText!,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFE65100),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (place.tags.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _sheetSection('Tags', Icons.tag_rounded),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: place.tags
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bluePale,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '#$t',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.blue2,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Footer ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.bluePale)),
              ),
              child: Row(
                children: [
                  if (place.phone != null) ...[
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri(scheme: 'tel', path: place.phone);
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: AppColors.green,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.bluePale,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.blue3.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Fermer',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _onReserve,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue1, AppColors.blue2],
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                place.isTicketingEnabled
                                    ? Icons.confirmation_number_rounded
                                    : Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                place.isTicketingEnabled
                                    ? 'Acheter un billet'
                                    : 'Réserver',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetSection(String t, IconData icon) => Row(
    children: [
      Container(
        width: 3,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.blue1,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Icon(icon, color: AppColors.blue1, size: 15),
      const SizedBox(width: 6),
      Text(
        t,
        style: GoogleFonts.poppins(
          color: AppColors.blue1,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.blue1.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.blue1, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 9),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _placeBadge(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      t,
      style: GoogleFonts.poppins(
        color: c,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PAYMENT DIALOG
// ═══════════════════════════════════════════════════════════════════════════

class _PaymentDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double amount,
    required String type,
    required String itemId,
    String? imageUrl,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentWidget(
        title: title,
        subtitle: subtitle,
        amount: amount,
        type: type,
        itemId: itemId,
        imageUrl: imageUrl,
      ),
    );
  }
}

class _PaymentWidget extends StatefulWidget {
  final String title, subtitle, type, itemId;
  final double amount;
  final String? imageUrl;
  const _PaymentWidget({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.itemId,
    this.imageUrl,
  });
  @override
  State<_PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<_PaymentWidget> {
  final _nameC = TextEditingController();
  final _cardC = TextEditingController();
  final _expiryC = TextEditingController();
  final _cvvC = TextEditingController();
  int _method = 0; // 0=card, 1=espèces, 2=virement
  bool _loading = false;

  static const _methods = [
    (icon: Icons.credit_card_rounded, label: 'Carte bancaire'),
    (icon: Icons.payments_rounded, label: 'Espèces'),
    (icon: Icons.account_balance_rounded, label: 'Virement'),
  ];

  @override
  void dispose() {
    _nameC.dispose();
    _cardC.dispose();
    _expiryC.dispose();
    _cvvC.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      final ctrl = Get.find<BookingController>();
      await ctrl.reserve(
        type: widget.type,
        itemId: widget.itemId,
        title: widget.title,
        amount: widget.amount,
        method: _methods[_method].label,
        imageUrl: widget.imageUrl,
      );
      if (mounted) {
        Navigator.pop(context);
        _SuccessDialog.show(context, widget.title);
      }
    } catch (e) {
      setState(() => _loading = false);
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: AppColors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 420,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        color: Colors.white,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blue1, AppColors.blue2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paiement sécurisé',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Amount ───────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: AppColors.bgPage,
              child: Column(
                children: [
                  Text(
                    'Montant à payer',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.amount.toStringAsFixed(3)} DT',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment method
                    Text(
                      'Méthode de paiement',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(_methods.length, (i) {
                        final active = _method == i;
                        final m = _methods[i];
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: i < _methods.length - 1 ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => setState(() => _method = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.blue1.withValues(alpha: 0.08)
                                      : AppColors.bgPage,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: active
                                        ? AppColors.blue1
                                        : AppColors.bluePale,
                                    width: active ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      m.icon,
                                      color: active
                                          ? AppColors.blue1
                                          : AppColors.blue3,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      m.label,
                                      style: GoogleFonts.poppins(
                                        color: active
                                            ? AppColors.blue1
                                            : AppColors.blue3,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    // Card form
                    if (_method == 0) ...[
                      const SizedBox(height: 18),
                      Text(
                        'Détails de la carte',
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _payField(
                        'Nom sur la carte',
                        _nameC,
                        Icons.person_rounded,
                      ),
                      _payField(
                        'Numéro de carte',
                        _cardC,
                        Icons.credit_card_rounded,
                        type: TextInputType.number,
                        hint: '•••• •••• •••• ••••',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _payField(
                              'Expiration',
                              _expiryC,
                              Icons.calendar_today_rounded,
                              hint: 'MM/AA',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _payField(
                              'CVV',
                              _cvvC,
                              Icons.lock_outline_rounded,
                              type: TextInputType.number,
                              hint: '•••',
                              obscure: true,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_method == 1) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_rounded,
                              color: AppColors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Payez en espèces à la réception du service. '
                                'Votre réservation sera confirmée immédiatement.',
                                style: GoogleFonts.poppins(
                                  color: AppColors.green,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_method == 2) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bluePale,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.blue3.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations bancaires',
                              style: GoogleFonts.poppins(
                                color: AppColors.blue1,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _bankRow('Banque', 'TuniTrain Bank'),
                            _bankRow('IBAN', 'TN59 0000 0000 0000 0000 0000'),
                            _bankRow('BIC', 'TTBITNTT'),
                            _bankRow(
                              'Référence',
                              widget.itemId.substring(0, 8).toUpperCase(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.bluePale)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.bgPage,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.bluePale),
                        ),
                        child: Center(
                          child: Text(
                            'Annuler',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _loading ? null : _confirm,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue1, AppColors.blue2],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue1.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Confirmer & Payer',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _payField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? hint,
    bool obscure = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.blue1),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.blue3),
        hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.blue3),
        prefixIcon: Icon(icon, color: AppColors.blue3, size: 18),
        filled: true,
        fillColor: AppColors.bgPage,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bluePale),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue1, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    ),
  );

  Widget _bankRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 11),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Success dialog ────────────────────────────────────────────────────────
class _SuccessDialog {
  static void show(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.green,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Réservation confirmée !',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Votre réservation pour "$name" a été enregistrée.',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.bgPage,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.bluePale),
                        ),
                        child: Center(
                          child: Text(
                            'Fermer',
                            style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/services/bookings');
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue1, AppColors.blue2],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Mes Réservations',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════════════

Widget _netImg(
  String? url, {
  required double height,
  required IconData placeholder,
}) {
  final fallback = Container(
    width: double.infinity,
    height: height,
    color: AppColors.bluePale,
    child: Icon(placeholder, color: AppColors.blue3, size: 48),
  );
  if (url == null || url.trim().isEmpty) return fallback;
  if (url.startsWith('data:image')) {
    try {
      final bytes = base64Decode(url.split(',').last);
      return Image.memory(
        bytes,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } catch (_) {
      return fallback;
    }
  }
  return Image.network(
    url,
    width: double.infinity,
    height: height,
    fit: BoxFit.cover,
    loadingBuilder: (_, child, progress) {
      if (progress == null) return child;
      return Container(
        width: double.infinity,
        height: height,
        color: AppColors.bluePale,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.blue1,
            strokeWidth: 2,
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        ),
      );
    },
    errorBuilder: (_, __, ___) => fallback,
  );
}

Widget _badge(String text, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.35),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Text(
    text,
    style: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ),
  ),
);

Widget _starRating(double rating, int count, {bool dark = true}) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 15),
    const SizedBox(width: 3),
    Text(
      rating.toStringAsFixed(1),
      style: GoogleFonts.poppins(
        color: dark ? AppColors.blue1 : Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
    Text(
      ' ($count)',
      style: GoogleFonts.poppins(
        color: dark ? Colors.grey[500] : Colors.white70,
        fontSize: 10,
      ),
    ),
  ],
);

Widget _specChip(IconData icon, String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.bluePale,
    borderRadius: BorderRadius.circular(10),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: AppColors.blue1),
      const SizedBox(width: 5),
      Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.blue1,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
);

Widget _emptyState(String msg) => Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.bluePale,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.inbox_rounded,
          color: AppColors.blue3,
          size: 36,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        msg,
        style: GoogleFonts.poppins(
          color: AppColors.blue1,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
);

Widget _errorState(Future<void> Function() onRetry) => Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.redBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.wifi_off_rounded,
          color: AppColors.red,
          size: 36,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Erreur de chargement',
        style: GoogleFonts.poppins(
          color: AppColors.blue1,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Vérifiez votre connexion',
        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
      ),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
