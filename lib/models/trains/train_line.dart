import 'package:cloud_firestore/cloud_firestore.dart';

class TrainLine {
  final String id;

  // BASIC
  final String name;
  final String code;
  final String color;

  // CATEGORY (NEW 🔥)
  final String category;

  // ROUTE
  final String startStation;
  final String endStation;

  final List<String> stations;

  // METADATA
  final int totalStations;
  final double totalDistanceKm;

  // OPERATION
  final bool isActive;

  final String firstDeparture;
  final String lastDeparture;

  final int averageWaitMinutes;

  // VISUAL
  final String mapImageUrl;

  // LIVE
  final int activeTrains;

  // SYSTEM
  final Timestamp updatedAt;

  const TrainLine({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    required this.category,
    required this.startStation,
    required this.endStation,
    required this.stations,
    required this.totalStations,
    required this.totalDistanceKm,
    required this.isActive,
    required this.firstDeparture,
    required this.lastDeparture,
    required this.averageWaitMinutes,
    required this.mapImageUrl,
    required this.activeTrains,
    required this.updatedAt,
  });

  factory TrainLine.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return TrainLine(
      id: doc.id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      color: map['color'] ?? '#000000',

      category: map['category'] ?? '',

      startStation: map['startStation'] ?? '',
      endStation: map['endStation'] ?? '',

      stations: List<String>.from(map['stations'] ?? []),

      totalStations: map['totalStations'] ?? 0,
      totalDistanceKm: (map['totalDistanceKm'] ?? 0).toDouble(),

      isActive: map['isActive'] ?? true,

      firstDeparture: map['firstDeparture'] ?? '',
      lastDeparture: map['lastDeparture'] ?? '',

      averageWaitMinutes: map['averageWaitMinutes'] ?? 0,

      mapImageUrl: map['mapImageUrl'] ?? '',

      activeTrains: map['activeTrains'] ?? 0,

      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'color': color,

      'category': category,

      'startStation': startStation,
      'endStation': endStation,

      'stations': stations,

      'totalStations': totalStations,
      'totalDistanceKm': totalDistanceKm,

      'isActive': isActive,

      'firstDeparture': firstDeparture,
      'lastDeparture': lastDeparture,

      'averageWaitMinutes': averageWaitMinutes,

      'mapImageUrl': mapImageUrl,

      'activeTrains': activeTrains,

      'updatedAt': updatedAt,
    };
  }

  // HELPERS
  bool containsStation(String station) {
    return stations.contains(station);
  }

  int stationIndex(String station) {
    return stations.indexOf(station);
  }

  bool isDirectionValid(String from, String to) {
    return stationIndex(from) < stationIndex(to);
  }
}
