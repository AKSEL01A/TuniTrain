import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/models/station.dart';
import 'package:tuni_train/models/tickets.dart';
import 'package:tuni_train/models/train_line.dart';
import 'package:tuni_train/models/traintime.dart';

// ── Data class pairing a Station with its scheduled times ────────────────────
class StationWithTime {
  final Station station;
  final String? scheduledDeparture;
  final String? scheduledArrival;

  const StationWithTime({
    required this.station,
    this.scheduledDeparture,
    this.scheduledArrival,
  });

  String get displayTime => scheduledDeparture ?? scheduledArrival ?? '';
}

class JourneyRouteController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _linesCollection = 'trainLines';
  static const String _stationsCollection = 'stations';
  static const String _timesCollection = 'trainTimes';

  final RxBool isLoading = true.obs;
  final Rx<String?> error = Rx<String?>(null);
  final Rx<TrainLine?> line = Rx<TrainLine?>(null);
  final RxList<StationWithTime> routeStops = <StationWithTime>[].obs;

  final MyTicket ticket;
  JourneyRouteController({required this.ticket});

  @override
  void onInit() {
    super.onInit();
    load();
  }

  int get totalStops => routeStops.length;
  int get intermediates => (totalStops - 2).clamp(0, 9999);

  // ═══════════════════════════════════════════════════════════════════════════
  //  LOAD
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> load() async {
    isLoading.value = true;
    error.value = null;

    try {
      final lineId = ticket.trainLine.trim();
      final trainNumInt = int.tryParse(ticket.trainNumber) ?? -1;
      debugPrint('🔍 lineId="$lineId"  trainNumber=$trainNumInt');

      // ── 1. Load all stations (4-strategy fallback) ────────────────────────
      final allSnap = await _db.collection(_stationsCollection).get();
      List<Station> allStations = [];

      // Strategy 1: lineIds arrayContains
      final s1 = await _db
          .collection(_stationsCollection)
          .where('lineIds', arrayContains: lineId)
          .get();
      if (s1.docs.isNotEmpty) {
        allStations = s1.docs.map((d) => Station.fromFirestore(d)).toList();
        debugPrint('✅ Strategy 1: ${allStations.length} stations');
      }

      // Strategy 2: lineId == field
      if (allStations.isEmpty) {
        final s2 = await _db
            .collection(_stationsCollection)
            .where('lineId', isEqualTo: lineId)
            .get();
        if (s2.docs.isNotEmpty) {
          allStations = s2.docs.map((d) => Station.fromFirestore(d)).toList();
          debugPrint('✅ Strategy 2: ${allStations.length} stations');
        }
      }

      // Strategy 3: manual scan
      if (allStations.isEmpty) {
        final lower = lineId.toLowerCase();
        allStations = allSnap.docs.map((d) => Station.fromFirestore(d)).where((
          s,
        ) {
          if (s.lineIds.any((id) => id.toLowerCase() == lower)) return true;
          final raw = allSnap.docs.firstWhere((d) => d.id == s.id).data();
          for (final val in raw.values) {
            if (val is String && val.toLowerCase() == lower) return true;
            if (val is List) {
              for (final v in val) {
                if (v is String && v.toLowerCase() == lower) return true;
              }
            }
          }
          return false;
        }).toList();
        debugPrint('✅ Strategy 3 scan: ${allStations.length} stations');
      }

      // Last resort: all stations
      if (allStations.isEmpty) {
        allStations = allSnap.docs
            .map((d) => Station.fromFirestore(d))
            .toList();
        debugPrint('⚠️ Fallback: all ${allStations.length} stations');
      }

      allStations.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

      // ── 2. Load trainTimes for this train ─────────────────────────────────
      debugPrint(
        '🔍 Loading trainTimes for lineId="$lineId" trainId=$trainNumInt',
      );

      final timesSnap = await _db
          .collection(_timesCollection)
          .where('lineId', isEqualTo: lineId)
          .get();

      List<TrainTime> trainTimes = timesSnap.docs
          .map((d) => TrainTime.fromFirestore(d))
          .where((t) => t.trainId == trainNumInt)
          .toList();

      // Fallback: all times on line if trainId not matched
      if (trainTimes.isEmpty) {
        debugPrint('⚠️ No times for trainId=$trainNumInt — using all on line');
        trainTimes = timesSnap.docs
            .map((d) => TrainTime.fromFirestore(d))
            .toList();
      }

      trainTimes.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

      debugPrint('📋 TrainTimes loaded: ${trainTimes.length}');
      for (final t in trainTimes) {
        debugPrint(
          '  stopOrder=${t.stopOrder} stationId="${t.stationId}" '
          'name="${t.stationName}" dep="${t.departureTime}" arr="${t.arrivalTime}"',
        );
      }

      // ── 3. Build a time map: stopOrder → TrainTime ────────────────────────
      // Also build by stationId and stationName for fallback matching
      final Map<int, TrainTime> timeByOrder = {};
      final Map<String, TrainTime> timeById = {};
      final Map<String, TrainTime> timeByName = {};

      for (final t in trainTimes) {
        timeByOrder[t.stopOrder] = t;
        if (t.stationId.isNotEmpty) {
          timeById[t.stationId.trim().toUpperCase()] = t;
        }
        if (t.stationName.isNotEmpty) {
          timeByName[t.stationName.trim().toUpperCase()] = t;
        }
      }

      // ── 4. Pair each Station with its TrainTime ───────────────────────────
      final List<StationWithTime> paired = allStations.map((station) {
        // Match by stopOrder first (most reliable)
        TrainTime? tt = timeByOrder[station.stopOrder];

        // Match by stationId
        tt ??= timeById[station.id.trim().toUpperCase()];

        // Match by stationName
        tt ??= timeByName[station.name.trim().toUpperCase()];

        // Partial name match fallback
        if (tt == null) {
          final upper = station.name.trim().toUpperCase();
          for (final entry in timeByName.entries) {
            if (entry.key.contains(upper) || upper.contains(entry.key)) {
              tt = entry.value;
              break;
            }
          }
        }

        return StationWithTime(
          station: station,
          scheduledDeparture: tt?.departureTime,
          scheduledArrival: tt?.arrivalTime,
        );
      }).toList();

      debugPrint('📍 Paired stations (${paired.length}):');
      for (final p in paired) {
        debugPrint(
          '  "${p.station.name}"[${p.station.stopOrder}] '
          'dep="${p.scheduledDeparture}" arr="${p.scheduledArrival}"',
        );
      }

      // ── 5. Slice from → to ────────────────────────────────────────────────
      final fromUpper = ticket.fromStation.trim().toUpperCase();
      final toUpper = ticket.toStation.trim().toUpperCase();

      int fromIdx = _findIdx(paired, fromUpper);
      int toIdx = _findIdx(paired, toUpper);

      debugPrint(
        '📌 fromIdx=$fromIdx ("$fromUpper") | toIdx=$toIdx ("$toUpper")',
      );

      if (fromIdx == -1 || toIdx == -1) {
        debugPrint('⚠️ Could not slice — showing full list');
        routeStops.value = paired;
      } else {
        if (fromIdx > toIdx) {
          final tmp = fromIdx;
          fromIdx = toIdx;
          toIdx = tmp;
        }
        routeStops.value = paired.sublist(fromIdx, toIdx + 1);
      }

      debugPrint(
        '✅ Route (${routeStops.length} stops): '
        '${routeStops.map((s) => '${s.station.name}[${s.station.stopOrder}]').join(' → ')}',
      );

      // ── 6. Load line metadata ─────────────────────────────────────────────
      await _loadLineMeta(lineId);
    } catch (e, stack) {
      debugPrint('🚨 JourneyRouteController error: $e\n$stack');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Find index by name in paired list ─────────────────────────────────────
  int _findIdx(List<StationWithTime> stops, String nameUpper) {
    int i = stops.indexWhere(
      (s) => s.station.name.trim().toUpperCase() == nameUpper,
    );
    if (i != -1) return i;
    i = stops.indexWhere((s) {
      final n = s.station.name.trim().toUpperCase();
      return n.contains(nameUpper) || nameUpper.contains(n);
    });
    return i;
  }

  // ── Load TrainLine metadata ────────────────────────────────────────────────
  Future<void> _loadLineMeta(String lineId) async {
    try {
      final snap = await _db.collection(_linesCollection).get();
      final lower = lineId.toLowerCase();
      for (final doc in snap.docs) {
        final d = doc.data();
        final docId = doc.id.toLowerCase();
        final code = (d['code'] ?? '').toString().toLowerCase();
        final name = (d['name'] ?? '').toString().toLowerCase();
        if (docId == lower ||
            code == lower ||
            name == lower ||
            docId.contains(lower) ||
            lower.contains(docId)) {
          line.value = TrainLine.fromFirestore(doc);
          debugPrint('✅ Line meta: "${line.value!.name}"');
          return;
        }
      }
    } catch (e) {
      debugPrint('ℹ️ Line meta not loaded: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color lineColor() {
    try {
      final hex = line.value?.color.replaceAll('#', '') ?? '1565C0';
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.blue1;
    }
  }

  bool isDeparture(StationWithTime s) =>
      s.station.name.trim().toUpperCase() ==
      ticket.fromStation.trim().toUpperCase();

  bool isArrival(StationWithTime s) =>
      s.station.name.trim().toUpperCase() ==
      ticket.toStation.trim().toUpperCase();
}
