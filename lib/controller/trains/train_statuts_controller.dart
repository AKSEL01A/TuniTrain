import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/models/trains/train.dart';
import 'package:tuni_train/models/trains/train_line.dart';
import 'package:tuni_train/models/trains/traintime.dart';

// Stop state enum
enum StopState { notDeparted, current, passed }

// Enriched stop for UI
class StopInfo {
  final TrainTime trainTime;
  final StopState state;

  const StopInfo({required this.trainTime, required this.state});
}

class TrainStatusController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // ── Search ────────────────────────────────────────────────────────────────
  final TextEditingController searchCtrl = TextEditingController();
  final isSearching = false.obs;
  final hasSearched = false.obs;
  final notFound = false.obs;

  // ── Result ────────────────────────────────────────────────────────────────
  final foundTrain = Rxn<Train>();
  final foundLine = Rxn<TrainLine>();

  // ── Stops (from TrainTimes) ───────────────────────────────────────────────
  final stops = <TrainTime>[].obs;
  final isLoadingStops = false.obs;

  // ── Live ──────────────────────────────────────────────────────────────────
  StreamSubscription<DocumentSnapshot>? _liveSub;
  final lastUpdated = Rxn<DateTime>();

  // ── Cache ─────────────────────────────────────────────────────────────────
  final _allLines = <TrainLine>[];

  @override
  void onInit() {
    super.onInit();
    _loadLines();
  }

  @override
  void onClose() {
    _liveSub?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadLines() async {
    try {
      final snap = await _db.collection('TrainLines').get();
      _allLines.addAll(snap.docs.map(TrainLine.fromFirestore));
    } catch (_) {}
  }

  // ── SEARCH ────────────────────────────────────────────────────────────────
  Future<void> searchTrain() async {
    final raw = searchCtrl.text.trim();
    if (raw.isEmpty) return;

    // Accept N505, n505, 505 → normalize to numeric string "505"
    final numericId = raw.toUpperCase().startsWith('N')
        ? raw.substring(1).trim()
        : raw.trim();

    isSearching.value = true;
    hasSearched.value = false;
    notFound.value = false;
    foundTrain.value = null;
    foundLine.value = null;
    stops.clear();
    await _liveSub?.cancel();
    _liveSub = null;

    try {
      // Try numeric string first
      QuerySnapshot snap = await _db
          .collection('Trains')
          .where('trainNumber', isEqualTo: numericId)
          .limit(1)
          .get();

      // Fallback: N-prefix format
      if (snap.docs.isEmpty) {
        snap = await _db
            .collection('Trains')
            .where('trainNumber', isEqualTo: 'N$numericId')
            .limit(1)
            .get();
      }

      if (snap.docs.isEmpty) {
        notFound.value = true;
        hasSearched.value = true;
        return;
      }

      final doc = snap.docs.first;
      final train = Train.fromFirestore(doc);
      foundTrain.value = train;
      lastUpdated.value = train.updatedAt.toDate();

      foundLine.value = _allLines.firstWhereOrNull((l) => l.id == train.lineId);

      hasSearched.value = true;

      // Load stops from TrainTimes
      await _loadStops(numericId, train.lineId);

      // Live subscription
      _liveSub = _db.collection('Trains').doc(doc.id).snapshots().listen((s) {
        if (!s.exists) return;
        foundTrain.value = Train.fromFirestore(s);
        lastUpdated.value = foundTrain.value!.updatedAt.toDate();
      });
    } catch (e) {
      debugPrint('🚨 search error: $e');
      notFound.value = true;
      hasSearched.value = true;
    } finally {
      isSearching.value = false;
    }
  }

  // ── LOAD STOPS ────────────────────────────────────────────────────────────
  Future<void> _loadStops(String numericId, String lineId) async {
    isLoadingStops.value = true;
    try {
      final trainIdInt = int.tryParse(numericId) ?? 0;

      final snap = await _db
          .collection('TrainTimes')
          .where('trainId', isEqualTo: trainIdInt)
          .orderBy('stopOrder')
          .get();

      if (snap.docs.isNotEmpty) {
        stops.assignAll(snap.docs.map(TrainTime.fromFirestore));
        return;
      }

      // Fallback: build from TrainLine.stations
      final line = foundLine.value;
      final train = foundTrain.value;
      if (line != null && train != null && line.stations.isNotEmpty) {
        stops.assignAll(
          line.stations.asMap().entries.map(
            (e) => TrainTime(
              id: 'fake_${e.key}',
              trainId: trainIdInt,
              lineId: lineId,
              stationName: e.value,
              stationId: '',
              stopOrder: e.key,
              departureTime: e.key == 0 ? train.firstDeparture : null,
              arrivalTime: e.key == line.stations.length - 1
                  ? train.lastDeparture
                  : null,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('🚨 stops error: $e');
    } finally {
      isLoadingStops.value = false;
    }
  }

  void clearSearch() {
    _liveSub?.cancel();
    _liveSub = null;
    searchCtrl.clear();
    foundTrain.value = null;
    foundLine.value = null;
    notFound.value = false;
    hasSearched.value = false;
    lastUpdated.value = null;
    stops.clear();
  }

  // ── COMPUTED ──────────────────────────────────────────────────────────────

  /// Build enriched stop list with state
  List<StopInfo> get enrichedStops {
    final train = foundTrain.value;
    if (train == null) return [];

    return stops.map((stop) {
      StopState state;
      if (!train.isActive) {
        // Not departed yet
        state = StopState.notDeparted;
      } else if (stop.stopOrder < train.currentStopOrder) {
        state = StopState.passed;
      } else if (stop.stopOrder == train.currentStopOrder) {
        state = StopState.current;
      } else {
        state = StopState.notDeparted;
      }
      return StopInfo(trainTime: stop, state: state);
    }).toList();
  }

  double get routeProgress {
    final train = foundTrain.value;
    if (train == null || stops.isEmpty) return 0;
    return (train.currentStopOrder / (stops.length - 1)).clamp(0.0, 1.0);
  }

  String get displayTrainNumber {
    final n = foundTrain.value?.trainNumber ?? '';
    return n.toUpperCase().startsWith('N') ? n.toUpperCase() : 'N$n';
  }

  String get statusLabel {
    final t = foundTrain.value;
    if (t == null) return '';
    if (!t.isActive) return 'Pas encore parti';
    if (t.isDelayed) return 'Retard ${t.delayMinutes} min';
    return 'À l\'heure';
  }

  String get lastUpdatedLabel {
    final d = lastUpdated.value;
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'Mis à jour il y a ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'Mis à jour il y a ${diff.inMinutes} min';
    return 'Mis à jour il y a ${diff.inHours}h';
  }

  Color get lineColor {
    final line = foundLine.value;
    if (line == null) return const Color(0xFF1B4F8A);
    try {
      return Color(int.parse('FF${line.color.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFF1B4F8A);
    }
  }
}
