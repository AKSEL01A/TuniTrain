import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/search_train_controller.dart';

/// Shows a draggable bottom sheet to pick a station.
void showStationPickerSheet(BuildContext context, {required bool isFrom}) {
  final controller = Get.find<SearchTrainController>();

  final isAll = controller.selectedNetwork.value == 'ALL';
  final List<String> allStations = isAll
      ? controller.stations.map((e) => e.name).toList()
      : controller.filteredStations.map((e) => e.name).toList();

  final ValueNotifier<List<String>> filtered =
      ValueNotifier<List<String>>(allStations);

  void filter(String query) {
    final q = query.toLowerCase();
    filtered.value =
        allStations.where((s) => s.toLowerCase().contains(q)).toList();
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.bgPage,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Handle
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const SizedBox(height: 14),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.train, color: AppColors.blue1),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() {
                            final isAll =
                                controller.selectedNetwork.value == 'ALL';
                            final line = controller.getSelectedLine();

                            return Text(
                              isAll
                                  ? "Toutes les stations"
                                  : "Stations de ${line?.name ?? ''}",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une station...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: filter,
                  ),
                ),

                const SizedBox(height: 12),

                // List
                Expanded(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: filtered,
                    builder: (_, list, _) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final station = list[i];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.location_on,
                                  color: AppColors.blue1,
                                ),
                                title: Text(
                                  station,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                onTap: () {
                                  controller.selectStation(isFrom, station);
                                  Navigator.pop(ctx);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
