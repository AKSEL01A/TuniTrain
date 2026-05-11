import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuni_train/models/station.dart';
import 'package:tuni_train/models/traintime.dart';
import '../models/train_journey.dart';
import '../models/train_line.dart';
import '../models/train.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────
  // NORMALIZE TEXT
  // ─────────────────────────────
  String norm(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  // ─────────────────────────────
  // FETCH DATA
  // ─────────────────────────────
  Future<List<TrainLine>> getTrainLines() async {
    final snap = await _db.collection('trainLines').get();
    return snap.docs.map((d) => TrainLine.fromFirestore(d)).toList();
  }

  Future<List<Train>> getTrains() async {
    final snap = await _db.collection('trains').get();
    return snap.docs.map((d) => Train.fromFirestore(d)).toList();
  }

  Future<List<TrainTime>> getTrainTimes() async {
    final snap = await _db.collection('trainTimes').get();
    return snap.docs.map((d) => TrainTime.fromFirestore(d)).toList();
  }

  Future<List<Station>> getAllStations() async {
    final snap = await _db.collection('stations').orderBy('stopOrder').get();
    return snap.docs.map((d) => Station.fromFirestore(d)).toList();
  }

  // ─────────────────────────────
  // TIME HELPERS
  // ─────────────────────────────
  int toMinutes(String t) {
    final parts = t.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  // ─────────────────────────────
  // 🔥 SMART STATION MATCHER
  // Tries 3 strategies in order:
  // 1. stationId exact match
  // 2. stationName exact match (uppercase)
  // 3. stationName contains match (handles "MOKNINE" matching "MOKNINE CENTRE")
  // ─────────────────────────────
  bool _stationMatches(TrainTime stop, String stationId, String stationName) {
    final stopId = stop.stationId.trim().toLowerCase();
    final stopName = stop.stationName.trim().toUpperCase();
    final searchId = stationId.trim().toLowerCase();
    final searchName = stationName.trim().toUpperCase();

    // Strategy 1: stationId exact match
    if (stopId.isNotEmpty && searchId.isNotEmpty && stopId == searchId) {
      return true;
    }

    // Strategy 2: stationName exact match
    if (stopName == searchName) {
      return true;
    }

    // Strategy 3: one name contains the other
    // handles: "MOKNINE" matches "MOKNINE CENTRE" and vice versa
    // handles: "MAHDIA" matches "MAHDIA CENTRE" and vice versa
    if (stopName.isNotEmpty && searchName.isNotEmpty) {
      if (stopName.contains(searchName) || searchName.contains(stopName)) {
        return true;
      }
    }

    return false;
  }

  // ─────────────────────────────
  // MAIN SEARCH
  // ─────────────────────────────
  Future<List<TrainJourney>> searchTrains({
    required String fromStationId,
    required String toStationId,
    required String fromStationName,
    required String toStationName,
    required TimeOfDay selectedTime,
    required DateTime selectedDate,
  }) async {
    try {
      final trainTimes = await getTrainTimes();

      // 🔥 DEBUG
      debugPrint("══ SAMPLE TRAIN TIME stationNames ══");
      for (final t in trainTimes.take(5)) {
        debugPrint(
          "  stationId='${t.stationId}' | stationName='${t.stationName}'",
        );
      }
      debugPrint("══ SEARCHING FOR ══");
      debugPrint(
        "  fromStationId='$fromStationId' | fromName='$fromStationName'",
      );
      debugPrint("  toStationId='$toStationId'     | toName='$toStationName'");

      // group by trainId
      final Map<int, List<TrainTime>> grouped = {};
      for (final t in trainTimes) {
        grouped.putIfAbsent(t.trainId, () => []).add(t);
      }

      final selectedMin = selectedTime.hour * 60 + selectedTime.minute;
      final now = DateTime.now();
      final isToday =
          selectedDate.year == now.year &&
          selectedDate.month == now.month &&
          selectedDate.day == now.day;

      final List<TrainJourney> result = [];
      final stations = await getAllStations(); // ✅ PLACE HERE (IMPORTANT)

      for (final entry in grouped.entries) {
        final stops = entry.value;
        stops.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

        TrainTime? fromStop;
        TrainTime? toStop;

        // 🔥 SMART MATCH: tries ID, exact name, then contains
        for (final s in stops) {
          if (_stationMatches(s, fromStationId, fromStationName)) {
            fromStop = s;
          }
          if (_stationMatches(s, toStationId, toStationName)) {
            toStop = s;
          }
        }

        if (fromStop == null || toStop == null) continue;
        if (fromStop.stopOrder >= toStop.stopOrder) continue;

        final dep = fromStop.departureTime;
        final arr = toStop.arrivalTime;

        if (dep == null || arr == null) continue;

        final depMin = toMinutes(dep);
        if (isToday && depMin < selectedMin) continue;

        result.add(
          TrainJourney(
            trainId: entry.key,
            lineId: fromStop.lineId,
            fromStation: fromStop.stationName,
            toStation: toStop.stationName,
            departureTime: dep,
            arrivalTime: arr,
            fromStopOrder: fromStop.stopOrder,
            toStopOrder: toStop.stopOrder,

            // ✅ FIX HERE
            ticketPrice: 0.800,
          ),
        );
      }

      result.sort(
        (a, b) =>
            toMinutes(a.departureTime).compareTo(toMinutes(b.departureTime)),
      );

      debugPrint("🚆 FOUND: ${result.length}");
      return result;
    } catch (e) {
      debugPrint("SEARCH ERROR: $e");
      return [];
    }
  }
}
