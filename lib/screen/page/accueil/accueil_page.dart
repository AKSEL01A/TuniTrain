import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/auth/auth_controller.dart';
import 'package:tuni_train/controller/accueil/accueil_controller.dart';
import 'package:tuni_train/controller/purchase/services/car_rental_controller.dart';
import 'package:tuni_train/controller/purchase/services/place_controller.dart';
import 'package:tuni_train/data/services/alert.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/models/services/place.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ALERT HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Color _alertAccent(AlertType type) => switch (type) {
  AlertType.warning => const Color(0xFFE65100),
  AlertType.danger => const Color(0xFFC62828),
  AlertType.success => const Color(0xFF2E7D32),
  AlertType.info => const Color(0xFF1565C0),
};

Color _alertBg(AlertType type) => switch (type) {
  AlertType.warning => const Color(0xFFFFF3E0),
  AlertType.danger => const Color(0xFFFFEBEE),
  AlertType.success => const Color(0xFFE8F5E9),
  AlertType.info => const Color(0xFFE8EAF6),
};

Color _alertBorder(AlertType type) => switch (type) {
  AlertType.warning => const Color(0xFFFFCC80),
  AlertType.danger => const Color(0xFFEF9A9A),
  AlertType.success => const Color(0xFFA5D6A7),
  AlertType.info => const Color(0xFF9FA8DA),
};

IconData _alertIcon(AlertType type) => switch (type) {
  AlertType.warning => Icons.warning_amber_rounded,
  AlertType.danger => Icons.dangerous_rounded,
  AlertType.success => Icons.check_circle_rounded,
  AlertType.info => Icons.info_rounded,
};

String _alertTag(AlertType type) => switch (type) {
  AlertType.warning => 'AVERTISSEMENT',
  AlertType.danger => 'URGENCE',
  AlertType.success => 'BONNE NOUVELLE',
  AlertType.info => 'INFORMATION',
};

// ─────────────────────────────────────────────────────────────────────────────
// ALERT DETAIL SHEET
// ─────────────────────────────────────────────────────────────────────────────

void _showAlertDetail(BuildContext context, Alert alert) {
  final accent = _alertAccent(alert.type);
  final bg = _alertBg(alert.type);
  final icon = _alertIcon(alert.type);
  final tag = _alertTag(alert.type);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.40,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: accent, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.poppins(
                                    color: accent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                alert.title,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF0D1B4B),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey[100], thickness: 1),
                    const SizedBox(height: 18),
                    Text(
                      'Message',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        alert.message,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0D1B4B),
                          fontSize: 14,
                          height: 1.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Détails',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _detailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Publié le',
                      value: DateFormat(
                        'd MMMM yyyy à HH:mm',
                        'fr_FR',
                      ).format(alert.createdAt),
                      accent: accent,
                      bg: bg,
                    ),
                    _detailRow(
                      icon: Icons.people_alt_rounded,
                      label: 'Destinataires',
                      value: alert.target.label,
                      accent: accent,
                      bg: bg,
                    ),
                    if (alert.expiresAt != null)
                      _detailRow(
                        icon: Icons.event_rounded,
                        label: 'Expire le',
                        value: DateFormat(
                          'd MMMM yyyy',
                          'fr_FR',
                        ).format(alert.expiresAt!),
                        accent: accent,
                        bg: bg,
                      ),
                    _detailRow(
                      icon: Icons.notifications_active_rounded,
                      label: 'Notification push',
                      value: alert.isPushEnabled ? 'Activée' : 'Désactivée',
                      accent: accent,
                      bg: bg,
                    ),
                    if (alert.targetLineName != null ||
                        alert.targetStationName != null)
                      _detailRow(
                        icon: Icons.alt_route_rounded,
                        label: alert.targetLineName != null
                            ? 'Ligne concernée'
                            : 'Gare concernée',
                        value:
                            alert.targetLineName ??
                            alert.targetStationName ??
                            '',
                        accent: accent,
                        bg: bg,
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Fermer',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _detailRow({
  required IconData icon,
  required String label,
  required String value,
  required Color accent,
  required Color bg,
}) => Container(
  margin: const EdgeInsets.only(bottom: 10),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: const Color(0xFFF5F7FA),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: accent, size: 16),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF0D1B4B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// MULTI-IMAGE WIDGET  — swipeable gallery, crash-safe
// ─────────────────────────────────────────────────────────────────────────────

class _ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final Widget placeholder;

  const _ImageGallery({
    required this.imageUrls,
    required this.height,
    required this.placeholder,
  });

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _index = 0;
  // Each card gets its own PageController so they never share state
  late final PageController _pc = PageController();

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) {
      return SizedBox(height: widget.height, child: widget.placeholder);
    }
    // Single image — no PageView needed (avoids any scroll conflict)
    if (urls.length == 1) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: _imgWidget(urls.first),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Use NeverScrollableScrollPhysics + manual drag to avoid competing
          // with the parent SingleChildScrollView
          PageView.builder(
            controller: _pc,
            // ClampingScrollPhysics keeps swipes inside this widget only
            physics: const ClampingScrollPhysics(),
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _imgWidget(urls[i]),
          ),
          // Dot indicators
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(urls.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
          // Image count badge
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_index + 1}/${urls.length}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgWidget(String url) {
    if (url.trim().isEmpty) return widget.placeholder;
    if (url.startsWith('data:image')) {
      try {
        final bytes = base64Decode(url.split(',').last);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: widget.height,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return widget.placeholder;
      }
    }
    return Image.network(
      url,
      width: double.infinity,
      height: widget.height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => widget.placeholder,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: const Color(0xFFE8EAF6),
              child: const Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AccueilPageScreen extends StatefulWidget {
  const AccueilPageScreen({super.key});

  @override
  State<AccueilPageScreen> createState() => _AccueilPageScreenState();
}

class _AccueilPageScreenState extends State<AccueilPageScreen> {
  final AccueilController ctrl = Get.put(AccueilController());
  final PlaceController placeCtrl = Get.put(PlaceController());
  final CarRentalController carCtrl = Get.put(CarRentalController());

  // Alerts pager — kept SEPARATE from the parent scroll
  final PageController _alertsPage = PageController(viewportFraction: 1.0);
  int _alertIndex = 0;
  Timer? _alertsTimer;

  PlaceCategory? _selectedPlaceCategory;

  String get _todayStr =>
      DateFormat('EEEE, d MMMM yyyy', 'fr_FR').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _alertsTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final n = ctrl.visibleAlerts.length;
      if (n <= 1 || !_alertsPage.hasClients) return;
      _alertIndex = (_alertIndex + 1) % n;
      _alertsPage.animateToPage(
        _alertIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _alertsTimer?.cancel();
    _alertsPage.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      ctrl.refreshAll(),
      placeCtrl.reloadData(),
      carCtrl.reloadData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        color: AppColors.blue1,
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          // NeverScrollableScrollPhysics on the PageViews inside means
          // vertical flings always go to THIS scroller, not the cards
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hero(context),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _sectionLabel('Actualités'),
              ),
              const SizedBox(height: 14),
              _alertsSection(),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('À Découvrir'),
                    GestureDetector(
                      onTap: () => Get.toNamed('/services/places'),
                      child: _seeAllBtn(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _placeCategoryFilters(),
              const SizedBox(height: 14),
              _placesList(),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('Location de Voitures'),
                    GestureDetector(
                      onTap: () => Get.toNamed('/services/cars'),
                      child: _seeAllBtn(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _carCategoryFilters(),
              const SizedBox(height: 16),
              _carsList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _hero(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      height: 335 + topPad,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/sidibousaid.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.50),
              Colors.black.withValues(alpha: 0.12),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, topPad + 14, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                // On récupère le client une seule fois pour tout le bloc
                final user = Get.find<AuthController>().client.value;
                final firstName = user?.firstName ?? '';

                return Row(
                  children: [
                    // Section Gauche : Date et Message de bienvenue
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _todayStr,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Bonjour, $firstName',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- CET ÉLÉMENT POUSSE LE PROFIL TOUT À FAIT À DROITE ---
                    const Spacer(),

                    // Section Droite : Avatar du profil
                    GestureDetector(
                      onTap: () => Get.toNamed('/profile'),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            firstName.isNotEmpty
                                ? firstName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Sidi Bou Saïd, Tunisie',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Où souhaitez-vous\nvoyager ?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Get.toNamed('/searchtrain'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D1B4B), Color(0xFF1565C0)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.train_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Réserver un billet',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0D1B4B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Départ · Arrivée · Date',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF1565C0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Alerts ────────────────────────────────────────────────────────────────

  Widget _alertsSection() {
    return Obx(() {
      if (ctrl.isLoadingNews.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.blue1),
            ),
          ),
        );
      }

      final alerts = ctrl.visibleAlerts;

      if (alerts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.train_rounded,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Aucune alerte pour le moment. Tout roule !',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E7D32),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          // IMPORTANT: wrap PageView in a NotificationListener that stops
          // scroll notifications from bubbling up to the parent scroller.
          NotificationListener<ScrollNotification>(
            onNotification: (_) => true, // consume — don't let it bubble up
            child: SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _alertsPage,
                physics: const ClampingScrollPhysics(),
                itemCount: alerts.length,
                onPageChanged: (i) => setState(() => _alertIndex = i),
                itemBuilder: (context, i) => Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 20 : 8,
                    right: i == alerts.length - 1 ? 20 : 8,
                  ),
                  child: _alertCard(alerts[i]),
                ),
              ),
            ),
          ),
          if (alerts.length > 1) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(alerts.length, (i) {
                final active = i == _alertIndex;
                final color = _alertAccent(alerts[i].type);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? color : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ],
      );
    });
  }

  Widget _alertCard(Alert alert) {
    final accent = _alertAccent(alert.type);
    final bg = _alertBg(alert.type);
    final border = _alertBorder(alert.type);
    final icon = _alertIcon(alert.type);
    final tag = _alertTag(alert.type);
    final isDanger =
        alert.type == AlertType.danger || alert.type == AlertType.warning;

    return GestureDetector(
      onTap: () => _showAlertDetail(context, alert),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, color: accent, size: 12),
                              const SizedBox(width: 5),
                              Text(
                                tag,
                                style: GoogleFonts.poppins(
                                  color: accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (isDanger)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      alert.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0D1B4B),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        alert.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'd MMM yyyy',
                            'fr_FR',
                          ).format(alert.createdAt),
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showAlertDetail(context, alert),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Voir plus',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Place category filters ─────────────────────────────────────────────────

  Widget _placeCategoryFilters() {
    final categories = PlaceCategory.values;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final selected = _selectedPlaceCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedPlaceCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0D1B4B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                isAll ? 'Tous' : category!.label,
                style: GoogleFonts.poppins(
                  color: selected ? Colors.white : const Color(0xFF0D1B4B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Places list — loads ALL from PlaceController ───────────────────────────

  Widget _placesList() {
    return Obx(() {
      if (placeCtrl.isLoading.value) {
        return const SizedBox(
          height: 245,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.blue1),
          ),
        );
      }

      // Use ALL places (not just recommended/featured)
      var places = placeCtrl.places.isNotEmpty
          ? placeCtrl.places.toList()
          : placeCtrl.recommendedPlaces.toList();

      if (_selectedPlaceCategory != null) {
        places = places
            .where((p) => p.category == _selectedPlaceCategory)
            .toList();
      }

      // Show all — no .take() limit
      if (places.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Aucun lieu disponible.'),
        );
      }

      return SizedBox(
        height: 265,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: places.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) => _placeCard(places[i]),
        ),
      );
    });
  }

  Widget _placeCard(Place place) {
    return Container(
      width: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Multi-image gallery
            _ImageGallery(
              imageUrls: place.imageUrls,
              height: 265,
              placeholder: Container(
                color: const Color(0xFFE8EAF6),
                child: const Icon(
                  Icons.landscape_rounded,
                  color: Color(0xFF1565C0),
                  size: 42,
                ),
              ),
            ),

            // Dark gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Category badge (top-left, but leave room for image count)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  place.category.label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0D1B4B),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Bottom info
            Positioned(
              left: 12,
              right: 12,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white70,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          place.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        placeCtrl.selectPlace(place);
                        Get.toNamed('/placesdetail');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1565C0),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Voir détails',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Car category filters ───────────────────────────────────────────────────

  Widget _carCategoryFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: CarCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = CarCategory.values[i];
          return GestureDetector(
            onTap: () =>
                Get.toNamed('/services/cars', arguments: {'category': cat}),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(_carIcon(cat), color: const Color(0xFF1565C0), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF0D1B4B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _carIcon(CarCategory c) => switch (c) {
    CarCategory.economy => Icons.savings_rounded,
    CarCategory.comfort => Icons.airline_seat_recline_extra_rounded,
    CarCategory.sedan => Icons.directions_car_rounded,
    CarCategory.suv => Icons.airport_shuttle_rounded,
    CarCategory.luxury => Icons.diamond_rounded,
    CarCategory.minibus => Icons.directions_bus_rounded,
    CarCategory.electric => Icons.electric_bolt_rounded,
    CarCategory.van => Icons.local_shipping_rounded,
  };

  // ── Cars list — loads ALL from CarRentalController ─────────────────────────

  Widget _carsList() {
    return Obx(() {
      if (ctrl.isLoadingData.value || carCtrl.isLoading.value) {
        return const SizedBox(
          height: 240,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.blue1),
          ),
        );
      }

      // Prefer ALL cars from carCtrl, fallback to featured from accueil ctrl
      final cars = carCtrl.cars.isNotEmpty
          ? carCtrl.cars.toList()
          : ctrl.featuredCars.toList();

      if (cars.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Aucune voiture disponible.'),
        );
      }

      // --- CHANGED TO SLIDE EFFECT (PageView) ---
      return SizedBox(
        height:
            420, // Adjust this height depending on how tall your _carCard is
        child: PageView.builder(
          itemCount: cars.length,
          controller: PageController(
            viewportFraction: 0.88, // Shows a peek of the next/previous slide
            initialPage: 0,
          ),
          padEnds: false, // Starts the first item neatly aligned to the left
          itemBuilder: (context, index) {
            final car = cars[index];
            return Padding(
              // Adds horizontal padding between your sliding slides
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: _carCard(car),
            );
          },
        ),
      );
    });
  }

  Widget _carCard(CarRental car) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildCardImage(car), _buildCardDetails(car)],
      ),
    );
  }

  /// 1. Top Section: Multi-image gallery with status & price overlays
  Widget _buildCardImage(CarRental car) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(
        children: [
          _ImageGallery(
            imageUrls: car.imageUrls,
            height: 185,
            placeholder: Container(
              width: double.infinity,
              height: 185,
              color: const Color(0xFFE8EAF6),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Color(0xFF1565C0),
                size: 50,
              ),
            ),
          ),
          // Availability Status Tag
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: car.available
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                car.available ? 'Disponible' : 'Indisponible',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Price Tag
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B4B).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${car.pricePerDay.toStringAsFixed(0)} DT / jour',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Bottom Section: Car details, features info chips, and CTA button
  Widget _buildCardDetails(CarRental car) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Rating
          Row(
            children: [
              Expanded(
                child: Text(
                  car.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0D1B4B),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC107),
                size: 16,
              ),
              const SizedBox(width: 3),
              Text(
                car.rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0D1B4B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Agency Info & Location
          Row(
            children: [
              Icon(Icons.business_rounded, size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  car.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.location_on_rounded,
                size: 13,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  car.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Specifications Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _specChip(Icons.event_seat_rounded, '${car.seats} sièges'),
              _specChip(car.fuelType.icon, car.fuelType.label),
              _specChip(Icons.settings_rounded, car.transmission.label),
            ],
          ),
          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                carCtrl.selectCar(car);
                Get.toNamed('/carsdetail');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue2,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Voir détails',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _specChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4FF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF1565C0)),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF0D1B4B),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _sectionLabel(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      color: const Color(0xFF0D1B4B),
      fontSize: 17,
      fontWeight: FontWeight.w800,
    ),
  );

  Widget _seeAllBtn() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF0D1B4B),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      'Voir tout',
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
