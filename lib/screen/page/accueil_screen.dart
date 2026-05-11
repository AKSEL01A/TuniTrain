import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/accueil_controller.dart';
import 'package:tuni_train/data/database_service.dart';
import 'package:tuni_train/models/service.dart';

class AccueilPageScreen extends StatefulWidget {
  const AccueilPageScreen({super.key});

  @override
  State<AccueilPageScreen> createState() => _AccueilPageScreenState();
}

class _AccueilPageScreenState extends State<AccueilPageScreen> {
  final AccueilController controller = Get.find<AccueilController>();

  DateTime selectedDate = DateTime.now();

  String get todayStr =>
      DateFormat('EEEE, d MMMM yyyy', 'fr_FR').format(DateTime.now());

  String get selectedDateStr =>
      DateFormat('d MMMM yyyy', 'fr_FR').format(selectedDate);

  bool get isToday =>
      selectedDate.day == DateTime.now().day &&
      selectedDate.month == DateTime.now().month &&
      selectedDate.year == DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(todayStr),
              const SizedBox(height: 20),
              _buildSearchCard(selectedDateStr, isToday),
              const SizedBox(height: 24),
              _buildSectionTitle('Destinations populaires'),
              const SizedBox(height: 24),
              _buildSectionTitle('Services à bord'),
              const SizedBox(height: 10),
              _buildServices(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirestoreStationFix.fixStationZones();

                  Get.snackbar(
                    "Done",
                    "Firestore fixed successfully",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: const Text("Fix Firestore DB"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────

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
              'Bonjour 👋',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppColors.blue1,
          child: Text('H', style: GoogleFonts.poppins(color: Colors.white)),
        ),
      ],
    );
  }

  // ───────────────── SEARCH CARD ─────────────────

  Widget _buildSearchCard(String selectedDateStr, bool isToday) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.blue1,
          borderRadius: BorderRadius.circular(24),
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
            _buildStations(),
            const SizedBox(height: 16),
            SizedBox(
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
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.bgPage,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Rechercher un train",
                      style: TextStyle(
                        color: AppColors.bgPage,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStations() {
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
          // ───── Departure ─────
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
                  "Station de départ",
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

          // ───── Connector (SEARCH / ROUTE INDICATOR) ─────
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

          // ───── Arrival ─────
          // ───── Arrival ─────
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

  // ───────────────── SERVICES ─────────────────

  Widget _buildServices() {
    final services = [
      Service(Icons.coffee, 'Café'),
      Service(Icons.wifi, 'Wi-Fi'),
      Service(Icons.airline_seat_recline_normal, 'Confort'),
      Service(Icons.usb, 'USB'),
    ];

    return Row(
      children: services.map((s) {
        return Expanded(
          child: Column(
            children: [
              Icon(s.icon, color: AppColors.blue1),
              const SizedBox(height: 6),
              Text(s.label),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ───────────────── TITLE ─────────────────

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
