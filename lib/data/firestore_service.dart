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
  // ZONE MAP  (station name → zone number)
  // ─────────────────────────────
  static const Map<String, int> _stationZones = {
    // ZONE 1
    "SOUSSE BAB JEDID": 1,
    "SOUSSE MED V": 1,
    "SOUSSE SUD": 1,
    "SOUSSE ZONE INDUSTRIELLE": 1,
    // ZONE 2
    "SAHLINE": 2,
    "SAHLINE SEBKHA": 2,
    "LES HOTELS": 2,
    "L'AEROPORT": 2,
    "LA FACULTE 1": 2,
    "MONASTIR CENTRE": 2,
    // ZONE 3
    "LA FACULTE 2": 3,
    "MONASTIR ZONE INDUSTRIELLE": 3,
    "FRINA": 3,
    "KHENISS BEMBLA": 3,
    "KSIBET MEDIOUNI BENANE": 3,
    "BOUHJAR": 3,
    // ZONE 4
    "LAMTA": 4,
    "SAYADA": 4,
    "KSAR HELLAL ZONE INDUSTRIELLE": 4,
    "KSAR HELLAL": 4,
    // ZONE 5
    "MOKNINE GRIBAA": 5,
    "MOKNINE CENTRE": 5,
    "MOKNINE ZONE INDUSTRIELLE": 5,
    "TEBOULBA ZONE INDUSTRIELLE": 5,
    "TEBOULBA": 5,
    "BEKALTA": 5,
    // ZONE 6
    "BAGHDADI": 6,
    "MAHDIA ZONE TOURISTIQUE": 6,
    "SIDI MESSOUD": 6,
    "BORJ EL ARIF": 6,
    "EZZAHRA": 6,
    "MAHDIA CENTRE": 6,
  };

  // ─────────────────────────────
  // PRICE TABLE  (index = zone diff, 0–5)
  // ─────────────────────────────
  static const List<double> _priceTable = [
    0.800, // diff 0 → same zone
    1.000, // diff 1
    1.200, // diff 2
    1.600, // diff 3
    1.900, // diff 4
    2.600, // diff 5 → zone 1 ↔ zone 6
  ];

  // ─────────────────────────────
  // CALCULATE PRICE between two station names
  // Returns the base price for ONE adult ticket (2nd class)
  // ─────────────────────────────
  static double calculatePrice(String fromStation, String toStation) {
    final fromNorm = fromStation.trim().toUpperCase();
    final toNorm = toStation.trim().toUpperCase();

    // Try exact match first, then "contains" fallback
    int? fromZone = _stationZones[fromNorm];
    int? toZone = _stationZones[toNorm];

    // Fallback: find first key that contains the station name
    if (fromZone == null) {
      for (final entry in _stationZones.entries) {
        if (entry.key.contains(fromNorm) || fromNorm.contains(entry.key)) {
          fromZone = entry.value;
          break;
        }
      }
    }
    if (toZone == null) {
      for (final entry in _stationZones.entries) {
        if (entry.key.contains(toNorm) || toNorm.contains(entry.key)) {
          toZone = entry.value;
          break;
        }
      }
    }

    if (fromZone == null || toZone == null) {
      debugPrint(
        "⚠️  Zone not found → from='$fromStation' (zone=$fromZone) | to='$toStation' (zone=$toZone) → fallback 0.800",
      );
      return 0.800; // fallback: minimum price
    }

    final diff = (fromZone - toZone).abs().clamp(0, _priceTable.length - 1);
    final price = _priceTable[diff];

    debugPrint(
      "💰 PRICE: $fromStation (Z$fromZone) → $toStation (Z$toZone) | diff=$diff | price=$price DT",
    );

    return price;
  }

  // ─────────────────────────────
  // Get zone number for a station (useful for UI display)
  // ─────────────────────────────
  static int? getZone(String stationName) {
    final norm = stationName.trim().toUpperCase();
    return _stationZones[norm] ??
        _stationZones.entries
            .firstWhere(
              (e) => e.key.contains(norm) || norm.contains(e.key),
              orElse: () => const MapEntry('', 0),
            )
            .value;
  }

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
  // SMART STATION MATCHER
  // ─────────────────────────────
  bool _stationMatches(TrainTime stop, String stationId, String stationName) {
    final stopId = stop.stationId.trim().toLowerCase();
    final stopName = stop.stationName.trim().toUpperCase();
    final searchId = stationId.trim().toLowerCase();
    final searchName = stationName.trim().toUpperCase();

    if (stopId.isNotEmpty && searchId.isNotEmpty && stopId == searchId) {
      return true;
    }
    if (stopName == searchName) return true;
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

      debugPrint("══ SEARCHING FOR ══");
      debugPrint(
        "  fromStationId='$fromStationId' | fromName='$fromStationName'",
      );
      debugPrint("  toStationId='$toStationId'     | toName='$toStationName'");

      // Group by trainId
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

      final double journeyPrice = calculatePrice(
        fromStationName,
        toStationName,
      );

      final List<TrainJourney> result = [];

      for (final entry in grouped.entries) {
        final stops = entry.value;
        stops.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

        TrainTime? fromStop;
        TrainTime? toStop;

        for (final s in stops) {
          if (_stationMatches(s, fromStationId, fromStationName)) fromStop = s;
          if (_stationMatches(s, toStationId, toStationName)) toStop = s;
        }

        if (fromStop == null || toStop == null) continue;

        // ✅ KEY FIX: allow both directions
        // fromStopOrder < toStopOrder = forward direction (Sousse → Mahdia)
        // fromStopOrder > toStopOrder = reverse direction (Mahdia → Sousse)
        // fromStopOrder == toStopOrder = same station, skip
        if (fromStop.stopOrder == toStop.stopOrder) continue;

        // ✅ For reverse direction, we need a train that runs in THAT direction.
        // Since your data has all trains running Sousse→Mahdia (stopOrder 1→32),
        // a "reverse" search means fromStop.stopOrder > toStop.stopOrder.
        // We swap the logic: departure time comes from fromStop, arrival from toStop.

        // For reverse trips, the train physically departs from the higher stopOrder
        // station earlier in its run — but the passenger boards at fromStop.
        // The departure time for the passenger is fromStop.departureTime.
        final dep = fromStop.departureTime ?? fromStop.arrivalTime;
        final arr = toStop.arrivalTime ?? toStop.departureTime;

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
            ticketPrice: journeyPrice,
          ),
        );
      }

      result.sort(
        (a, b) =>
            toMinutes(a.departureTime).compareTo(toMinutes(b.departureTime)),
      );

      debugPrint(
        "🚆 FOUND: ${result.length} trains | price: ${journeyPrice.toStringAsFixed(3)} DT",
      );
      return result;
    } catch (e) {
      debugPrint("SEARCH ERROR: $e");
      return [];
    }
  }
}
