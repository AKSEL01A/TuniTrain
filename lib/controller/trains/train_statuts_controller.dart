import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/models/trains/train.dart';
import 'package:tuni_train/models/trains/train_line.dart';
import 'package:tuni_train/models/trains/traintime.dart';

enum StopState { notDeparted, current, passed }

class StopInfo {
  final TrainTime trainTime;
  final StopState state;

  const StopInfo({required this.trainTime, required this.state});
}

class TrainStatusController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // ── SEARCH ─────────────────────────────
  final TextEditingController searchCtrl = TextEditingController();
  final isSearching = false.obs;
  final hasSearched = false.obs;
  final notFound = false.obs;

  // ── LINE FILTER ─────────────────────────
  final selectedLineId = RxnString();

  // Observable list so the UI reacts when lines load
  final _allLines = <TrainLine>[].obs;
  List<TrainLine> get lines => _allLines;

  // ── DATA ───────────────────────────────
  final foundTrain = Rxn<Train>();
  final foundLine = Rxn<TrainLine>();

  final stops = <TrainTime>[].obs;
  final isLoadingStops = false.obs;

  // ── LIVE ────────────────────────────────
  StreamSubscription<DocumentSnapshot>? _liveSub;
  final lastUpdated = Rxn<DateTime>();

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

  // ─────────────────────────────
  // SELECT LINE
  // ─────────────────────────────
  void selectLine(String lineId) {
    if (selectedLineId.value == lineId) {
      selectedLineId.value = null;
    } else {
      selectedLineId.value = lineId;
    }
    // ✅ نمسح فقط النتيجة، مش الـ text field
    _clearResult();
  }

  void _clearResult() {
    _liveSub?.cancel();
    _liveSub = null;

    foundTrain.value = null;
    foundLine.value = null;
    stops.clear();

    hasSearched.value = false;
    notFound.value = false;
    lastUpdated.value = null;
  }

  // clearSearch الكاملة تمسح كل شي بما فيها الـ text
  void clearSearch() {
    searchCtrl.clear();
    _clearResult();
  }

  // ─────────────────────────────
  // LOAD LINES
  // ─────────────────────────────
  Future<void> _loadLines() async {
    try {
      final snap = await _db.collection('TrainLines').get();
      _allLines.assignAll(snap.docs.map(TrainLine.fromFirestore));
    } catch (e) {
      debugPrint('lines load error: $e');
    }
  }

  // ─────────────────────────────
  // SEARCH TRAIN
  // ─────────────────────────────
  Future<void> searchTrain() async {
    final raw = searchCtrl.text.trim().toUpperCase();

    if (selectedLineId.value == null) {
      Get.snackbar(
        'Ligne manquante',
        'Sélectionne une ligne d\'abord',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (raw.isEmpty) {
      Get.snackbar(
        'Numéro manquant',
        'Tape le numéro du train',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isSearching.value = true;
    hasSearched.value = false;
    notFound.value = false;

    foundTrain.value = null;
    foundLine.value = null;
    stops.clear();

    await _liveSub?.cancel();
    _liveSub = null;

    try {
      final snap = await _db
          .collection('Trains')
          .where('lineId', isEqualTo: selectedLineId.value)
          .where('trainNumber', isEqualTo: raw)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        notFound.value = true;
        hasSearched.value = true;
        return;
      }

      final doc = snap.docs.first;
      final train = Train.fromFirestore(doc);

      foundTrain.value = train;
      foundLine.value = _allLines.firstWhereOrNull((l) => l.id == train.lineId);

      lastUpdated.value = train.updatedAt.toDate();
      hasSearched.value = true;

      await _loadStops(train);

      _liveSub = _db.collection('Trains').doc(doc.id).snapshots().listen((s) {
        if (!s.exists) return;
        final updated = Train.fromFirestore(s);
        foundTrain.value = updated;
        lastUpdated.value = updated.updatedAt.toDate();
      });
    } catch (e) {
      debugPrint('search error: $e');
      notFound.value = true;
      hasSearched.value = true;
    } finally {
      isSearching.value = false;
    }
  }

  // ─────────────────────────────
  // LOAD STOPS
  // ─────────────────────────────
  Future<void> _loadStops(Train train) async {
    isLoadingStops.value = true;

    try {
      final snap = await _db
          .collection('TrainTimes')
          .where('trainId', isEqualTo: train.trainNumber)
          .orderBy('stopOrder')
          .get();

      if (snap.docs.isNotEmpty) {
        stops.assignAll(snap.docs.map(TrainTime.fromFirestore));
      } else {
        // Fallback: build from line stations
        final line = foundLine.value;
        if (line != null && line.stations.isNotEmpty) {
          stops.assignAll(
            line.stations.asMap().entries.map(
              (e) => TrainTime(
                id: 'fake_${e.key}',
                trainId: 0,
                lineId: train.lineId,
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
      }
    } catch (e) {
      debugPrint('stops error: $e');
    } finally {
      isLoadingStops.value = false;
    }
  }

  // ─────────────────────────────
  // ENRICHED STOPS
  // ─────────────────────────────
  List<StopInfo> get enrichedStops {
    final train = foundTrain.value;
    if (train == null || stops.isEmpty) return [];

    return stops.map((stop) {
      if (!train.isActive) {
        return StopInfo(trainTime: stop, state: StopState.notDeparted);
      }

      if (stop.stopOrder < train.currentStopOrder) {
        return StopInfo(trainTime: stop, state: StopState.passed);
      }

      if (stop.stopOrder == train.currentStopOrder) {
        return StopInfo(trainTime: stop, state: StopState.current);
      }

      return StopInfo(trainTime: stop, state: StopState.notDeparted);
    }).toList();
  }

  // ─────────────────────────────
  // ROUTE PROGRESS
  // ─────────────────────────────
  double get routeProgress {
    final train = foundTrain.value;
    if (train == null || stops.length <= 1) return 0;

    return (train.currentStopOrder / (stops.length - 1)).clamp(0.0, 1.0);
  }

  // ─────────────────────────────
  // UI HELPERS
  // ─────────────────────────────
  String get displayTrainNumber {
    final n = foundTrain.value?.trainNumber ?? '';
    return n.startsWith('N') ? n : 'N$n';
  }

  String get statusLabel {
    final t = foundTrain.value;
    if (t == null) return '';
    if (!t.isActive) return "Pas encore parti";
    if (t.isDelayed) return "Retard ${t.delayMinutes} min";
    return "À l'heure";
  }

  String get lastUpdatedLabel {
    final d = lastUpdated.value;
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return "Mis à jour il y a ${diff.inSeconds}s";
    if (diff.inMinutes < 60) return "Mis à jour il y a ${diff.inMinutes} min";
    return "Mis à jour il y a ${diff.inHours}h";
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
