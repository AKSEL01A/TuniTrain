import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuni_train/models/trains/station.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Simple circuit model for client side ─────────────────────────────────────
class ClientCircuit {
  final String id;
  final String name;
  final String color;
  final String lineId;
  final String lineName;
  final bool isActive;
  final List<LatLng> points;

  const ClientCircuit({
    required this.id,
    required this.name,
    required this.color,
    required this.lineId,
    required this.lineName,
    required this.isActive,
    required this.points,
  });

  factory ClientCircuit.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    final rawPoints = m['points'] as List<dynamic>? ?? [];
    final points = rawPoints.map((p) {
      final mp = p as Map<String, dynamic>;
      return LatLng(
        (mp['lat'] as num).toDouble(),
        (mp['lng'] as num).toDouble(),
      );
    }).toList();

    return ClientCircuit(
      id: doc.id,
      name: m['name'] as String? ?? '',
      color: m['color'] as String? ?? '#1565C0',
      lineId: m['lineId'] as String? ?? '',
      lineName: m['lineName'] as String? ?? '',
      isActive: m['isActive'] as bool? ?? true,
      points: points,
    );
  }

  Color get flutterColor {
    try {
      return Color(int.parse('FF${color.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFF1565C0);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class StationsMapController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // ── Data ──────────────────────────────────────────────────────────────────
  final RxList<Station> stations = <Station>[].obs;
  final RxList<Map<String, dynamic>> geoFeatures = <Map<String, dynamic>>[].obs;
  final RxList<ClientCircuit> circuits = <ClientCircuit>[].obs;

  // ── State ─────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isLocating = false.obs;
  final Rx<Position?> userPosition = Rx<Position?>(null);
  final Rx<Station?> selectedStation = Rx<Station?>(null);
  final Rx<Station?> nearestStation = Rx<Station?>(null);

  // ── Layer toggles ─────────────────────────────────────────────────────────
  final RxBool showGeoLines = true.obs;
  final RxBool showStations = true.obs;
  final RxBool showCircuits = true.obs;

  // ── Search ────────────────────────────────────────────────────────────────
  final RxString searchQuery = ''.obs;

  List<Station> get filteredStations {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) return stations.toList();
    return stations
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              (s.city?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  // Only active circuits
  List<ClientCircuit> get activeCircuits =>
      circuits.where((c) => c.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  // ── Load all ──────────────────────────────────────────────────────────────
  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      await Future.wait([_loadStations(), _loadGeoJson(), _loadCircuits()]);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load stations from Firestore ──────────────────────────────────────────
  Future<void> _loadStations() async {
    try {
      final snap = await _db
          .collection('stations')
          .where('isActive', isEqualTo: true)
          .get();

      stations.value = snap.docs
          .map((d) => Station.fromFirestore(d))
          .where((s) => s.latitude != 0 && s.longitude != 0)
          .toList();

      debugPrint('✅ Client map: ${stations.length} stations');
    } catch (e) {
      debugPrint('❌ _loadStations: $e');
    }
  }

  // ── Load GeoJSON railway lines ─────────────────────────────────────────────
  Future<void> _loadGeoJson() async {
    try {
      final raw = await rootBundle.loadString('assets/geojson/export.geojson');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final features = (json['features'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      geoFeatures.assignAll(features);
      debugPrint('✅ GeoJSON: ${features.length} features');
    } catch (e) {
      debugPrint('⚠️  GeoJSON not found: $e');
    }
  }

  // ── Load circuits (traced routes) from Firestore ───────────────────────────
  Future<void> _loadCircuits() async {
    try {
      final snap = await _db
          .collection('circuits')
          .where('isActive', isEqualTo: true)
          .get();

      circuits.value = snap.docs.map(ClientCircuit.fromFirestore).toList();

      debugPrint('✅ Circuits: ${circuits.length}');
    } catch (e) {
      debugPrint('❌ _loadCircuits: $e');
    }
  }

  // ── Location ──────────────────────────────────────────────────────────────
  Future<Position?> locateUser() async {
    isLocating.value = true;
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _snack('Activez la localisation dans les paramètres');
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userPosition.value = pos;
      _computeNearest();
      return pos;
    } catch (e) {
      _snack('Impossible d\'obtenir votre position');
      return null;
    } finally {
      isLocating.value = false;
    }
  }

  void _computeNearest() {
    final pos = userPosition.value;
    if (pos == null || stations.isEmpty) return;
    Station? nearest;
    double minDist = double.infinity;
    for (final s in stations) {
      final d = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        s.latitude,
        s.longitude,
      );
      if (d < minDist) {
        minDist = d;
        nearest = s;
      }
    }
    nearestStation.value = nearest;
  }

  // ── Distance helpers ──────────────────────────────────────────────────────
  /// Call only inside Obx — reads observable directly
  double? distanceTo(Station s) {
    final pos = userPosition.value;
    if (pos == null) return null;
    return Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      s.latitude,
      s.longitude,
    );
  }

  /// Pure — safe to call anywhere with pre-extracted values
  double distanceBetweenRaw(
    double userLat,
    double userLng,
    double stationLat,
    double stationLng,
  ) => Geolocator.distanceBetween(userLat, userLng, stationLat, stationLng);

  String formatDistance(double metres) {
    if (metres < 1000) return '${metres.round()} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  // ── Directions ────────────────────────────────────────────────────────────
  Future<void> openDirections(Station s) async {
    final pos = userPosition.value;
    final Uri uri = pos != null
        ? Uri.parse(
            'https://www.google.com/maps/dir/'
            '${pos.latitude},${pos.longitude}/'
            '${s.latitude},${s.longitude}/'
            '@${s.latitude},${s.longitude},15z'
            '?travelmode=driving',
          )
        : Uri.parse(
            'https://www.google.com/maps/dir/?api=1'
            '&destination=${s.latitude},${s.longitude}'
            '&travelmode=driving',
          );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final geo = Uri.parse(
        'geo:${s.latitude},${s.longitude}?q=${Uri.encodeComponent(s.name)}',
      );
      if (await canLaunchUrl(geo)) {
        await launchUrl(geo, mode: LaunchMode.externalApplication);
      } else {
        _snack('Impossible d\'ouvrir la navigation');
      }
    }
  }

  // ── GeoJSON parsers ───────────────────────────────────────────────────────
  List<List<LatLng>> geoJsonLines(Map<String, dynamic> feature) {
    try {
      final geo = feature['geometry'] as Map<String, dynamic>;
      final type = geo['type'] as String;
      final coords = geo['coordinates'];
      if (type == 'LineString') return [_parseCoords(coords as List)];
      if (type == 'MultiLineString') {
        return (coords as List)
            .map((seg) => _parseCoords(seg as List))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  List<LatLng> _parseCoords(List coords) => coords
      .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
      .toList();

  Color geoLineColor(Map<String, dynamic> feature) {
    final p = feature['properties'] as Map<String, dynamic>? ?? {};
    final hex = p['color'] as String? ?? p['colour'] as String? ?? '';
    if (hex.isNotEmpty) {
      try {
        return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
      } catch (_) {}
    }
    return const Color(0xFF1565C0);
  }

  void selectStation(Station s) => selectedStation.value = s;
  void clearSelection() => selectedStation.value = null;

  void _snack(String msg) => Get.snackbar(
    'Localisation',
    msg,
    backgroundColor: const Color(0xFF0D1B4B),
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    borderRadius: 14,
  );

  static const LatLng defaultCenter = LatLng(35.8245, 10.6346);
}
