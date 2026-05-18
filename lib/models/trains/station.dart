import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String id;

  // BASIC
  final String name;
  final String city;

  // POSITION
  final double latitude;
  final double longitude;

  // NETWORK
  final List<String> lineIds;

  // ROUTING
  final int zoneNumber;
  final int stopOrder;

  // STATUS
  final bool isActive;

  // FEATURES
  final bool hasParking;
  final bool hasTicketOffice;
  final bool hasAccessibility;

  // LIVE
  final int activeTrainsNow;

  // META
  final String imageUrl;

  final Timestamp updatedAt;

  const Station({
    required this.id,

    required this.name,
    required this.city,

    required this.latitude,
    required this.longitude,

    required this.lineIds,

    required this.zoneNumber,
    required this.stopOrder,

    required this.isActive,

    required this.hasParking,
    required this.hasTicketOffice,
    required this.hasAccessibility,

    required this.activeTrainsNow,

    required this.imageUrl,

    required this.updatedAt,
  });

  // ─────────────────────────────
  // FIREBASE
  // ─────────────────────────────

  factory Station.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return Station(
      id: doc.id,

      name: map['name'] ?? '',
      city: map['city'] ?? '',

      latitude: (map['latitude'] ?? 0).toDouble(),

      longitude: (map['longitude'] ?? 0).toDouble(),

      lineIds: List<String>.from(map['lineIds'] ?? []),

      zoneNumber: map['zoneNumber'] ?? 0,

      stopOrder: map['stopOrder'] ?? 0,

      isActive: map['isActive'] ?? true,

      hasParking: map['hasParking'] ?? false,

      hasTicketOffice: map['hasTicketOffice'] ?? false,

      hasAccessibility: map['hasAccessibility'] ?? false,

      activeTrainsNow: map['activeTrainsNow'] ?? 0,

      imageUrl: map['imageUrl'] ?? '',

      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,

      'latitude': latitude,
      'longitude': longitude,

      'lineIds': lineIds,

      'zoneNumber': zoneNumber,
      'stopOrder': stopOrder,

      'isActive': isActive,

      'hasParking': hasParking,
      'hasTicketOffice': hasTicketOffice,
      'hasAccessibility': hasAccessibility,

      'activeTrainsNow': activeTrainsNow,

      'imageUrl': imageUrl,

      'updatedAt': updatedAt,
    };
  }

  // ─────────────────────────────
  // HELPERS
  // ─────────────────────────────

  bool belongsToLine(String lineId) {
    return lineIds.contains(lineId);
  }

  String get coordinates => '$latitude,$longitude';
}
