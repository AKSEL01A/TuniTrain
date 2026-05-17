import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuni_train/models/station.dart';
import 'package:tuni_train/models/train_line.dart';
import 'package:tuni_train/models/traintime.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class StationWithCoords {
  final Station station;
  final LatLng coords;
  const StationWithCoords({required this.station, required this.coords});
}

class RailwaySegment {
  final List<LatLng> points;
  final Color color;
  final String lineId;
  const RailwaySegment({
    required this.points,
    required this.color,
    required this.lineId,
  });
}

// Station timetable entry (one train stopping at this station)
class StationTimetableEntry {
  final int trainId;
  final String lineId;
  final String departure;
  final String arrival;
  final String dayType;
  const StationTimetableEntry({
    required this.trainId,
    required this.lineId,
    required this.departure,
    required this.arrival,
    required this.dayType,
  });
}

// ── TRUE GeoJSON Coordinates from export.geojson ──────────────────────────────
const Map<String, LatLng> _geoCoords = {
  'sousse bab djedid': LatLng(35.8229148, 10.6415016),
  'sousse bab jedid': LatLng(35.8229148, 10.6415016),
  'sousse med v': LatLng(35.8162829, 10.6433526),
  'sousse mohamed v': LatLng(35.8162829, 10.6433526),
  'sousse sud': LatLng(35.8001927, 10.6499057),
  'sousse zone industrielle': LatLng(35.7821002, 10.6686033),
  'sahline sebkha': LatLng(35.7574586, 10.7171572),
  'sahline ville': LatLng(35.7591436, 10.70312),
  'sahline': LatLng(35.7591436, 10.70312),
  'les hotels': LatLng(35.7601011, 10.7448732),
  'les hotels monastir': LatLng(35.7601011, 10.7448732),
  'aeroport': LatLng(35.7626211, 10.7545542),
  "l'aeroport": LatLng(35.7626211, 10.7545542),
  'airport': LatLng(35.7626211, 10.7545542),
  'faculte 1': LatLng(35.7593931, 10.8070346),
  'la faculte 1': LatLng(35.7593931, 10.8070346),
  'monastir': LatLng(35.770851, 10.8261051),
  'monastir centre': LatLng(35.770851, 10.8261051),
  'faculte 2': LatLng(35.7608002, 10.8091677),
  'la faculte 2': LatLng(35.7608002, 10.8091677),
  'monastir zone industrielle': LatLng(35.7397019, 10.8203432),
  'frina': LatLng(35.7306263, 10.8126671),
  'kheniss bembla': LatLng(35.708942, 10.8125242),
  'khenis bembla': LatLng(35.708942, 10.8125242),
  'ksibet mediouni benane': LatLng(35.6799171, 10.8426835),
  'ksibet el mediouni': LatLng(35.6799171, 10.8426835),
  'bouhjar': LatLng(35.672244, 10.8678348),
  'lamta': LatLng(35.6701564, 10.8825112),
  'sayada': LatLng(35.666072, 10.888306),
  'ksar hellal zone industrielle': LatLng(35.6517434, 10.8986568),
  'ksar hellal': LatLng(35.6449135, 10.9010237),
  'moknine gribaa': LatLng(35.6379139, 10.9069929),
  'moknine': LatLng(35.6312384, 10.9157185),
  'moknine centre': LatLng(35.6312384, 10.9157185),
  'moknine zone industrielle': LatLng(35.630783, 10.931482),
  'teboulba zone industrielle': LatLng(35.633655, 10.9435046),
  'teboulba': LatLng(35.6378506, 10.9612288),
  'bekalta': LatLng(35.6150597, 10.9895536),
  'baghdadi': LatLng(35.569537, 11.0183903),
  'mahdia zone touristique': LatLng(35.536856, 11.0274296),
  'sidi messoud': LatLng(35.5211332, 11.0273412),
  'sidi masaoud': LatLng(35.5211332, 11.0273412),
  'borj el arif': LatLng(35.5061583, 11.0303221),
  'borj arif': LatLng(35.5061583, 11.0303221),
  'ezzahra': LatLng(35.5000219, 11.0482466),
  'mahdia centre': LatLng(35.5007123, 11.0642185),
  'mahdia': LatLng(35.5007123, 11.0642185),
};

String _norm(String s) => s
    .toLowerCase()
    .trim()
    .replaceAll(RegExp(r"['\-]"), '')
    .replaceAll(RegExp(r'\s+'), ' ');

LatLng? _resolveCoords(Station s) {
  final key = _norm(s.name);

  // 1. Direct match
  if (_geoCoords.containsKey(key)) return _geoCoords[key];

  // 2. Partial match
  for (final e in _geoCoords.entries) {
    final k = _norm(e.key);
    if (k.contains(key) || key.contains(k)) return e.value;
  }

  // 3. Word-level match (≥2 significant words)
  final words = key.split(' ').where((w) => w.length > 3).toSet();
  for (final e in _geoCoords.entries) {
    final kw = _norm(e.key).split(' ').toSet();
    if (words.intersection(kw).length >= 2) return e.value;
  }

  // 4. Firestore coords
  if (s.latitude != 0 || s.longitude != 0) {
    return LatLng(s.latitude, s.longitude);
  }

  return null;
}

// ── Controller ────────────────────────────────────────────────────────────────

class StationsMapController extends GetxController
    with GetTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MapController mapController = MapController();

  // State
  final RxBool isLoading = true.obs;
  final Rx<String?> error = Rx<String?>(null);
  final RxList<StationWithCoords> allStations = <StationWithCoords>[].obs;
  final RxList<TrainLine> allLines = <TrainLine>[].obs;
  final RxList<TrainTime> allTrainTimes = <TrainTime>[].obs;
  final RxString selectedLineId = ''.obs;
  final Rxn<StationWithCoords> selectedStation = Rxn<StationWithCoords>();
  final RxBool showLegend = false.obs;
  final RxList<RailwaySegment> allSegments = <RailwaySegment>[].obs;

  // Location
  final Rxn<LatLng> userLocation = Rxn<LatLng>();
  final Rxn<StationWithCoords> nearestStation = Rxn<StationWithCoords>();
  final RxDouble nearestDistKm = 0.0.obs;
  final RxBool locating = false.obs;

  // Timetable
  final RxList<StationTimetableEntry> timetable = <StationTimetableEntry>[].obs;
  final RxBool timetableLoading = false.obs;

  // Animation
  late final AnimationController _pulseCtrl;
  late final Animation<double> pulseAnim;

  List<Station> _rawStations = [];

  @override
  void onInit() {
    super.onInit();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    pulseAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _load();
  }

  @override
  void onClose() {
    _pulseCtrl.dispose();
    super.onClose();
  }

  // ── Computed ───────────────────────────────────────────────────────────────

  List<StationWithCoords> get displayedStations {
    final list = selectedLineId.value.isEmpty
        ? allStations.toList()
        : allStations
              .where((s) => s.station.lineIds.contains(selectedLineId.value))
              .toList();
    return list
      ..sort((a, b) => a.station.stopOrder.compareTo(b.station.stopOrder));
  }

  TrainLine? get selectedLine =>
      allLines.firstWhereOrNull((l) => l.id == selectedLineId.value);

  Color lineColor([String? id]) {
    final line = allLines.firstWhereOrNull(
      (l) => l.id == (id ?? selectedLineId.value),
    );
    return _hexColor(line?.color ?? '#1565C0');
  }

  Color zoneColor(int zone) {
    const m = {
      1: Color(0xFF2196F3),
      2: Color(0xFF4CAF50),
      3: Color(0xFF9C27B0),
      4: Color(0xFFFF9800),
      5: Color(0xFFF44336),
      6: Color(0xFF009688),
    };
    return m[zone] ?? Colors.grey;
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return const Color(0xFF2196F3);
    }
  }

  String normalizeId(String id) =>
      id.toLowerCase().replaceAll(' ', '').replaceAll('_', '');

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    isLoading.value = true;
    error.value = null;
    try {
      await Future.wait([_loadFirestore(), _loadGeoJsonLines()]);
      _buildStations();

      // Auto-select first matching line
      final ids = allStations.expand((s) => s.station.lineIds).toSet();
      final matched = allLines.where((l) => ids.contains(l.id)).toList();
      selectedLineId.value = matched.isNotEmpty
          ? matched.first.id
          : (allLines.isNotEmpty ? allLines.first.id : '');

      debugPrint(
        '✅ ${allStations.length} stations | '
        '${allLines.length} lines | '
        '${allSegments.length} segments | '
        '${allTrainTimes.length} train times',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) => fitBounds());
    } catch (e, st) {
      debugPrint('🚨 $e\n$st');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFirestore() async {
    final results = await Future.wait([
      _db.collection('trainLines').get(),
      _db.collection('stations').get(),
      _db.collection('trainTimes').get(),
    ]);

    allLines.value = results[0].docs
        .map((d) => TrainLine.fromFirestore(d))
        .toList();

    _rawStations = results[1].docs
        .map((d) => Station.fromFirestore(d))
        .toList();

    allTrainTimes.value = results[2].docs
        .map((d) => TrainTime.fromFirestore(d))
        .toList();

    debugPrint(
      '✅ Firestore: ${allLines.length} lines | '
      '${_rawStations.length} stations | '
      '${allTrainTimes.length} train times',
    );
  }

  void _buildStations() {
    final result = <StationWithCoords>[];
    int hits = 0, misses = 0;

    for (final s in _rawStations) {
      final coords = _resolveCoords(s);
      if (coords != null) {
        result.add(StationWithCoords(station: s, coords: coords));
        hits++;
      } else {
        misses++;
        debugPrint('⚠️ No coords: ${s.name}');
      }
    }

    result.sort((a, b) => a.station.stopOrder.compareTo(b.station.stopOrder));
    allStations.value = result;
    debugPrint('✅ Stations resolved: $hits | missing: $misses');
  }

  Future<void> _loadGeoJsonLines() async {
    try {
      final raw = await rootBundle.loadString('assets/geojson/export.geojson');
      final geo = jsonDecode(raw) as Map<String, dynamic>;
      final features = geo['features'] as List? ?? [];
      final segs = <RailwaySegment>[];

      for (final f in features) {
        final geom = f['geometry'] as Map<String, dynamic>?;
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        if (geom == null) continue;

        final type = geom['type'] as String? ?? '';
        final color = _segColor(props);

        void addSeg(List pts) {
          final points = _toLatLng(pts);
          if (points.length >= 2) {
            segs.add(RailwaySegment(points: points, color: color, lineId: ''));
          }
        }

        if (type == 'LineString') {
          addSeg(geom['coordinates'] as List? ?? []);
        } else if (type == 'MultiLineString') {
          for (final seg in geom['coordinates'] as List? ?? []) {
            addSeg(seg as List);
          }
        }
      }

      allSegments.value = segs;
      debugPrint('✅ GeoJSON segments: ${segs.length}');
    } catch (e) {
      debugPrint('⚠️ GeoJSON load error: $e');
    }
  }

  Color _segColor(Map<String, dynamic> props) {
    final c = props['colour']?.toString() ?? props['color']?.toString();
    if (c != null) {
      try {
        return Color(int.parse('FF${c.replaceAll('#', '')}', radix: 16));
      } catch (_) {}
    }
    final cands = ['ref', 'line', 'name', 'network']
        .map((k) => props[k]?.toString().toLowerCase())
        .whereType<String>()
        .toList();
    for (final line in allLines) {
      for (final c2 in cands) {
        if (c2.contains(line.name.toLowerCase()) ||
            c2 == line.id.toLowerCase()) {
          return _hexColor(line.color);
        }
      }
    }
    return lineColor();
  }

  List<LatLng> _toLatLng(List coords) {
    final r = <LatLng>[];
    for (final c in coords) {
      if (c is List && c.length >= 2) {
        try {
          r.add(LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()));
        } catch (_) {}
      }
    }
    return r;
  }

  // ── Timetable ──────────────────────────────────────────────────────────────

  void loadTimetableForStation(StationWithCoords swc) {
    timetableLoading.value = true;
    timetable.clear();

    final stationName = swc.station.name.trim().toUpperCase();
    final stationId = swc.station.id.trim().toLowerCase();

    final entries = <StationTimetableEntry>[];

    for (final tt in allTrainTimes) {
      final ttName = tt.stationName.trim().toUpperCase();
      final ttId = tt.stationId.trim().toLowerCase();

      // Match by id or name
      bool matches =
          (ttId.isNotEmpty && ttId == stationId) ||
          ttName == stationName ||
          ttName.contains(stationName) ||
          stationName.contains(ttName);

      if (!matches) continue;

      final dep = tt.departureTime ?? tt.arrivalTime ?? '';
      final arr = tt.arrivalTime ?? tt.departureTime ?? '';
      if (dep.isEmpty) continue;

      entries.add(
        StationTimetableEntry(
          trainId: tt.trainId,
          lineId: tt.lineId,
          departure: dep,
          arrival: arr,
          dayType: tt.dayType ?? 'LV',
        ),
      );
    }

    // Sort by departure time
    entries.sort(
      (a, b) => _timeToMin(a.departure).compareTo(_timeToMin(b.departure)),
    );

    timetable.value = entries;
    timetableLoading.value = false;

    debugPrint(
      '📅 Timetable for ${swc.station.name}: '
      '${entries.length} trains',
    );
  }

  int _timeToMin(String t) {
    try {
      final p = t.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    } catch (_) {
      return 0;
    }
  }

  bool isTrainDeparted(String dep) {
    final now = TimeOfDay.now();
    final min = _timeToMin(dep);
    final nowM = now.hour * 60 + now.minute;
    return nowM > min;
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> locateUser() async {
    locating.value = true;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission refusée',
          'Activez la localisation dans les paramètres',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      userLocation.value = LatLng(pos.latitude, pos.longitude);
      _computeNearest();
      mapController.move(userLocation.value!, 13.0);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      locating.value = false;
    }
  }

  void _computeNearest() {
    final loc = userLocation.value;
    if (loc == null) return;
    StationWithCoords? best;
    double minD = double.infinity;
    for (final s in displayedStations) {
      final d = _km(loc, s.coords);
      if (d < minD) {
        minD = d;
        best = s;
      }
    }
    nearestStation.value = best;
    nearestDistKm.value = minD;
  }

  double _km(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLa = _rad(b.latitude - a.latitude);
    final dLo = _rad(b.longitude - a.longitude);
    final x =
        math.sin(dLa / 2) * math.sin(dLa / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLo / 2) *
            math.sin(dLo / 2);
    return R * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
  }

  double _rad(double d) => d * math.pi / 180;

  double? distanceToStation(StationWithCoords s) {
    final loc = userLocation.value;
    return loc == null ? null : _km(loc, s.coords);
  }

  String formatDist(double km) =>
      km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

  // ── Actions ────────────────────────────────────────────────────────────────

  void selectLine(String id) {
    selectedLineId.value = id;
    selectedStation.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => fitBounds());
  }

  void selectStation(StationWithCoords s) {
    selectedStation.value = s;
    loadTimetableForStation(s);
    mapController.move(s.coords, 14.0);
  }

  void clearSelection() {
    selectedStation.value = null;
    timetable.clear();
  }

  void toggleLegend() => showLegend.value = !showLegend.value;

  void fitBounds() {
    final stations = displayedStations;
    if (stations.isEmpty) return;
    final lats = stations.map((s) => s.coords.latitude);
    final lngs = stations.map((s) => s.coords.longitude);
    try {
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(
            LatLng(lats.reduce(math.min) - 0.05, lngs.reduce(math.min) - 0.05),
            LatLng(lats.reduce(math.max) + 0.05, lngs.reduce(math.max) + 0.05),
          ),
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ fitCamera: $e');
    }
  }

  void zoomIn() => mapController.move(
    mapController.camera.center,
    mapController.camera.zoom + 1,
  );
  void zoomOut() => mapController.move(
    mapController.camera.center,
    mapController.camera.zoom - 1,
  );

  StationWithCoords? previousStation(StationWithCoords s) {
    final list = displayedStations;
    final idx = list.indexWhere((x) => x.station.id == s.station.id);
    return idx > 0 ? list[idx - 1] : null;
  }

  StationWithCoords? nextStation(StationWithCoords s) {
    final list = displayedStations;
    final idx = list.indexWhere((x) => x.station.id == s.station.id);
    return (idx != -1 && idx < list.length - 1) ? list[idx + 1] : null;
  }
}
