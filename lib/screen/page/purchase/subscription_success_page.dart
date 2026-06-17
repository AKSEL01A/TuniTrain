import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/purchase/subscription_controller.dart';

class SubscriptionSuccessPage extends StatefulWidget {
  const SubscriptionSuccessPage({super.key});

  @override
  State<SubscriptionSuccessPage> createState() =>
      _SubscriptionSuccessPageState();
}

class _SubscriptionSuccessPageState extends State<SubscriptionSuccessPage>
    with SingleTickerProviderStateMixin {
  final SubscriptionController ctrl = Get.find<SubscriptionController>();

  late AnimationController _qrAnim;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _qrAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..addListener(() {
            final s = (30 - (_qrAnim.value * 30)).ceil();
            if (s != _secondsLeft && mounted) setState(() => _secondsLeft = s);
          })
          ..addStatusListener((st) {
            if (st == AnimationStatus.completed) {
              _qrAnim.forward(from: 0);
              setState(() => _secondsLeft = 30);
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _qrAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final isPending = ctrl.isStudent.value;
            return Column(
              children: [
                const SizedBox(height: 16),
                _card(isPending),
                const SizedBox(height: 20),
                isPending ? _pendingBox() : _qrBox(),
                const SizedBox(height: 24),
                _homeButton(),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Abonnement card ────────────────────────────────────────────────
  Widget _card(bool isPending) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0D2B6B), Color(0xFF1565C0), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: AppColors.blue1.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        _blob(top: -20, right: -20, size: 120, alpha: 0.05),
        _blob(bottom: -30, left: -10, size: 100, alpha: 0.04),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.train_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TuniTrain',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _statusChip(isPending),
                ],
              ),
              const SizedBox(height: 20),
              _userRow(),
              const SizedBox(height: 18),
              Divider(color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _info(
                      'Type',
                      ctrl.typeName,
                      Icons.calendar_today_rounded,
                    ),
                  ),
                  Expanded(
                    child: _info(
                      'Durée',
                      ctrl.durationLabel,
                      Icons.schedule_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _routeBox(),
              const SizedBox(height: 14),
              _priceRefRow(),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double alpha,
  }) => Positioned(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    ),
  );

  Widget _statusChip(bool isPending) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: (isPending ? AppColors.sand : AppColors.green).withValues(
        alpha: 0.25,
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: (isPending ? AppColors.sand : AppColors.green).withValues(
          alpha: 0.5,
        ),
      ),
    ),
    child: Text(
      isPending ? 'En attente' : 'Actif',
      style: GoogleFonts.poppins(
        color: isPending ? AppColors.sand : AppColors.green,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _userRow() => Row(
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: ctrl.userPhotoBase64.value.isNotEmpty
            ? ClipOval(
                child: Image.memory(
                  base64Decode(ctrl.userPhotoBase64.value),
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.person_rounded, color: Colors.white70, size: 28),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ctrl.firstNameCtrl.text} ${ctrl.lastNameCtrl.text}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              ctrl.emailCtrl.text,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
            ),
            if (ctrl.isStudent.value && ctrl.universityCtrl.text.isNotEmpty)
              Text(
                ctrl.universityCtrl.text,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _routeBox() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.trip_origin_rounded, color: Colors.white70, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            ctrl.fromStation.value?.name ?? '',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white38,
          size: 14,
        ),
        Expanded(
          child: Text(
            ctrl.toStation.value?.name ?? '',
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
      ],
    ),
  );

  Widget _priceRefRow() {
    final id = ctrl.savedSubId.value;
    return Row(
      children: [
        Text(
          '${ctrl.currentPrice.toStringAsFixed(2)} DT',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Réf.',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 9),
            ),
            Text(
              id.length > 12 ? id.substring(0, 12) : id,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _info(String label, String value, IconData icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
      ),
      const SizedBox(height: 3),
      Row(
        children: [
          Icon(icon, color: Colors.white60, size: 12),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );

  // ── QR box ─────────────────────────────────────────────────────────
  Widget _qrBox() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.blue1,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'QR Code de contrôle',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Présentez ce code au contrôleur',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 11),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.blue1.withValues(alpha: 0.15),
              ),
            ),
            child: ctrl.liveQrCode.value.isEmpty
                ? const SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(color: AppColors.blue1),
                  )
                : QrImageView(
                    data: ctrl.liveQrCode.value,
                    version: QrVersions.auto,
                    size: 180,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        _qrCountdown(),
        const SizedBox(height: 12),
        _antifraudBadge(),
      ],
    ),
  );

  Widget _qrCountdown() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedBuilder(
        animation: _qrAnim,
        builder: (_, __) => SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1 - _qrAnim.value,
                strokeWidth: 3,
                backgroundColor: const Color(0xFFE8EEF7),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _secondsLeft <= 5 ? AppColors.red : AppColors.blue1,
                ),
              ),
              Text(
                '$_secondsLeft',
                style: GoogleFonts.poppins(
                  color: _secondsLeft <= 5 ? AppColors.red : AppColors.blue1,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),
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
            'Le QR change toutes les 30 secondes',
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 10),
          ),
        ],
      ),
    ],
  );

  Widget _antifraudBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.green.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shield_rounded, color: AppColors.green, size: 14),
        const SizedBox(width: 6),
        Text(
          'Code sécurisé anti-fraude',
          style: GoogleFonts.poppins(
            color: AppColors.green,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  // ── Pending box ────────────────────────────────────────────────────
  Widget _pendingBox() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.sand.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.sand.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        const Icon(
          Icons.hourglass_top_rounded,
          color: AppColors.sand,
          size: 36,
        ),
        const SizedBox(height: 10),
        Text(
          'En attente de validation',
          style: GoogleFonts.poppins(
            color: AppColors.sand,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'L\'administration vérifiera votre carte étudiante.\nVous recevrez votre QR code dès validation.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: AppColors.sand, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _homeButton() => GestureDetector(
    onTap: () {
      ctrl.reset();
      Get.offAllNamed('/home');
    },
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blue2, AppColors.blue1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Retour à l\'accueil',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}
