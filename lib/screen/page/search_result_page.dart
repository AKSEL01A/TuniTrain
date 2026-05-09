import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/search_train_controller.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/data/data.dart';
import 'package:tuni_train/models/train_journey.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  int _selectedDay = 2;

  final _days = List.generate(
    5,
    (i) => DateTime.now().add(Duration(days: i - 2)),
  );

  int _toMin(String t) {
    try {
      final p = t.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    } catch (_) {
      return 0;
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _calcDuration(String dep, String arr) {
    var diff = _toMin(arr) - _toMin(dep);
    if (diff < 0) diff += 1440;
    if (diff == 0) return '';
    final h = diff ~/ 60;
    final m = diff % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m.toString().padLeft(2, '0')}';
  }

  bool _isNextDay(String dep, String arr) => _toMin(arr) < _toMin(dep);

  List<String> _dayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SearchTrainController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: Column(
        children: [
          _buildHeader(ctrl),
          _buildDayBar(),
          _buildCountBar(ctrl),

          // 👇 THIS IS THE IMPORTANT PART
          Expanded(
            child: Obx(() {
              if (ctrl.searchLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (ctrl.nextTrains.isEmpty) {
                return const Center(
                  child: Text(
                    "No trains available",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.nextTrains.length,
                itemBuilder: (context, index) {
                  final t = ctrl.nextTrains[index];
                  return _buildTrainCard(t); // your card function
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTrainCard(TrainJourney t) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${t.fromStation} → ${t.toStation}"),
              Text("Train ${t.trainId}"),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.departureTime),
              const Icon(Icons.train),
              Text(t.arrivalTime),
            ],
          ),

          const SizedBox(height: 10),

          Text(Get.find<SearchTrainController>().getStopsText(t)),
        ],
      ),
    );
  }

  Widget _timeColumn(String label, String time) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────
  Widget _buildHeader(SearchTrainController controller) {
    return Container(
      color: AppColors.blue1,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white60,
                      size: 18,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  const Spacer(),
                  Text(
                    'Aller simple',
                    style: GoogleFonts.barlow(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.home_outlined,
                      color: Colors.white60,
                      size: 22,
                    ),
                    onPressed: () => Get.offAllNamed('/home'),
                  ),
                ],
              ),

              Obx(() {
                final from = controller.from.value;
                final to = controller.to.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DÉPART',
                              style: GoogleFonts.barlow(
                                color: Colors.white38,
                                fontSize: 9,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              from.isEmpty ? '—' : from,
                              style: GoogleFonts.barlow(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 12,
                          right: 12,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Divider(
                                color: AppColors.sand.withOpacity(0.6),
                                thickness: 1,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.sand,
                              size: 16,
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ARRIVÉE',
                              style: GoogleFonts.barlow(
                                color: Colors.white38,
                                fontSize: 9,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              to.isEmpty ? '—' : to,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.barlow(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              Obx(() {
                // ⚠️ adjust names depending on your controller
                final date = controller.departureDateTime.value;
                final time = controller.selectedTime.value;
                final adults = controller.adults.value;
                final babies = controller.babies.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // DATE + TIME
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DATE',
                            style: GoogleFonts.barlow(
                              color: Colors.white38,
                              fontSize: 9,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            date == null
                                ? "—"
                                : "${date.day.toString().padLeft(2, '0')} "
                                      "${DaysData.months[date.month - 1]} "
                                      "${date.year}",
                            style: GoogleFonts.barlow(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'TIME',
                            style: GoogleFonts.barlow(
                              color: Colors.white38,
                              fontSize: 9,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            time == null ? "—" : time.format(context),
                            style: GoogleFonts.barlow(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      // PASSENGERS
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PASSAGERS',
                            style: GoogleFonts.barlow(
                              color: Colors.white38,
                              fontSize: 9,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),

                          Text(
                            'Adult: $adults',
                            style: GoogleFonts.barlow(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Bébé: $babies',
                            style: GoogleFonts.barlow(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── DAY BAR ─────────────────────────
  Widget _buildDayBar() {
    return Container(
      color: AppColors.blue1,
      child: Column(
        children: [
          Container(height: 1, color: AppColors.sand.withOpacity(0.25)),
          SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_days.length, (i) {
                final d = _days[i];
                final isSelected = i == _selectedDay;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = i),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? AppColors.sand
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _dayLabels[d.weekday - 1].toUpperCase(),
                            style: GoogleFonts.barlow(
                              color: isSelected
                                  ? AppColors.sand
                                  : Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            d.day.toString().padLeft(2, '0'),
                            style: GoogleFonts.barlow(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontSize: 18,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── COUNT BAR ─────────────────────────
  Widget _buildCountBar(SearchTrainController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Obx(
            () => RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${controller.nextTrains.length}',
                    style: GoogleFonts.barlow(
                      color: AppColors.blue1,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' trains disponibles',
                    style: GoogleFonts.barlow(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
