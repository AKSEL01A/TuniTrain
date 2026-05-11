import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/data/firestore_service.dart';
import 'package:tuni_train/models/station.dart';
import 'package:tuni_train/models/train.dart';
import 'package:tuni_train/models/train_journey.dart';
import 'package:tuni_train/models/train_line.dart';
import 'package:tuni_train/screen/page/search_result_page.dart';

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
  RxInt selectedDayIndex = 2.obs;
  RxList<TrainLine> lines = <TrainLine>[].obs;
  RxList<Station> stations = <Station>[].obs;
  RxList<Train> trains = <Train>[].obs;
  RxList<TrainJourney> nextTrains = <TrainJourney>[].obs;
  Rx<DateTime?> departureDate = Rx<DateTime?>(null);
  Rx<DateTime?> departureDateTime = Rx<DateTime?>(null);
  RxBool hasReturn = false.obs;
  RxInt adults = 1.obs;
  RxInt children = 0.obs;
  RxBool showCouponField = false.obs;
  RxString couponCode = ''.obs;
  Rx<TimeOfDay?> departureTime = Rx<TimeOfDay?>(null);
  RxMap<String, Train> trainMap = <String, Train>{}.obs;
  Rx<DateTime?> returnDate = Rx<DateTime?>(null);
  Rx<TimeOfDay?> returnTime = Rx<TimeOfDay?>(null);
  Rx<DateTime?> returnDateTime = Rx<DateTime?>(null);
  Rxn<Train> selectedTrain = Rxn<Train>();
  bool get isRoundTrip => hasReturn.value;
  int get totalPassengers => adults.value + children.value + babies.value;
  Rxn<TrainJourney> selectedAller = Rxn<TrainJourney>();
  Rxn<TrainJourney> selectedRetour = Rxn<TrainJourney>();
  RxString searchMode = 'ALLER'.obs; // ALLER | RETOUR
  RxString bookingStep = 'ALLER'.obs;
  final TextEditingController couponTextCtrl = TextEditingController();
  // ─────────────────────────────
  // FILTERS
  // ─────────────────────────────
  RxString selectedNetwork = 'ALL'.obs;
  RxString from = ''.obs;
  RxString to = ''.obs;
  Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  RxString searchQuery = ''.obs;
  RxString fromId = ''.obs;
  RxString toId = ''.obs;
  RxString selectedDate = ''.obs;
  RxInt babies = 0.obs;

  // ─────────────────────────────
  // INIT
  // ─────────────────────────────
  @override
  void onInit() {
    super.onInit();
    selectedNetwork.value = 'ALL';
    loadData();
  }

  static const List<String> frenchDayLabels = [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];

  String getDayLabel(DateTime date) {
    return frenchDayLabels[date.weekday - 1];
  }

  // ─────────────────────────────
  // TRAIN STATUS
  // ─────────────────────────────
  bool isTrainDeparted(String departureTime) {
    try {
      final now = TimeOfDay.now();
      final parts = departureTime.split(':');
      final depHour = int.parse(parts[0]);
      final depMin = int.parse(parts[1]);
      final depTotal = depHour * 60 + depMin;
      final nowTotal = now.hour * 60 + now.minute;
      return nowTotal >= depTotal;
    } catch (_) {
      return false;
    }
  }

  String getTrainStatus(TrainJourney journey, Train? train) {
    final departed = isTrainDeparted(journey.departureTime);

    if (!departed) return 'Pas encore parti';

    final delay = train?.delayText ?? 'OK';

    if (delay != 'OK' && delay != '—') return 'Retard $delay';

    return 'À l\'heure';
  }

  Color getTrainStatusColor(String status) {
    if (status.contains('Retard')) return AppColors.red;
    if (status == 'Pas encore parti') return AppColors.sand;
    return AppColors.green;
  }

  Color getTrainStatusBg(String status) {
    if (status.contains('Retard')) return AppColors.redBg;
    if (status == 'Pas encore parti') return AppColors.sandBg;
    return AppColors.greenBg;
  }

  // ─────────────────────────────
  // DAYS
  // ─────────────────────────────
  List<DateTime> get daysList =>
      List.generate(5, (i) => DateTime.now().add(Duration(days: i - 2)));

  void updateSelectedDay(int index) {
    selectedDayIndex.value = index;
  }

  // ─────────────────────────────
  // DURATION HELPERS
  // ─────────────────────────────
  int _toMin(String t) {
    try {
      final p = t.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    } catch (_) {
      return 0;
    }
  }

  String calcDuration(String dep, String arr) {
    var diff = _toMin(arr) - _toMin(dep);
    if (diff < 0) diff += 1440;
    if (diff == 0) return '';
    final h = diff ~/ 60;
    final m = diff % 60;
    return h == 0
        ? '${m}min'
        : (m == 0 ? '${h}h' : '${h}h ${m.toString().padLeft(2, '0')}');
  }

  bool isNextDay(String dep, String arr) => _toMin(arr) < _toMin(dep);

  // ─────────────────────────────
  // LOAD DATA FROM FIRESTORE
  // ─────────────────────────────
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      lines.value = await _firestore.getTrainLines();

      debugPrint("════════ TRAIN LINES ════════");
      for (final line in lines) {
        debugPrint(
          "LINE: ${line.name} | ID: ${line.id} | Stations: ${line.stations.length}",
        );
      }

      stations.value = await _firestore.getAllStations();

      debugPrint("════════ STATIONS ════════");
      for (var i = 0; i < stations.length; i++) {
        debugPrint(
          "Station [${i + 1}] ${stations[i].name} (Order: ${stations[i].stopOrder})",
        );
      }
      debugPrint("TOTAL STATIONS: ${stations.length}");

      trains.value = await _firestore.getTrains();
      final trainTimes = await _firestore.getTrainTimes();

      debugPrint("════════ TRAINS ════════");
      for (final t in trains) {
        debugPrint(
          "TRAIN: ${t.trainNumber} | LINE: ${t.lineId} | ${t.startStation} → ${t.endStation}",
        );
      }

      final uniqueTrains = trainTimes.map((e) => e.trainId).toSet();
      debugPrint("TOTAL UNIQUE TRAINS: ${uniqueTrains.length}");

      // ─────────────────────────────
      // DEFAULT FROM / TO (by name)
      // ─────────────────────────────
      if (stations.isNotEmpty) {
        from.value = stations.first.name;
        fromId.value = stations.first.id;

        if (stations.length >= 2) {
          to.value = stations[1].name;
          toId.value = stations[1].id;
        }
      }
    } catch (e) {
      debugPrint("🚨 LOAD DATA ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────
  // LINES
  // ─────────────────────────────
  List<TrainLine> get linesWithAll => lines;

  List<Station> get filteredStations {
    if (selectedNetwork.value == 'ALL') return stations;
    final line = lines.firstWhereOrNull((l) => l.id == selectedNetwork.value);
    if (line == null) return stations;
    return stations.where((s) => line.stations.contains(s.name)).toList();
  }

  bool get canGoToPanel {
    if (!hasReturn.value) {
      return selectedAller.value != null;
    }

    return selectedAller.value != null && selectedRetour.value != null;
  }

  void changeNetwork(String lineId) {
    selectedNetwork.value = lineId;
    final filtered = filteredStations;
    if (filtered.isNotEmpty) {
      from.value = filtered.first.name;
      fromId.value = filtered.first.id;
      to.value = filtered.length > 1 ? filtered.last.name : '';
      toId.value = filtered.length > 1 ? filtered.last.id : '';
    }
  }

  // ─────────────────────────────
  // SELECT STATION
  // ─────────────────────────────
  void selectStation(bool isFrom, String stationName) {
    final station = stations.firstWhereOrNull((s) => s.name == stationName);

    if (isFrom) {
      from.value = stationName;
      fromId.value = station?.id ?? '';
    } else {
      to.value = stationName;
      toId.value = station?.id ?? '';
    }
  }

  String getStopsText(TrainJourney t) {
    final stops = t.toStopOrder - t.fromStopOrder - 1;
    if (stops <= 0) return "Direct";
    if (stops == 1) return "1 arrêt";
    return "$stops arrêts";
  }

  // ─────────────────────────────
  // SWAP
  // ─────────────────────────────
  void swapStations() {
    final tempName = from.value;
    final tempId = fromId.value;

    from.value = to.value;
    fromId.value = toId.value;

    to.value = tempName;
    toId.value = tempId;
  }

  void selectRetour(TrainJourney journey, Train? train) {
    selectedRetour.value = journey;
    Get.toNamed('/panel');
  }

  void selectAller(TrainJourney journey, Train? train) {
    selectedAller.value = journey;
    selectedTrain.value = train;

    if (hasReturn.value) {
      // 🔁 STEP 1 → go RETOUR mode
      bookingStep.value = 'RETOUR';
      searchMode.value = 'RETOUR';

      // swap stations
      final tempFrom = from.value;
      final tempFromId = fromId.value;

      from.value = to.value;
      fromId.value = toId.value;

      to.value = tempFrom;
      toId.value = tempFromId;

      // 👉 use return date
      departureDateTime.value = returnDateTime.value;

      // 👉 set selectedTime for the return search
      if (returnDateTime.value != null) {
        selectedTime.value = TimeOfDay(
          hour: returnDateTime.value!.hour,
          minute: returnDateTime.value!.minute,
        );
      }

      // 🔄 reload results
      search();
    } else {
      // 🚀 ONE WAY → go panel
      Get.toNamed('/panel');
    }
  }

  // ─────────────────────────────
  // SEARCH TRAINS
  // ─────────────────────────────
  Future<void> search() async {
    try {
      searchLoading.value = true;

      final date = searchMode.value == 'ALLER'
          ? departureDateTime.value
          : returnDateTime.value;

      // Guard: if date or time is null, can't search
      if (date == null || selectedTime.value == null) {
        debugPrint(
          "⚠️ SEARCH: date=$date | selectedTime=${selectedTime.value}",
        );
        nextTrains.clear();
        return;
      }

      debugPrint(
        "🔍 SEARCH [${searchMode.value}]: ${from.value} → ${to.value} | date=$date | time=${selectedTime.value}",
      );

      final result = await _firestore.searchTrains(
        fromStationId: fromId.value,
        toStationId: toId.value,
        fromStationName: from.value,
        toStationName: to.value,
        selectedTime: selectedTime.value!,
        selectedDate: date,
      );

      debugPrint("🚆 FOUND: ${result.length} trains");
      nextTrains.assignAll(result);
    } catch (e) {
      debugPrint("🚨 SEARCH ERROR: $e");
      nextTrains.clear();
    } finally {
      searchLoading.value = false;
    }
  }

  DateTime get activeDate => bookingStep.value == 'RETOUR'
      ? (returnDateTime.value ?? DateTime.now())
      : (departureDateTime.value ?? DateTime.now());
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

  // ─────────────────────────────
  // VIEW HELPERS (moved from page)
  // ─────────────────────────────

  /// Format date + time for display.
  String fmtDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return 'Sélectionner';
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    final d =
        '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
    final t = time != null
        ? ' · ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : '';
    return '$d$t';
  }

  /// Human-readable passengers label.
  String get passengersLabel {
    final parts = <String>[];
    if (adults.value > 0) {
      parts.add('${adults.value} Adulte${adults.value > 1 ? 's' : ''}');
    }
    if (babies.value > 0) {
      parts.add('${babies.value} Bébé${babies.value > 1 ? 's' : ''}');
    }
    return parts.isEmpty ? '1 Adulte' : parts.join(' · ');
  }

  /// Clear return trip.
  void clearReturn() {
    hasReturn.value = false;
    returnDate.value = null;
    returnTime.value = null;
    returnDateTime.value = null;
  }

  /// Reset coupon state.
  void cancelCoupon() {
    showCouponField.value = false;
    couponCode.value = '';
    couponTextCtrl.clear();
  }

  /// Search button logic (validate → search → navigate).
  Future<void> performSearch() async {
    searchLoading.value = true;

    try {
      // Date check
      if (departureDateTime.value == null) {
        Get.snackbar(
          "Erreur",
          "Sélectionnez la date et l'heure",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 14,
        );
        return;
      }

      // Time set
      final ad = activeDate;
      selectedTime.value = TimeOfDay(hour: ad.hour, minute: ad.minute);

      // Station check
      if (from.value.isEmpty || to.value.isEmpty) {
        Get.snackbar(
          "Erreur",
          "Choisissez les stations",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
        return;
      }

      // Search
      await search();

      // Navigate
      if (nextTrains.isNotEmpty) {
        Get.to(
          () => SearchResultPage(),
          arguments: {
            "from": from.value,
            "to": to.value,
            "date": departureDateTime.value,
            "adults": adults.value,
            "children": children.value,
            "babies": babies.value,
            "coupon": couponCode.value,
          },
        );
      } else {
        Get.snackbar(
          "Aucun train",
          "Aucun trajet disponible",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 14,
        );
      }
    } finally {
      searchLoading.value = false;
    }
  }
}
