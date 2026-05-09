import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuni_train/models/train_journey.dart';

import '../models/station.dart';
import '../models/train.dart';
import '../models/train_line.dart';
import '../models/traintime.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────
  // NORMALIZER 🔥 IMPORTANT
  // ─────────────────────────────
  String _norm(String s) {
    return s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ─────────────────────────────
  // FETCH DATA
  // ─────────────────────────────
  Future<List<TrainLine>> getTrainLines() async {
    final snap = await _db.collection('trainLines').get();
    return snap.docs.map((d) => TrainLine.fromFirestore(d)).toList();
  }

  Future<List<Station>> getAllStations() async {
    final snap = await _db.collection('stations').get();
    return snap.docs.map((d) => Station.fromFirestore(d)).toList();
  }

  Future<List<Train>> getTrains() async {
    final snap = await _db.collection('trains').get();
    return snap.docs.map((d) => Train.fromFirestore(d)).toList();
  }

  // ─────────────────────────────
  // SEARCH TRAINS 🔥 FIXED CORE
  // ─────────────────────────────
  Future<List<TrainJourney>> searchTrains({
    required String fromStation,
    required String toStation,
    required TimeOfDay selectedTime,
  }) async {
    final stopsSnap = await _db.collection('trainTimes').get();
    final linesSnap = await _db.collection('trainLines').get();

    final allStops = stopsSnap.docs
        .map((d) => TrainTime.fromFirestore(d))
        .toList();

    final lines = linesSnap.docs
        .map((d) => TrainLine.fromFirestore(d))
        .toList();

    final Map<String, List<TrainTime>> grouped = {};

    for (final s in allStops) {
      grouped.putIfAbsent(s.trainId.toString(), () => []).add(s);
    }

    final List<TrainJourney> result = [];

    for (final entry in grouped.entries) {
      final stops = entry.value;

      final line = lines.firstWhere(
        (l) => l.id == stops.first.lineId,
        orElse: () => lines.first,
      );

      final fromIndex = line.stations.indexOf(fromStation);
      final toIndex = line.stations.indexOf(toStation);

      if (fromIndex == -1 || toIndex == -1) continue;
      if (fromIndex >= toIndex) continue;

      final fromStop = stops.firstWhere((s) => s.stationName == fromStation);

      final toStop = stops.firstWhere((s) => s.stationName == toStation);

      final dep = fromStop.departureTime;
      final arr = toStop.arrivalTime;

      if (dep == null || arr == null) continue;

      if (!_isAfterSelectedTime(dep, selectedTime)) continue;

      result.add(
        TrainJourney(
          trainId: fromStop.trainId,
          lineId: fromStop.lineId,

          fromStation: fromStation,
          toStation: toStation,

          departureTime: dep,
          arrivalTime: arr,

          fromStopOrder: fromStop.stopOrder,
          toStopOrder: toStop.stopOrder,
        ),
      );
    }

    return result;
  }

  // ─────────────────────────────
  // TIME CHECK
  // ─────────────────────────────
  bool _isAfterSelectedTime(String trainTime, TimeOfDay selectedTime) {
    final parts = trainTime.split(':');
    if (parts.length != 2) return false;

    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    if (h > selectedTime.hour) return true;

    if (h == selectedTime.hour && m >= selectedTime.minute) {
      return true;
    }

    return false;
  }
}
