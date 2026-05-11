import 'package:cloud_firestore/cloud_firestore.dart';

class TrainTime {
  final String id;
  final int trainId;
  final String lineId;

  // 🔥 OLD (keep for display only)
  final String stationName;

  // 🔥 NEW (IMPORTANT)
  final String stationId;

  final int stopOrder;

  final String? departureTime;
  final String? arrivalTime;
  final String? dayType;

  const TrainTime({
    required this.id,
    required this.trainId,
    required this.lineId,

    required this.stationName,
    required this.stationId,

    required this.stopOrder,
    this.departureTime,
    this.arrivalTime,
    this.dayType,
  });

  // ─────────────────────────────
  // CLEANERS
  // ─────────────────────────────
  static String? clean(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    if (s.toUpperCase() == 'NULL') return null;
    return s;
  }

  static int cleanInt(dynamic v) {
    if (v == null) return 0;
    return int.tryParse(v.toString()) ?? 0;
  }

  // ─────────────────────────────
  // FIRESTORE
  // ─────────────────────────────
  factory TrainTime.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return TrainTime(
      id: doc.id,

      trainId: cleanInt(map['trainId']),
      lineId: map['lineId'] ?? '',

      stationName: map['stationName'] ?? '',

      // 🔥 NEW FIELD (IMPORTANT)
      stationId: map['stationId'] ?? '',

      stopOrder: cleanInt(map['stopOrder']),

      departureTime: clean(map['departureTime']),
      arrivalTime: clean(map['arrivalTime']),
      dayType: clean(map['dayType']),
    );
  }

  // ─────────────────────────────
  // WRITE TO FIRESTORE
  // ─────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'trainId': trainId,
      'lineId': lineId,

      'stationName': stationName,
      'stationId': stationId,

      'stopOrder': stopOrder,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'dayType': dayType,
    };
  }

  // ─────────────────────────────
  // HELPERS
  // ─────────────────────────────
  bool get hasTime => departureTime != null || arrivalTime != null;

  String get displayDeparture => departureTime ?? '--';
  String get displayArrival => arrivalTime ?? '--';
}
