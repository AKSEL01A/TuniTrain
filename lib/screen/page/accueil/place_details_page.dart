import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuni_train/controller/purchase/services/place_controller.dart';
import 'package:tuni_train/models/services/place.dart';

class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PlaceController ctrl = Get.find<PlaceController>();

    return Obx(() {
      final place = ctrl.selectedPlace.value;
      if (place == null) {
        return const Scaffold(
          body: Center(child: Text('Aucun lieu sélectionné')),
        );
      }
      return _PlaceDetailView(place: place);
    });
  }
}

class _PlaceDetailView extends StatefulWidget {
  final Place place;
  const _PlaceDetailView({required this.place});

  @override
  State<_PlaceDetailView> createState() => _PlaceDetailViewState();
}

class _PlaceDetailViewState extends State<_PlaceDetailView> {
  int _imageIndex = 0;
  final PageController _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final topPad = MediaQuery.of(context).padding.top;
    final images = place.imageUrls;
    final hasTicketing = place.isTicketingEnabled && (place.price ?? 0) > 0;

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
                  height: 320 + topPad,
                  child: Stack(
                    children: [
                      // Images
                      images.isEmpty
                          ? _placeholder(320 + topPad)
                          : PageView.builder(
                              controller: _pageCtrl,
                              itemCount: images.length,
                              onPageChanged: (i) =>
                                  setState(() => _imageIndex = i),
                              itemBuilder: (_, i) =>
                                  _imageWidget(images[i], 320 + topPad),
                            ),

                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
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

                      // Category badge
                      Positioned(
                        top: topPad + 12,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            place.category.label,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0D1B4B),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      // Dots
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

                      // Price (if ticketing)
                      if (hasTicketing)
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
                              '${place.price!.toStringAsFixed(0)} DT / pers.',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                              place.name,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0D1B4B),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
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
                                  place.rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF0D1B4B),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  ' (${place.reviewsCount})',
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

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              place.location,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Tags
                      if (place.tags.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: place.tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EAF6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF1565C0),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      // Description
                      if (place.description.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('À propos'),
                        const SizedBox(height: 10),
                        Text(
                          place.description,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.65,
                          ),
                        ),
                      ],

                      // Info cards
                      const SizedBox(height: 24),
                      _sectionTitle('Informations'),
                      const SizedBox(height: 12),
                      _infoGrid(place),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky CTA ────────────────────────────────────────────
          if (hasTicketing || place.hasBooking)
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
                  onPressed: () {
                    if (hasTicketing) {
                      Get.toNamed('/services/places/booking');
                    } else {
                      Get.toNamed('/services/places/reserve');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B4B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    hasTicketing ? 'Acheter un billet' : 'Réserver',
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

  Widget _infoGrid(Place place) {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.category_rounded,
        'label': 'Catégorie',
        'value': place.category.label,
      },
      if (place.price != null && place.price! > 0)
        {
          'icon': Icons.confirmation_num_rounded,
          'label': 'Entrée',
          'value': '${place.price!.toStringAsFixed(1)} DT',
        },
      {
        'icon': Icons.star_rounded,
        'label': 'Note',
        'value': '${place.rating.toStringAsFixed(1)} / 5',
      },
      {
        'icon': Icons.reviews_rounded,
        'label': 'Avis',
        'value': '${place.reviewsCount} avis',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                item['icon'] as IconData,
                size: 18,
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['label'] as String,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      item['value'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0D1B4B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      color: const Color(0xFF0D1B4B),
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
  );

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
      Icons.landscape_rounded,
      color: Color(0xFF1565C0),
      size: 60,
    ),
  );
}
