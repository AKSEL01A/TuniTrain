import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/data/firestore_service.dart';
import 'package:tuni_train/models/station.dart';
import 'package:tuni_train/models/train.dart';
import 'package:tuni_train/models/train_journey.dart';
import 'package:tuni_train/models/train_line.dart';

class SearchTrainController extends GetxController {
  final FirestoreService _firestore = FirestoreService();

  // ─────────────────────────────
  // LOADING
  // ─────────────────────────────
  RxBool isLoading = true.obs;
  RxBool searchLoading = false.obs;

  // ─────────────────────────────
  // DATA
  // ─────────────────────────────
  RxList<TrainLine> lines = <TrainLine>[].obs;
  RxList<Station> stations = <Station>[].obs;
  RxList<Train> trains = <Train>[].obs;
  RxList<TrainJourney> nextTrains = <TrainJourney>[].obs;
  Rx<DateTime?> departureDate = Rx<DateTime?>(null);
  Rx<DateTime?> departureDateTime = Rx<DateTime?>(null);
  RxBool hasReturn = false.obs;
  RxInt adults = 1.obs;
  RxInt children = 0.obs;

  Rx<TimeOfDay?> departureTime = Rx<TimeOfDay?>(null);

  Rx<DateTime?> returnDate = Rx<DateTime?>(null);
  Rx<TimeOfDay?> returnTime = Rx<TimeOfDay?>(null);
  Rx<DateTime?> returnDateTime = Rx<DateTime?>(null);

  // ─────────────────────────────
  // FILTERS
  // ─────────────────────────────
  RxString selectedNetwork = 'ALL'.obs;
  RxString from = ''.obs;
  RxString to = ''.obs;
  Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  RxString searchQuery = ''.obs;

  RxString selectedDate = ''.obs;
  RxInt babies = 0.obs;

  // ─────────────────────────────
  // INIT
  // ─────────────────────────────
  @override
  void onInit() {
    super.onInit();
    selectedNetwork.value = 'ALL'; // ✅ default
    loadData();
  }

  // ─────────────────────────────
  // LOAD DATA FROM FIRESTORE
  // ─────────────────────────────
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      lines.value = await _firestore.getTrainLines();
      stations.value = await _firestore.getAllStations();
      trains.value = await _firestore.getTrains();

      // default stations (ANY first two)
      if (stations.length >= 2) {
        from.value = stations.first.name;
        to.value = stations[1].name;
      }
    } catch (e) {
      debugPrint("LOAD DATA ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────
  // VIRTUAL "ALL LINES"
  // ─────────────────────────────
  List<TrainLine> get linesWithAll => lines;
  // ─────────────────────────────
  // FILTER STATIONS BY LINE
  // ─────────────────────────────
  List<Station> get filteredStations {
    if (selectedNetwork.value == 'ALL') {
      return stations;
    }

    final line = lines.firstWhereOrNull((l) => l.id == selectedNetwork.value);

    if (line == null) return stations;

    return stations.where((s) => line.stations.contains(s.name)).toList();
  }

  // ─────────────────────────────
  // CHANGE LINE
  // ─────────────────────────────
  void changeNetwork(String lineId) {
    selectedNetwork.value = lineId;

    // reset selection
    final filtered = filteredStations;

    if (filtered.isNotEmpty) {
      from.value = filtered.first.name;
      to.value = filtered.length > 1 ? filtered[1].name : '';
    }
  }

  // ─────────────────────────────
  // SELECT STATION
  // ─────────────────────────────
  void selectStation(bool isFrom, String stationName) {
    if (isFrom) {
      from.value = stationName;
    } else {
      to.value = stationName;
    }
  }

  String getStopsText(TrainJourney t) {
    final stops = t.toStopOrder - t.fromStopOrder;

    if (stops <= 1) {
      return "Direct";
    }

    return "$stops arrêts";
  }

  // ─────────────────────────────
  // SWAP
  // ─────────────────────────────
  void swapStations() {
    final temp = from.value;
    from.value = to.value;
    to.value = temp;
  }

  // ─────────────────────────────
  // SEARCH TRAINS
  // ─────────────────────────────
  Future<void> searchTrains() async {
    try {
      if (from.value.isEmpty || to.value.isEmpty) {
        Get.snackbar("Erreur", "Sélectionner les stations");
        return;
      }

      if (from.value == to.value) {
        Get.snackbar("Erreur", "Stations doivent être différentes");
        return;
      }

      if (selectedTime.value == null) {
        Get.snackbar("Erreur", "Sélectionner une heure");
        return;
      }

      searchLoading.value = true;
      nextTrains.clear();

      final result = await _firestore.searchTrains(
        fromStation: from.value,
        toStation: to.value,
        selectedTime: selectedTime.value!,
      );

      nextTrains.value = result;

      if (result.isEmpty) {
        Get.snackbar("Info", "Aucun train disponible");
      }
    } catch (e) {
      debugPrint("SEARCH ERROR: $e");
      Get.snackbar("Erreur", "Problème de recherche");
    } finally {
      searchLoading.value = false;
    }
  }

  // ─────────────────────────────
  // HELPERS
  // ─────────────────────────────
  Train? getTrainById(int id) {
    try {
      return trains.firstWhere((t) => t.trainNumber == id.toString());
    } catch (_) {
      return null;
    }
  }

  Station? getStationByName(String name) {
    try {
      return stations.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }

  TrainLine? getSelectedLine() {
    if (selectedNetwork.value == 'ALL') return null;
    return lines.firstWhereOrNull((l) => l.id == selectedNetwork.value);
  }
}
