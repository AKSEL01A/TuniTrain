import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuni_train/controller/map/stations_map_controller.dart';
import 'package:tuni_train/models/trains/station.dart';

class StationsMapPage extends StatefulWidget {
  const StationsMapPage({super.key});

  @override
  State<StationsMapPage> createState() => _StationsMapPageState();
}

class _StationsMapPageState extends State<StationsMapPage>
    with TickerProviderStateMixin {
  final StationsMapController ctrl = Get.put(StationsMapController());
  late final MapController _mapCtrl = MapController();

  double _zoom = 11;
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  late final AnimationController _sheetAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<Offset> _sheetSlide = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _sheetAnim, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _sheetAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectStation(Station s) {
    ctrl.selectStation(s);
    _mapCtrl.move(LatLng(s.latitude, s.longitude), 15);
    setState(() => _zoom = 15);
    _sheetAnim.forward();
  }

  void _closeSheet() {
    _sheetAnim.reverse().then((_) => ctrl.clearSelection());
  }

  void _moveTo(LatLng ll, double zoom) {
    _mapCtrl.move(ll, zoom);
    setState(() => _zoom = zoom);
  }

  double? _distanceBetween(double? userLat, double? userLng, Station s) {
    if (userLat == null || userLng == null) return null;
    return ctrl.distanceBetweenRaw(userLat, userLng, s.latitude, s.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final btmPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B4B),
      body: Stack(
        children: [
          // MAP — never wrapped in Obx
          _buildMap(),

          // Top bar
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar(topPad)),

          // FABs
          Positioned(right: 16, bottom: btmPad + 240, child: _buildFABs()),

          // Zoom controls
          Positioned(
            right: 16,
            bottom: btmPad + 120,
            child: _buildZoomControls(),
          ),

          // Nearest station banner
          Obx(() {
            final nearest = ctrl.nearestStation.value;
            final selected = ctrl.selectedStation.value;
            final userLat = ctrl.userPosition.value?.latitude;
            final userLng = ctrl.userPosition.value?.longitude;
            if (nearest == null || selected != null) {
              return const SizedBox.shrink();
            }
            final dist = _distanceBetween(userLat, userLng, nearest);
            return Positioned(
              bottom: btmPad + 20,
              left: 16,
              right: 16,
              child: _NearestBanner(
                station: nearest,
                distance: dist != null ? ctrl.formatDistance(dist) : null,
                onTap: () => _selectStation(nearest),
                onDirections: () => ctrl.openDirections(nearest),
              ),
            );
          }),

          // Station detail sheet
          Obx(() {
            final s = ctrl.selectedStation.value;
            final userLat = ctrl.userPosition.value?.latitude;
            final userLng = ctrl.userPosition.value?.longitude;
            if (s == null) return const SizedBox.shrink();
            final dist = _distanceBetween(userLat, userLng, s);
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _sheetSlide,
                child: _StationSheet(
                  station: s,
                  distance: dist,
                  formatDistance: ctrl.formatDistance,
                  onClose: _closeSheet,
                  onDirections: () => ctrl.openDirections(s),
                  btmPad: btmPad,
                ),
              ),
            );
          }),

          // Loading overlay
          Obx(() {
            final loading = ctrl.isLoading.value;
            if (!loading) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── MAP ───────────────────────────────────────────────────────────────────
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapCtrl,
      options: MapOptions(
        initialCenter: StationsMapController.defaultCenter,
        initialZoom: 11,
        minZoom: 7,
        maxZoom: 18,
        onPositionChanged: (pos, _) {
          if (pos.zoom != null) setState(() => _zoom = pos.zoom!);
        },
        onTap: (_, __) => _closeSheet(),
      ),
      children: [
        // Base tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tuni_train.app',
        ),

        // ── Layer 1: GeoJSON railway lines ────────────────────────────────
        Obx(() {
          final show = ctrl.showGeoLines.value;
          final features = ctrl.geoFeatures.toList();
          if (!show || features.isEmpty) return const SizedBox.shrink();

          final polylines = <Polyline>[];
          for (final f in features) {
            final geo = f['geometry'] as Map<String, dynamic>? ?? {};
            final type = geo['type'] as String? ?? '';
            if (type != 'LineString' && type != 'MultiLineString') continue;
            final segments = ctrl.geoJsonLines(f);
            final color = ctrl.geoLineColor(f);
            for (final seg in segments) {
              if (seg.length < 2) continue;
              polylines.add(
                Polyline(
                  points: seg,
                  strokeWidth: 3.0,
                  color: color.withValues(alpha: 0.65),
                  strokeCap: StrokeCap.round,
                ),
              );
            }
          }
          return PolylineLayer(polylines: polylines);
        }),

        // ── Layer 2: Circuits (traced routes from Firestore) ──────────────
        Obx(() {
          final show = ctrl.showCircuits.value;
          final circuits = ctrl.activeCircuits;
          if (!show || circuits.isEmpty) return const SizedBox.shrink();

          return PolylineLayer(
            polylines: circuits.map((circuit) {
              final cc = circuit.flutterColor;
              return Polyline(
                points: circuit.points,
                strokeWidth: 5.0,
                color: cc.withValues(alpha: 0.85),
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              );
            }).toList(),
          );
        }),

        // ── Layer 3: Circuit start/end markers ────────────────────────────
        Obx(() {
          final show = ctrl.showCircuits.value;
          final circuits = ctrl.activeCircuits;
          if (!show || circuits.isEmpty) return const SizedBox.shrink();

          final markers = <Marker>[];
          for (final circuit in circuits) {
            if (circuit.points.isEmpty) continue;
            final cc = circuit.flutterColor;
            // Start marker
            markers.add(
              Marker(
                point: circuit.points.first,
                width: 18,
                height: 18,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
            // End marker
            if (circuit.points.length > 1) {
              markers.add(
                Marker(
                  point: circuit.points.last,
                  width: 18,
                  height: 18,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
          return MarkerLayer(markers: markers);
        }),

        // ── Layer 4: Station markers ──────────────────────────────────────
        Obx(() {
          final show = ctrl.showStations.value;
          final stations = ctrl.stations.toList();
          final selectedId = ctrl.selectedStation.value?.id;
          final nearestId = ctrl.nearestStation.value?.id;
          if (!show || stations.isEmpty) return const SizedBox.shrink();

          final markers = stations.map((s) {
            final isSelected = s.id == selectedId;
            final isNearest = s.id == nearestId;

            return Marker(
              point: LatLng(s.latitude, s.longitude),
              width: isSelected ? 60 : 50,
              height: isSelected ? 68 : 58,
              child: GestureDetector(
                onTap: () => _selectStation(s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected || isNearest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0D1B4B)
                              : const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          s.name.length > 14
                              ? '${s.name.substring(0, 14)}...'
                              : s.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 2),
                    Container(
                      width: isSelected ? 24 : 14,
                      height: isSelected ? 24 : 14,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0D1B4B)
                            : isNearest
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF1565C0),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isSelected
                                        ? const Color(0xFF0D1B4B)
                                        : const Color(0xFF1565C0))
                                    .withValues(alpha: 0.4),
                            blurRadius: isSelected ? 10 : 5,
                            spreadRadius: isSelected ? 2 : 0,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.train_rounded,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList();

          return MarkerLayer(markers: markers);
        }),

        // ── Layer 5: User location ────────────────────────────────────────
        Obx(() {
          final pos = ctrl.userPosition.value;
          if (pos == null) return const SizedBox.shrink();
          return MarkerLayer(
            markers: [
              Marker(
                point: LatLng(pos.latitude, pos.longitude),
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1565C0,
                            ).withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),

        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D1B4B).withValues(alpha: 0.95),
            const Color(0xFF0D1B4B).withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carte du réseau',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Obx(() {
                      final stCount = ctrl.stations.length;
                      final circCount = ctrl.circuits.length;
                      return Text(
                        '$stCount gares · $circCount circuits',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchCtrl.clear();
                    ctrl.searchQuery.value = '';
                  }
                }),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _showSearch
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    _showSearch ? Icons.close_rounded : Icons.search_rounded,
                    color: _showSearch ? const Color(0xFF0D1B4B) : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _showSearch
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF90A4AE),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF0D1B4B),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Rechercher une gare...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFFB0BEC5),
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (v) => ctrl.searchQuery.value = v,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Search results
          Obx(() {
            final query = ctrl.searchQuery.value;
            final results = ctrl.filteredStations.take(5).toList();
            final userLat = ctrl.userPosition.value?.latitude;
            final userLng = ctrl.userPosition.value?.longitude;
            if (!_showSearch || query.isEmpty || results.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: results.map((s) {
                  final dist = _distanceBetween(userLat, userLng, s);
                  final isLast = results.last == s;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSearch = false;
                        _searchCtrl.clear();
                        ctrl.searchQuery.value = '';
                      });
                      _selectStation(s);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isLast
                                ? Colors.transparent
                                : const Color(0xFFEEF2F8),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1565C0,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.train_rounded,
                              color: Color(0xFF1565C0),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF0D1B4B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (s.city?.isNotEmpty == true)
                                  Text(
                                    s.city!,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF90A4AE),
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (dist != null)
                            Text(
                              ctrl.formatDistance(dist),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF1565C0),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── FABs ──────────────────────────────────────────────────────────────────
  Widget _buildFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // My location
        Obx(() {
          final isLocating = ctrl.isLocating.value;
          final hasPosition = ctrl.userPosition.value != null;
          return _MapFAB(
            icon: isLocating
                ? null
                : hasPosition
                ? Icons.my_location_rounded
                : Icons.location_searching_rounded,
            isLoading: isLocating,
            color: hasPosition
                ? const Color(0xFF1565C0)
                : const Color(0xFF0D1B4B),
            tooltip: 'Ma position',
            onTap: () async {
              final pos = await ctrl.locateUser();
              if (pos != null) {
                _moveTo(LatLng(pos.latitude, pos.longitude), 14);
              }
            },
          );
        }),
        const SizedBox(height: 10),

        // Nearest station
        Obx(() {
          final hasNearest = ctrl.nearestStation.value != null;
          final hasPosition = ctrl.userPosition.value != null;
          return _MapFAB(
            icon: Icons.directions_transit_rounded,
            color: hasNearest
                ? const Color(0xFF2E7D32)
                : const Color(0xFF90A4AE),
            tooltip: 'Gare la plus proche',
            onTap: () {
              if (!hasPosition) {
                _locateAndNearest();
                return;
              }
              final s = ctrl.nearestStation.value;
              if (s != null) _selectStation(s);
            },
          );
        }),
        const SizedBox(height: 10),

        // Toggle circuits layer
        Obx(() {
          final show = ctrl.showCircuits.value;
          return _MapFAB(
            icon: show ? Icons.route_rounded : Icons.route_outlined,
            color: show ? const Color(0xFF2E7D32) : const Color(0xFF90A4AE),
            tooltip: 'Circuits ferroviaires',
            onTap: () => ctrl.showCircuits.value = !ctrl.showCircuits.value,
          );
        }),
        const SizedBox(height: 10),

        // Toggle GeoJSON lines layer
        Obx(() {
          final show = ctrl.showGeoLines.value;
          return _MapFAB(
            icon: show ? Icons.layers_rounded : Icons.layers_clear_rounded,
            color: show ? const Color(0xFF6A1B9A) : const Color(0xFF90A4AE),
            tooltip: 'Lignes GeoJSON',
            onTap: () => ctrl.showGeoLines.value = !ctrl.showGeoLines.value,
          );
        }),
      ],
    );
  }

  Future<void> _locateAndNearest() async {
    final pos = await ctrl.locateUser();
    if (pos != null) {
      _moveTo(LatLng(pos.latitude, pos.longitude), 13);
      await Future.delayed(const Duration(milliseconds: 400));
      final s = ctrl.nearestStation.value;
      if (s != null) _selectStation(s);
    }
  }

  // ── ZOOM CONTROLS ─────────────────────────────────────────────────────────
  Widget _buildZoomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${_zoom.round()}x',
              style: GoogleFonts.poppins(
                color: const Color(0xFF90A4AE),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _ZoomBtn(
          icon: Icons.add_rounded,
          onTap: () {
            _zoom = (_zoom + 1).clamp(7, 18);
            _mapCtrl.move(_mapCtrl.camera.center, _zoom);
            setState(() {});
          },
        ),
        const SizedBox(height: 4),
        _ZoomBtn(
          icon: Icons.remove_rounded,
          onTap: () {
            _zoom = (_zoom - 1).clamp(7, 18);
            _mapCtrl.move(_mapCtrl.camera.center, _zoom);
            setState(() {});
          },
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// NEAREST STATION BANNER
// ═════════════════════════════════════════════════════════════════════════════
class _NearestBanner extends StatelessWidget {
  final Station station;
  final String? distance;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _NearestBanner({
    required this.station,
    required this.distance,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.directions_transit_rounded,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gare la plus proche',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF90A4AE),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF0D1B4B),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (distance != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.social_distance_rounded,
                          size: 12,
                          color: Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance!,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1565C0),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onDirections,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATION DETAIL SHEET
// ═════════════════════════════════════════════════════════════════════════════
class _StationSheet extends StatelessWidget {
  final Station station;
  final double? distance;
  final String Function(double) formatDistance;
  final VoidCallback onClose;
  final VoidCallback onDirections;
  final double btmPad;

  const _StationSheet({
    required this.station,
    required this.distance,
    required this.formatDistance,
    required this.onClose,
    required this.onDirections,
    required this.btmPad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, btmPad + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B4B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.train_rounded,
                  color: Color(0xFF0D1B4B),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0D1B4B),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (station.city?.isNotEmpty == true)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: Color(0xFF90A4AE),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            station.city!,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF90A4AE),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF90A4AE),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (station.zoneNumber != null)
                _InfoChip(
                  icon: Icons.layers_rounded,
                  label: 'Zone ${station.zoneNumber}',
                  color: const Color(0xFF6A1B9A),
                ),
              if (distance != null)
                _InfoChip(
                  icon: Icons.social_distance_rounded,
                  label: formatDistance(distance!),
                  color: const Color(0xFF1565C0),
                ),
              _InfoChip(
                icon: Icons.check_circle_rounded,
                label: 'Active',
                color: const Color(0xFF2E7D32),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.pin_drop_rounded,
                  color: Color(0xFF90A4AE),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${station.latitude.toStringAsFixed(5)}, '
                  '${station.longitude.toStringAsFixed(5)}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF546E7A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Distance card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.social_distance_rounded,
                        color: Color(0xFF1565C0),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        distance != null ? formatDistance(distance!) : '--',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1565C0),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        distance != null ? 'de vous' : 'Activez la position',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF90A4AE),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Directions button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onDirections,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF0D1B4B)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Itinéraire',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Ouvrir dans Maps',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═════════════════════════════════════════════════════════════════════════════
class _MapFAB extends StatelessWidget {
  final IconData? icon;
  final bool isLoading;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _MapFAB({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Tooltip(
      message: tooltip,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: color,
                ),
              )
            : Icon(icon, color: color, size: 22),
      ),
    ),
  );
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF1565C0), size: 22),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
