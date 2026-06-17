import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuni_train/controller/purchase/services/car_rental_controller.dart';
import 'package:tuni_train/models/services/car_rental.dart';

class CarDetailPage extends StatelessWidget {
  const CarDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CarRentalController ctrl = Get.find<CarRentalController>();

    return Obx(() {
      final car = ctrl.selectedCar.value;
      if (car == null) {
        return const Scaffold(
          body: Center(child: Text('Aucune voiture sélectionnée')),
        );
      }
      return _CarDetailView(car: car);
    });
  }
}

class _CarDetailView extends StatefulWidget {
  final CarRental car;
  const _CarDetailView({required this.car});

  @override
  State<_CarDetailView> createState() => _CarDetailViewState();
}

class _CarDetailViewState extends State<_CarDetailView> {
  int _imageIndex = 0;
  final PageController _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final topPad = MediaQuery.of(context).padding.top;
    final images = car.imageUrls;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image gallery ──────────────────────────────────────
                SizedBox(
                  height: 300 + topPad,
                  child: Stack(
                    children: [
                      // Images
                      images.isEmpty
                          ? _placeholder(300 + topPad)
                          : PageView.builder(
                              controller: _pageCtrl,
                              itemCount: images.length,
                              onPageChanged: (i) =>
                                  setState(() => _imageIndex = i),
                              itemBuilder: (_, i) =>
                                  _imageWidget(images[i], 300 + topPad),
                            ),

                      // Dark gradient at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Back button
                      Positioned(
                        top: topPad + 12,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Color(0xFF0D1B4B),
                            ),
                          ),
                        ),
                      ),

                      // Availability badge
                      Positioned(
                        top: topPad + 12,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: car.available
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            car.available ? 'Disponible' : 'Indisponible',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      // Image dots
                      if (images.length > 1)
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) {
                              final active = i == _imageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: active ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),

                      // Price tag
                      Positioned(
                        bottom: 14,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B4B),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${car.pricePerDay.toStringAsFixed(0)} DT / jour',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Main info card ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              car.displayName,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0D1B4B),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFC107),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  car.rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF0D1B4B),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  ' (${car.reviewsCount})',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Company + location
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              car.companyName,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              car.location,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Spec chips ──────────────────────────────────
                      _sectionTitle('Caractéristiques'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _specChip(
                            Icons.event_seat_rounded,
                            '${car.seats} sièges',
                          ),
                          _specChip(car.fuelType.icon, car.fuelType.label),
                          _specChip(
                            Icons.settings_rounded,
                            car.transmission.label,
                          ),
                          _specChip(
                            Icons.luggage_rounded,
                            '${car.luggageCapacity} bagages',
                          ),
                          _specChip(
                            _categoryIcon(car.category),
                            car.category.label,
                          ),
                        ],
                      ),

                      // ── Description ─────────────────────────────────
                      if (car.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Description'),
                        const SizedBox(height: 10),
                        Text(
                          car.description!,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],

                      // ── Amenities ────────────────────────────────────
                      if (car.amenities.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Équipements'),
                        const SizedBox(height: 12),
                        ...car.amenities.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF1565C0),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  a,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF0D1B4B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ── Contact ──────────────────────────────────────
                      if ((car.phone?.isNotEmpty == true) ||
                          (car.whatsapp?.isNotEmpty == true)) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Contact'),
                        const SizedBox(height: 12),
                        if (car.phone?.isNotEmpty == true)
                          _contactRow(Icons.phone_rounded, car.phone!),
                        if (car.whatsapp?.isNotEmpty == true)
                          _contactRow(
                            Icons.chat_rounded,
                            car.whatsapp!,
                            color: const Color(0xFF25D366),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky CTA ────────────────────────────────────────────
          if (car.available)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  MediaQuery.of(context).padding.bottom + 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/services/cars/booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B4B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Réserver maintenant',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageWidget(String url, double height) {
    if (url.startsWith('data:image')) {
      try {
        final bytes = base64Decode(url.split(',').last);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return _placeholder(height);
      }
    }
    return Image.network(
      url,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(height),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: const Color(0xFFE8EAF6),
              height: height,
              child: const Center(child: CircularProgressIndicator()),
            ),
    );
  }

  Widget _placeholder(double height) => Container(
    width: double.infinity,
    height: height,
    color: const Color(0xFFE8EAF6),
    child: const Icon(
      Icons.directions_car_rounded,
      color: Color(0xFF1565C0),
      size: 60,
    ),
  );

  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      color: const Color(0xFF0D1B4B),
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
  );

  Widget _specChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF1565C0)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF0D1B4B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _contactRow(
    IconData icon,
    String value, {
    Color color = const Color(0xFF1565C0),
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF0D1B4B),
          ),
        ),
      ],
    ),
  );

  IconData _categoryIcon(CarCategory c) => switch (c) {
    CarCategory.economy => Icons.savings_rounded,
    CarCategory.comfort => Icons.airline_seat_recline_extra_rounded,
    CarCategory.sedan => Icons.directions_car_rounded,
    CarCategory.suv => Icons.airport_shuttle_rounded,
    CarCategory.luxury => Icons.diamond_rounded,
    CarCategory.minibus => Icons.directions_bus_rounded,
    CarCategory.electric => Icons.electric_bolt_rounded,
    CarCategory.van => Icons.local_shipping_rounded,
  };
}
