import 'package:cloud_firestore/cloud_firestore.dart';

class Train {
  final String id;

  // BASIC
  final String trainNumber;
  final String lineId;

  // ROUTE
  final String startStation;
  final String endStation;
  final int totalStops;

  // STATUS
  final bool isActive;
  final bool isDelayed;
  final int delayMinutes;

  // LIVE
  final String currentStation;
  final int currentStopOrder;
  final double currentSpeed;

  // CAPACITY
  final int totalCapacity;
  final int occupiedSeats;

  // TIME
  final String firstDeparture;
  final String lastDeparture;

  // META
  final Timestamp updatedAt;

  const Train({
    required this.id,

    required this.trainNumber,
    required this.lineId,

    required this.startStation,
    required this.endStation,
    required this.totalStops,

    required this.isActive,
    required this.isDelayed,
    required this.delayMinutes,

    required this.currentStation,
    required this.currentStopOrder,
    required this.currentSpeed,

    required this.totalCapacity,
    required this.occupiedSeats,

    required this.firstDeparture,
    required this.lastDeparture,

    required this.updatedAt,
  });

  // ─────────────────────────────
  // FIRESTORE
  // ─────────────────────────────

  factory Train.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return Train(
      id: doc.id,

      trainNumber: map['trainNumber'] ?? '',
      lineId: map['lineId'] ?? '',

      startStation: map['startStation'] ?? '',
      endStation: map['endStation'] ?? '',

      totalStops: map['totalStops'] ?? 0,

      isActive: map['isActive'] ?? true,
      isDelayed: map['isDelayed'] ?? false,
      delayMinutes: map['delayMinutes'] ?? 0,

      currentStation: map['currentStation'] ?? '',
      currentStopOrder: map['currentStopOrder'] ?? 0,

      currentSpeed: (map['currentSpeed'] ?? 0).toDouble(),

      totalCapacity: map['totalCapacity'] ?? 0,
      occupiedSeats: map['occupiedSeats'] ?? 0,

      firstDeparture: map['firstDeparture'] ?? '',
      lastDeparture: map['lastDeparture'] ?? '',

      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  // ─────────────────────────────
  // TO MAP
  // ─────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'trainNumber': trainNumber,
      'lineId': lineId,

      'startStation': startStation,
      'endStation': endStation,

      'totalStops': totalStops,

      'isActive': isActive,
      'isDelayed': isDelayed,
      'delayMinutes': delayMinutes,

      'currentStation': currentStation,
      'currentStopOrder': currentStopOrder,

      'currentSpeed': currentSpeed,

      'totalCapacity': totalCapacity,
      'occupiedSeats': occupiedSeats,

      'firstDeparture': firstDeparture,
      'lastDeparture': lastDeparture,

      'updatedAt': updatedAt,
    };
  }

  // ─────────────────────────────
  // HELPERS
  // ─────────────────────────────

  bool get isFull => occupiedSeats >= totalCapacity;

  int get availableSeats => totalCapacity - occupiedSeats;

  double get occupancyRate {
    if (totalCapacity == 0) return 0;
    return occupiedSeats / totalCapacity;
  }

  String get delayText {
    if (!isDelayed) return 'À l\'heure';

    return 'Retard $delayMinutes min';
  }
}
