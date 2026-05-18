import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tuni_train/const/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────
class AbonnementTabController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMsg = ''.obs;

  final RxList<Map<String, dynamic>> abonnements = <Map<String, dynamic>>[].obs;

  final RxString activeSubId = ''.obs;
  final RxString liveQrCode = ''.obs;
  Timer? _qrTimer;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _qrTimer?.cancel();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;
    errorMsg.value = '';

    try {
      final user = _auth.currentUser;

      if (user == null) {
        debugPrint('🚨 AbonnementTab: user not logged in');
        hasError.value = true;
        errorMsg.value = 'Utilisateur non connecté.';
        isLoading.value = false;
        return;
      }

      debugPrint('🔄 Loading abonnements for uid: ${user.uid}');

      // ⚠️  NO orderBy → avoids composite-index error.
      //     Sorting is done client-side below.
      final snap = await _db
          .collection('abonnements')
          .where('userId', isEqualTo: user.uid)
          .get();

      debugPrint('📦 Raw docs returned: ${snap.docs.length}');

      // Log field names of first doc to help debug mismatches
      if (snap.docs.isNotEmpty) {
        debugPrint(
          '🗂 First doc keys: ${snap.docs.first.data().keys.toList()}',
        );
        debugPrint('🗂 First doc data: ${snap.docs.first.data()}');
      }

      final list = snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data());
        m['id'] = d.id;
        return m;
      }).toList();

      // Sort by createdAt descending
      list.sort((a, b) {
        final ta = (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final tb = (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      });

      abonnements.value = list;
      debugPrint('✅ Abonnements loaded: ${list.length}');
    } catch (e, st) {
      debugPrint('🚨 AbonnementTab error: $e');
      debugPrint('$st');
      hasError.value = true;
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── QR ────────────────────────────────────────────────────────────────────
  void showQr(String subId, String baseToken) {
    activeSubId.value = subId;
    _generateQr(subId, baseToken);
    _qrTimer?.cancel();
    _qrTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _generateQr(subId, baseToken);
    });
  }

  void hideQr() {
    _qrTimer?.cancel();
    activeSubId.value = '';
    liveQrCode.value = '';
  }

  void _generateQr(String subId, String baseToken) {
    final slot = DateTime.now().millisecondsSinceEpoch ~/ 30000;
    final payload = '$subId|$baseToken|$slot';
    final hash = payload.hashCode.abs().toRadixString(16).padLeft(8, '0');
    liveQrCode.value = 'TUNITRAIN|$subId|$slot|$hash';
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String statusLabel(String s) {
    switch (s) {
      case 'active':
        return 'Actif';
      case 'pending':
        return 'En attente';
      case 'expired':
        return 'Expiré';
      case 'blocked':
        return 'Bloqué';
      default:
        return s;
    }
  }

  Color statusColor(String s) {
    switch (s) {
      case 'active':
        return AppColors.green;
      case 'pending':
        return AppColors.sand;
      case 'expired':
        return AppColors.blue3;
      case 'blocked':
        return AppColors.red;
      default:
        return AppColors.blue3;
    }
  }

  IconData statusIcon(String s) {
    switch (s) {
      case 'active':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'expired':
        return Icons.event_busy_rounded;
      case 'blocked':
        return Icons.block_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String formatDate(Timestamp? ts) {
    if (ts == null) return '—';
    final dt = ts.toDate();
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class MyJourneyAbonnementTab extends StatelessWidget {
  const MyJourneyAbonnementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AbonnementTabController(), permanent: false);

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blue1),
        );
      }

      if (ctrl.hasError.value) {
        return _ErrorState(message: ctrl.errorMsg.value, onRetry: ctrl.load);
      }

      if (ctrl.abonnements.isEmpty) {
        return _EmptyState();
      }

      return RefreshIndicator(
        onRefresh: ctrl.load,
        color: AppColors.blue1,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: ctrl.abonnements.length,
          itemBuilder: (_, i) =>
              _AbonnementItem(ctrl: ctrl, data: ctrl.abonnements[i]),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ABONNEMENT ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _AbonnementItem extends StatelessWidget {
  final AbonnementTabController ctrl;
  final Map<String, dynamic> data;
  const _AbonnementItem({required this.ctrl, required this.data});

  @override
  Widget build(BuildContext context) {
    final subId = data['id'] as String? ?? '';
    final status = data['status'] as String? ?? 'pending';
    final isActive = status == 'active';
    final baseToken = data['qrBaseToken'] as String? ?? subId;
    final photo = data['photoBase64'] as String? ?? '';
    final label = data['label'] as String? ?? data['type'] as String? ?? '';
    final from = data['fromStation'] as String? ?? '—';
    final to = data['toStation'] as String? ?? '—';
    final lineName = data['lineName'] as String? ?? '';
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final isStudent = data['isStudent'] as bool? ?? false;
    final university = data['university'] as String? ?? '';
    final endDate = ctrl.formatDate(data['endDate'] as Timestamp?);
    final startDate = ctrl.formatDate(data['startDate'] as Timestamp?);

    return Obx(() {
      final showingQr = ctrl.activeSubId.value == subId;

      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── MAIN CARD ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [const Color(0xFF0A2463), const Color(0xFF1565C0)]
                      : [const Color(0xFF3A3A3A), const Color(0xFF606060)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: showingQr
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand + status
                        Row(
                          children: [
                            const Icon(
                              Icons.train_rounded,
                              color: Colors.white70,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TuniTrain',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ctrl
                                    .statusColor(status)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ctrl
                                      .statusColor(status)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    ctrl.statusIcon(status),
                                    color: ctrl.statusColor(status),
                                    size: 11,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    ctrl.statusLabel(status),
                                    style: GoogleFonts.poppins(
                                      color: ctrl.statusColor(status),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Photo + name + price
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 2,
                                ),
                              ),
                              child: photo.isNotEmpty
                                  ? ClipOval(
                                      child: Image.memory(
                                        base64Decode(photo),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(
                                              Icons.person_rounded,
                                              color: Colors.white70,
                                              size: 24,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$firstName $lastName'.trim().isEmpty
                                        ? 'Abonné'
                                        : '$firstName $lastName',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (isStudent && university.isNotEmpty)
                                    Text(
                                      university,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white54,
                                        fontSize: 10,
                                      ),
                                    ),
                                  if (isStudent)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.blue1.withValues(
                                          alpha: 0.3,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Étudiant',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${price.toStringAsFixed(2)} DT',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (label.isNotEmpty)
                                  Text(
                                    label,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        Divider(color: Colors.white.withValues(alpha: 0.12)),
                        const SizedBox(height: 10),

                        // Route
                        Row(
                          children: [
                            if (lineName.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  lineName,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            const Icon(
                              Icons.trip_origin_rounded,
                              color: Colors.white54,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                from,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white38,
                                size: 12,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                to,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white54,
                              size: 10,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Dates + QR button
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (startDate != '—')
                                  _dateRow(
                                    Icons.play_arrow_rounded,
                                    'Début',
                                    startDate,
                                  ),
                                if (startDate != '—') const SizedBox(height: 4),
                                _dateRow(
                                  Icons.event_rounded,
                                  'Expire',
                                  endDate,
                                ),
                              ],
                            ),
                            const Spacer(),

                            if (isActive)
                              GestureDetector(
                                onTap: () => showingQr
                                    ? ctrl.hideQr()
                                    : ctrl.showQr(subId, baseToken),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: showingQr
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: showingQr ? 0.5 : 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        showingQr
                                            ? Icons.close_rounded
                                            : Icons.qr_code_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        showingQr ? 'Masquer' : 'Afficher QR',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'QR non disponible',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (showingQr) _QrPanel(ctrl: ctrl, subId: subId),
          ],
        ),
      );
    });
  }

  Widget _dateRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, color: Colors.white38, size: 11),
      const SizedBox(width: 4),
      Text(
        '$label: ',
        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 9),
      ),
      Text(
        value,
        style: GoogleFonts.poppins(
          color: Colors.white60,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// QR PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _QrPanel extends StatefulWidget {
  final AbonnementTabController ctrl;
  final String subId;
  const _QrPanel({required this.ctrl, required this.subId});

  @override
  State<_QrPanel> createState() => _QrPanelState();
}

class _QrPanelState extends State<_QrPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..addListener(() {
            final s = (30 - (_anim.value * 30)).ceil().clamp(0, 30);
            if (s != _secondsLeft && mounted) setState(() => _secondsLeft = s);
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _anim.forward(from: 0);
              if (mounted) setState(() => _secondsLeft = 30);
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Text(
          'QR Code de contrôle',
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Présentez ce code au contrôleur',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 11),
        ),
        const SizedBox(height: 16),

        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: widget.ctrl.liveQrCode.value.isEmpty
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 180,
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.blue1),
                    ),
                  )
                : Container(
                    key: ValueKey(widget.ctrl.liveQrCode.value),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.blue1.withValues(alpha: 0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blue1.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: widget.ctrl.liveQrCode.value,
                      version: QrVersions.auto,
                      size: 180,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _anim,
              builder: (_, _) => SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1 - _anim.value,
                      strokeWidth: 3,
                      backgroundColor: const Color(0xFFE8EEF7),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _secondsLeft <= 5 ? AppColors.red : AppColors.blue1,
                      ),
                    ),
                    Text(
                      '$_secondsLeft',
                      style: GoogleFonts.poppins(
                        color: _secondsLeft <= 5
                            ? AppColors.red
                            : AppColors.blue1,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualisation automatique',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Renouvellement toutes les 30 secondes',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_rounded,
                color: AppColors.green,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Code sécurisé — valide 30 secondes',
                style: GoogleFonts.poppins(
                  color: AppColors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.blue1.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_membership_rounded,
              color: AppColors.blue1,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun abonnement',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Souscrivez à un abonnement\npour voyager librement.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 13),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Get.toNamed('/subscription'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue2, AppColors.blue1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue1.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Souscrire un abonnement',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.red,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message.isNotEmpty
                ? message
                : 'Vérifiez votre connexion et réessayez.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.blue1,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Réessayer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
