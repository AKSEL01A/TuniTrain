import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/map/stations_map_controller.dart';
import 'package:tuni_train/models/trains/station.dart';

class StationsMapPage extends StatefulWidget {
  const StationsMapPage({super.key});

  @override
  State<StationsMapPage> createState() => _StationsMapPageState();
}

class _StationsMapPageState extends State<StationsMapPage>
    with SingleTickerProviderStateMixin {
  final StationsMapController ctrl = Get.put(StationsMapController());

  // Tab controller for station sheet
  TabController? _tabs;
  String? _sheetStationId;

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  // Ensure tab controller matches current selected station
  void _ensureTabs(String stationId) {
    if (_sheetStationId != stationId) {
      _tabs?.dispose();
      _tabs = TabController(length: 2, vsync: this);
      _sheetStationId = stationId;
    }
  }

  double _headerH(BuildContext ctx) => MediaQuery.of(ctx).padding.top + 62;

  // ─── ROOT ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Obx(() {
        if (ctrl.isLoading.value) return _buildLoader();
        if (ctrl.error.value != null) return _buildError(ctrl.error.value!);

        return Stack(
          children: [
            _buildMap(),

            // Header
            Positioned(top: 0, left: 0, right: 0, child: _buildHeader(context)),

            // Line filter chips
            Positioned(
              top: _headerH(context),
              left: 0,
              right: 0,
              child: _buildLineChips(),
            ),

            // Nearest station banner
            Obx(() {
              final nearest = ctrl.nearestStation.value;
              final sel = ctrl.selectedStation.value;
              if (nearest == null || sel != null) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: _headerH(context) + 52,
                left: 12,
                right: 12,
                child: _buildNearestBanner(nearest),
              );
            }),

            // Zone legend
            Obx(
              () => ctrl.showLegend.value
                  ? Positioned(
                      top: _headerH(context) + 52,
                      right: 12,
                      child: _buildZoneLegend(),
                    )
                  : const SizedBox.shrink(),
            ),

            // Station sheet
            Obx(() {
              final swc = ctrl.selectedStation.value;
              if (swc == null) return const SizedBox.shrink();
              _ensureTabs(swc.station.id);
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildStationSheet(context, swc),
              );
            }),

            // FABs
            Positioned(
              bottom: 24,
              right: 16,
              child: Obx(
                () => ctrl.selectedStation.value == null
                    ? _buildFabs()
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─── LOADER / ERROR ──────────────────────────────────────────────────────
  Widget _buildLoader() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.blue1),
        const SizedBox(height: 16),
        Text(
          'Chargement de la carte…',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildError(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.blue1, fontSize: 14),
          ),
        ],
      ),
    ),
  );

  // ─── MAP ─────────────────────────────────────────────────────────────────
  Widget _buildMap() {
    return Obx(() {
      final stations = ctrl.displayedStations;
      final segments = ctrl.allSegments;

      return FlutterMap(
        mapController: ctrl.mapController,
        options: MapOptions(
          initialCenter: const LatLng(35.690, 10.800),
          initialZoom: 9.0,
          minZoom: 6,
          maxZoom: 18,
          initialRotation: 0,
          onTap: (_, _) => ctrl.clearSelection(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tunitrain.app',
            maxZoom: 19,
          ),

          if (segments.isNotEmpty)
            PolylineLayer(
              polylines: [
                ...segments.map(
                  (seg) => Polyline(
                    points: seg.points,
                    strokeWidth: 6.0,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                ...segments.map(
                  (seg) => Polyline(
                    points: seg.points,
                    strokeWidth: 4.0,
                    color: ctrl.lineColor().withValues(alpha: 0.9),
                  ),
                ),
              ],
            )
          else if (stations.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: stations.map((s) => s.coords).toList(),
                  strokeWidth: 4.0,
                  color: ctrl.lineColor().withValues(alpha: 0.85),
                  borderStrokeWidth: 2.0,
                  borderColor: Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),

          if (ctrl.userLocation.value != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: ctrl.userLocation.value!,
                  width: 60,
                  height: 60,
                  child: _buildUserMarker(),
                ),
              ],
            ),

          MarkerLayer(
            markers: stations.map((swc) {
              final isSel =
                  ctrl.selectedStation.value?.station.id == swc.station.id;
              final isNearest =
                  ctrl.nearestStation.value?.station.id == swc.station.id;
              return Marker(
                point: swc.coords,
                width: isSel ? 54 : 34,
                height: isSel ? 54 : 34,
                child: GestureDetector(
                  onTap: () => ctrl.selectStation(swc),
                  child: _buildStationMarker(
                    color: ctrl.zoneColor(swc.station.zoneNumber),
                    isSelected: isSel,
                    isNearest: isNearest,
                    zone: swc.station.zoneNumber,
                  ),
                ),
              );
            }).toList(),
          ),

          MarkerLayer(
            markers: stations.map((swc) {
              final isSel =
                  ctrl.selectedStation.value?.station.id == swc.station.id;
              return Marker(
                point: swc.coords,
                width: 160,
                height: 22,
                alignment: const Alignment(0, -2.7),
                child: GestureDetector(
                  onTap: () => ctrl.selectStation(swc),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.blue1.withValues(alpha: 0.92)
                          : Colors.white.withValues(alpha: 0.93),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x20000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      swc.station.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: isSel ? Colors.white : const Color(0xFF1A1F36),
                        fontSize: 7.5,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  // ─── STATION MARKER ──────────────────────────────────────────────────────
  Widget _buildStationMarker({
    required Color color,
    required bool isSelected,
    required bool isNearest,
    required int zone,
  }) {
    return AnimatedBuilder(
      animation: ctrl.pulseAnim,
      builder: (_, _) {
        final scale = (isNearest || isSelected) ? ctrl.pulseAnim.value : 1.0;
        final c = isNearest ? const Color(0xFFFFD600) : color;
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? c : Colors.white,
              border: Border.all(color: c, width: isSelected ? 3 : 2),
              boxShadow: [
                BoxShadow(
                  color: c.withValues(alpha: isSelected ? 0.5 : 0.25),
                  blurRadius: isSelected ? 18 : 6,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: isSelected
                  ? const Icon(
                      Icons.train_rounded,
                      color: Colors.white,
                      size: 22,
                    )
                  : isNearest
                  ? const Icon(
                      Icons.near_me_rounded,
                      color: Color(0xFFFFD600),
                      size: 14,
                    )
                  : Text(
                      '$zone',
                      style: TextStyle(
                        color: c,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // ─── USER MARKER ─────────────────────────────────────────────────────────
  Widget _buildUserMarker() {
    return AnimatedBuilder(
      animation: ctrl.pulseAnim,
      builder: (_, _) {
        final v = ctrl.pulseAnim.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60 * v,
              height: 60 * v,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue1.withValues(alpha: (1 - v) * 0.3),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue1,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x501565C0),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext ctx) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue1, AppColors.blue2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 12, 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carte des Gares',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${ctrl.displayedStations.length} gares'
                        '${ctrl.selectedLine != null ? ' · ${ctrl.selectedLine!.name}' : ''}',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => _buildHBtn(
                  icon: ctrl.locating.value
                      ? Icons.location_searching_rounded
                      : ctrl.userLocation.value != null
                      ? Icons.my_location_rounded
                      : Icons.location_on_rounded,
                  active: ctrl.userLocation.value != null,
                  activeColor: const Color(0xFF4CAF50),
                  onTap: ctrl.locateUser,
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => _buildHBtn(
                  icon: Icons.layers_rounded,
                  active: ctrl.showLegend.value,
                  onTap: ctrl.toggleLegend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHBtn({
    required IconData icon,
    required bool active,
    Color activeColor = AppColors.blue2,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: active
            ? Border.all(color: Colors.white.withValues(alpha: 0.5))
            : null,
      ),
      child: Icon(
        icon,
        color: active ? Colors.white : Colors.white70,
        size: 18,
      ),
    ),
  );

  // ─── LINE CHIPS ──────────────────────────────────────────────────────────
  Widget _buildLineChips() {
    return Container(
      height: 50,
      color: Colors.white.withValues(alpha: 0.97),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: ctrl.allLines.length,
          itemBuilder: (_, i) {
            final line = ctrl.allLines[i];
            final sel = ctrl.selectedLineId.value == line.id;
            final lColor = ctrl.lineColor(line.id);
            return GestureDetector(
              onTap: () => ctrl.selectLine(line.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: sel ? lColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? lColor : const Color(0xFFDDE6F5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: sel ? Colors.white : lColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      line.name,
                      style: GoogleFonts.poppins(
                        color: sel ? Colors.white : AppColors.blue3,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── FABs ────────────────────────────────────────────────────────────────
  Widget _buildFabs() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _fab(
        Icons.fit_screen_rounded,
        ctrl.fitBounds,
        Colors.white,
        AppColors.blue1,
      ),
      const SizedBox(height: 8),
      _fab(
        Icons.add_rounded,
        ctrl.zoomIn,
        AppColors.blue1,
        Colors.white,
        topR: 13,
        botR: 0,
      ),
      _fab(
        Icons.remove_rounded,
        ctrl.zoomOut,
        AppColors.blue1.withValues(alpha: 0.85),
        Colors.white,
        topR: 0,
        botR: 13,
      ),
    ],
  );

  Widget _fab(
    IconData icon,
    VoidCallback onTap,
    Color bg,
    Color ic, {
    double topR = 13,
    double botR = 13,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topR),
          bottom: Radius.circular(botR),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: ic, size: 20),
    ),
  );

  // ─── NEAREST BANNER ──────────────────────────────────────────────────────
  Widget _buildNearestBanner(StationWithCoords nearest) {
    final zc = ctrl.zoneColor(nearest.station.zoneNumber);
    return GestureDetector(
      onTap: () => ctrl.selectStation(nearest),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFFD600).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD600), width: 2),
              ),
              child: const Icon(
                Icons.near_me_rounded,
                color: Color(0xFFFFD600),
                size: 16,
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
                      color: AppColors.blue3,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    nearest.station.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD600).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ctrl.formatDist(ctrl.nearestDistKm.value),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFCCA800),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: zc.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Zone ${nearest.station.zoneNumber}',
                    style: GoogleFonts.poppins(
                      color: zc,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.blue3,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ─── ZONE LEGEND ─────────────────────────────────────────────────────────
  Widget _buildZoneLegend() {
    const prices = [0.800, 1.000, 1.200, 1.600, 1.900, 2.600];
    return Container(
      width: 185,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zones & Tarifs',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(6, (i) {
            final zone = i + 1;
            final color = ctrl.zoneColor(zone);
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.12),
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$zone',
                        style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Zone $zone',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${prices[i].toStringAsFixed(3)} DT',
                    style: GoogleFonts.poppins(
                      color: i == 0 ? AppColors.green : AppColors.sand,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
          Divider(color: Colors.grey.shade200, height: 14),
          Text(
            '* Tarif depuis Zone 1',
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ─── STATION SHEET ───────────────────────────────────────────────────────
  Widget _buildStationSheet(BuildContext context, StationWithCoords swc) {
    final station = swc.station;
    final zc = ctrl.zoneColor(station.zoneNumber);
    final prev = ctrl.previousStation(swc);
    final next = ctrl.nextStation(swc);
    final dist = ctrl.distanceToStation(swc);
    final tabs = _tabs!;

    return GestureDetector(
      onTap: () {},
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: zc.withValues(alpha: 0.12),
                      border: Border.all(color: zc, width: 2.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Z',
                          style: GoogleFonts.poppins(
                            color: zc,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${station.zoneNumber}',
                          style: GoogleFonts.poppins(
                            color: zc,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (station.city.isNotEmpty)
                          Text(
                            station.city,
                            style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 11,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 5,
                          runSpacing: 3,
                          children: [
                            _chip('Z${station.zoneNumber}', zc),
                            _chip('#${station.stopOrder}', AppColors.blue1),
                            if (station.isActive)
                              _chip('Active', AppColors.green),
                            if (station.hasTicketOffice)
                              _chip('Guichet', AppColors.sand),
                            if (station.hasParking)
                              _chip('Parking', AppColors.blue3),
                            if (station.hasAccessibility)
                              _chip('PMR', const Color(0xFF6A1B9A)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: ctrl.clearSelection,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.bgPage,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.blue3,
                            size: 15,
                          ),
                        ),
                      ),
                      if (dist != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFD600,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            ctrl.formatDist(dist),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFCCA800),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // GPS row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.blue3,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${swc.coords.latitude.toStringAsFixed(5)}°N  '
                      '${swc.coords.longitude.toStringAsFixed(5)}°E',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Neighbours
            if (prev != null || next != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    if (prev != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => ctrl.selectStation(prev),
                          child: _buildNeighbourBtn(prev.station.name, false),
                        ),
                      ),
                    if (prev != null && next != null) const SizedBox(width: 8),
                    if (next != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => ctrl.selectStation(next),
                          child: _buildNeighbourBtn(next.station.name, true),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: tabs,
                indicator: BoxDecoration(
                  color: AppColors.blue1,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.blue3,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                tabs: const [
                  Tab(text: 'Informations'),
                  Tab(text: 'Horaires'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Flexible(
              child: TabBarView(
                controller: tabs,
                children: [
                  // Tab 1 – Info
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      children: [
                        _buildPriceTable(station),
                        const SizedBox(height: 14),
                        _buildSearchBtn(),
                      ],
                    ),
                  ),
                  // Tab 2 – Timetable
                  _buildTimetableTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: GoogleFonts.poppins(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _buildNeighbourBtn(String name, bool forward) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFDDE6F5)),
    ),
    child: Row(
      mainAxisAlignment: forward
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!forward) ...[
          const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.blue3,
            size: 13,
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            textAlign: forward ? TextAlign.end : TextAlign.start,
            style: GoogleFonts.poppins(
              color: AppColors.blue3,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (forward) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.blue3,
            size: 13,
          ),
        ],
      ],
    ),
  );

  // ─── PRICE TABLE ─────────────────────────────────────────────────────────
  Widget _buildPriceTable(Station station) {
    const prices = [0.800, 1.000, 1.200, 1.600, 1.900, 2.600];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: AppColors.blue3,
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                'Tarifs depuis cette gare',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(6, (i) {
              final zone = i + 1;
              final diff = (station.zoneNumber - zone).abs().clamp(0, 5);
              final price = prices[diff];
              final isSame = zone == station.zoneNumber;
              final color = ctrl.zoneColor(zone);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSame
                        ? color.withValues(alpha: 0.14)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSame ? color : const Color(0xFFDDE6F5),
                      width: isSame ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Z$zone',
                        style: GoogleFonts.poppins(
                          color: isSame ? color : AppColors.blue3,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        price.toStringAsFixed(2),
                        style: GoogleFonts.poppins(
                          color: isSame ? color : AppColors.blue1,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── SEARCH BUTTON ───────────────────────────────────────────────────────
  Widget _buildSearchBtn() => GestureDetector(
    onTap: () {
      ctrl.clearSelection();
      Get.back();
    },
    child: Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blue2, AppColors.blue1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Chercher un train depuis ici',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );

  // ─── TIMETABLE TAB ───────────────────────────────────────────────────────
  Widget _buildTimetableTab() {
    return Obx(() {
      if (ctrl.timetableLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: AppColors.blue1),
          ),
        );
      }

      final entries = ctrl.timetable;
      if (entries.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: AppColors.blue3.withValues(alpha: 0.4),
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun horaire disponible',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final Map<String, List<StationTimetableEntry>> grouped = {};
      for (final e in entries) {
        grouped.putIfAbsent(e.dayType, () => []).add(e);
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: grouped.entries.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue1.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _dayLabel(group.key),
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${group.value.length} trains',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              ...group.value.map((entry) {
                final departed = ctrl.isTrainDeparted(entry.departure);
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: departed ? Colors.grey.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: departed
                          ? Colors.grey.shade200
                          : AppColors.blue1.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: departed
                              ? Colors.grey.shade100
                              : AppColors.blue1.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.train_rounded,
                          color: departed ? Colors.grey : AppColors.blue1,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Train ${entry.trainId}',
                              style: GoogleFonts.poppins(
                                color: departed ? Colors.grey : AppColors.blue1,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (entry.lineId.isNotEmpty)
                              Text(
                                entry.lineId,
                                style: GoogleFonts.poppins(
                                  color: AppColors.blue3,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                size: 11,
                                color: departed ? Colors.grey : AppColors.green,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                entry.departure,
                                style: GoogleFonts.poppins(
                                  color: departed
                                      ? Colors.grey
                                      : AppColors.blue1,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          if (entry.arrival.isNotEmpty &&
                              entry.arrival != entry.departure)
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 10,
                                  color: AppColors.blue3,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  entry.arrival,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.blue3,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: departed
                              ? Colors.grey.shade300
                              : AppColors.green,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        }).toList(),
      );
    });
  }

  String _dayLabel(String dayType) {
    switch (dayType.toUpperCase()) {
      case 'LV':
        return '🗓 Lun – Ven';
      case 'LS':
        return '📅 Lun – Sam';
      case 'SD':
        return '🎉 Sam – Dim';
      case 'WE':
        return '🎉 Week-end';
      case 'HO':
        return '🏖 Jours fériés';
      default:
        return '📅 $dayType';
    }
  }
}
