import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/accueil_controller.dart';
import 'package:tuni_train/screen/page/search_train.dart';

class AccueilPageScreen extends StatefulWidget {
  const AccueilPageScreen({super.key});

  @override
  State<AccueilPageScreen> createState() => _AccueilPageScreenState();
}

class _AccueilPageScreenState extends State<AccueilPageScreen> {
  final AccueilController controller = Get.put(AccueilController());

  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'EEEE, d MMMM yyyy',
      'fr_FR',
    ).format(DateTime.now());

    final selectedDateStr = DateFormat(
      'd MMMM yyyy',
      'fr_FR',
    ).format(_selectedDate);

    final isToday =
        _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(dateStr),

              const SizedBox(height: 20),

              _buildSearchCard(selectedDateStr, isToday),

              const SizedBox(height: 24),

              _buildSectionTitle('Destinations populaires'),

              const SizedBox(height: 24),

              _buildSectionTitle('Services à bord'),

              const SizedBox(height: 10),

              _buildServices(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

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

            Text(
              'Bonjour, Hadil 👋',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.blue1,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'H',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SEARCH CARD
  // ─────────────────────────────────────────────

  Widget _buildSearchCard(String selectedDateStr, bool isToday) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // TITLE
          Row(
            children: [
              Icon(
                Icons.train_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 22,
              ),

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

          // FROM -> TO FIELD
          GestureDetector(
            onTap: () {
              Get.to(() => const SearchTrainPage());
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  // LEFT ICONS
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),

                      Container(
                        width: 2,
                        height: 30,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),

                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  // TEXTS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Station de départ",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Divider(
                          color: Colors.white.withValues(alpha: 0.15),
                          height: 1,
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "Station d'arrivée",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // SEARCH BUTTON
          GestureDetector(
            onTap: () {
              Get.to(() => const SearchTrainPage());
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.blue2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Rechercher un train',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SERVICES
  // ─────────────────────────────────────────────

  Widget _buildServices() {
    final services = [
      _Service(Icons.coffee_rounded, 'Café'),
      _Service(Icons.wifi_rounded, 'Wi-Fi'),
      _Service(Icons.airline_seat_recline_normal_rounded, 'Confort'),
      _Service(Icons.usb_rounded, 'USB'),
    ];

    return Row(
      children: services.map((service) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: service == services.last ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFB0C8E8), width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bluePale,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(service.icon, color: AppColors.blue1, size: 18),
                ),

                const SizedBox(height: 6),

                Text(
                  service.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION TITLE
  // ─────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.blue1,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SERVICE MODEL
// ─────────────────────────────────────────────

class _Service {
  final IconData icon;
  final String label;

  const _Service(this.icon, this.label);
}
