class ZonePricing {
  // ─────────────────────────────
  // ZONE MAP
  // ─────────────────────────────
  static const Map<String, int> _zones = {
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
  // PRICE TABLE BY ZONE DIFF
  // diff 0 → 0.800 | diff 1 → 1.000 | diff 2 → 1.200
  // diff 3 → 1.600 | diff 4 → 1.900 | diff 5 → 2.600
  // ─────────────────────────────
  static const List<double> _prices = [
    0.800, // diff 0 (same zone)
    1.000, // diff 1
    1.200, // diff 2
    1.600, // diff 3
    1.900, // diff 4
    2.600, // diff 5 (max: zone 1 → zone 6)
  ];

  static int getZone(String stationName) {
    return _zones[stationName.trim().toUpperCase()] ?? 1;
  }

  /// Base price for one ticket (before class/offer/passenger multiplier)
  static double calcBasePrice(String fromStation, String toStation) {
    final zoneFrom = getZone(fromStation);
    final zoneTo = getZone(toStation);
    final diff = (zoneFrom - zoneTo).abs().clamp(0, 5);
    return _prices[diff];
  }

  static String formatPrice(double price) => '${price.toStringAsFixed(3)} DT';
}
