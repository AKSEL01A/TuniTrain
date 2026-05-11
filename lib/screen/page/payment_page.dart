import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/panel_controller.dart';
import 'package:tuni_train/data/zone_pricing.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PanelController ctrl = Get.find<PanelController>();

  // ─── Timer (10 min countdown) ───
  static const int _totalSeconds = 10 * 60;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;

  // ─── Selected payment method ───
  String _selectedMethod = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
          Get.back();
          Get.snackbar(
            'Délai expiré',
            'Votre réservation a expiré. Réessayez.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.red,
            colorText: Colors.white,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_secondsLeft > 300) return AppColors.green;
    if (_secondsLeft > 120) return AppColors.sand;
    return AppColors.red;
  }

  // ─────────────────────────────
  // BUILD
  // ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildMethodSection(),
                  const SizedBox(height: 24),
                  _buildTermsRow(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─────────────────────────────
  // HEADER with timer
  // ─────────────────────────────
  Widget _buildHeader() {
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
          padding: const EdgeInsets.fromLTRB(4, 6, 16, 16),
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
                child: Text(
                  'Paiement',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // 🔥 COUNTDOWN TIMER
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _timerColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_rounded, color: _timerColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _timerText,
                      style: GoogleFonts.poppins(
                        color: _timerColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────
  // SUMMARY CARD
  // ─────────────────────────────
  Widget _buildSummaryCard() {
    final aller = ctrl.journeyAller.value;
    final retour = ctrl.journeyRetour.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.confirmation_num_rounded,
                color: AppColors.blue1,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Récapitulatif',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 10),

          if (aller != null) ...[
            _summaryJourneyRow(
              label: 'ALLER',
              color: const Color(0xFF1565C0),
              bg: const Color(0xFFE3F2FD),
              from: aller.fromStation,
              to: aller.toStation,
              dep: aller.departureTime,
              arr: aller.arrivalTime,
              basePrice: ZonePricing.calcBasePrice(
                aller.fromStation,
                aller.toStation,
              ),
            ),
          ],

          if (retour != null) ...[
            const SizedBox(height: 12),
            _summaryJourneyRow(
              label: 'RETOUR',
              color: const Color(0xFFE65100),
              bg: const Color(0xFFFFF3E0),
              from: retour.fromStation,
              to: retour.toStation,
              dep: retour.departureTime,
              arr: retour.arrivalTime,
              basePrice: ZonePricing.calcBasePrice(
                retour.fromStation,
                retour.toStation,
              ),
            ),
          ],

          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 10),

          _summaryRow(
            'Classe',
            ctrl.selectedClass.value == '1st' ? '1ère classe' : '2ème classe',
          ),
          _summaryRow('Offre', ctrl.selectedOffer.value),
          _summaryRow('Passagers', '${ctrl.totalPassengers}'),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Obx(
                () => Text(
                  ZonePricing.formatPrice(ctrl.totalPrice.value),
                  style: GoogleFonts.poppins(
                    color: AppColors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryJourneyRow({
    required String label,
    required Color color,
    required Color bg,
    required String from,
    required String to,
    required String dep,
    required String arr,
    required double basePrice,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                ZonePricing.formatPrice(basePrice),
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' / billet',
                style: GoogleFonts.poppins(
                  color: color.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  from,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: color,
                  size: 14,
                ),
              ),
              Expanded(
                child: Text(
                  to,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$dep  →  $arr',
            style: GoogleFonts.poppins(
              color: AppColors.blue3,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────
  // PAYMENT METHODS
  // ─────────────────────────────
  Widget _buildMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bluePale,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: AppColors.blue1,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Méthode de paiement',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _methodCard(
          id: 'google',
          icon: Icons.g_mobiledata_rounded,
          iconColor: const Color(0xFF4285F4),
          label: 'Google Pay',
          subtitle: 'Paiement rapide avec Google',
          badgeColor: const Color(0xFF34A853),
          badge: 'RAPIDE',
        ),
        const SizedBox(height: 10),
        _methodCard(
          id: 'apple',
          icon: Icons.apple_rounded,
          iconColor: Colors.black,
          label: 'Apple Pay',
          subtitle: 'Paiement sécurisé avec Apple',
          badgeColor: Colors.black,
          badge: 'SÉCURISÉ',
        ),
        const SizedBox(height: 10),
        _methodCard(
          id: 'card',
          icon: Icons.credit_card_rounded,
          iconColor: AppColors.blue1,
          label: 'Carte bancaire',
          subtitle: 'Visa · Mastercard · CIB',
          badgeColor: AppColors.blue3,
          badge: null,
        ),
      
      ],
    );
  }

  Widget _methodCard({
    required String id,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required Color badgeColor,
    String? badge,
  }) {
    final selected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.bluePale : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.blue1 : const Color(0xFFDDE6F5),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.blue1.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.poppins(
                              color: badgeColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.blue1 : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.blue1 : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Center(
      child: Text(
        '🔒  Paiement sécurisé · Données chiffrées SSL',
        style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 11),
      ),
    );
  }

  // ─────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _secondsLeft / _totalSeconds,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Expire dans $_timerText',
              style: GoogleFonts.poppins(
                color: _timerColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Obx(
                      () => Text(
                        ZonePricing.formatPrice(ctrl.totalPrice.value),
                        style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _onPay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _selectedMethod.isEmpty
                          ? [Colors.grey.shade300, Colors.grey.shade400]
                          : [AppColors.blue2, AppColors.blue1],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _selectedMethod.isEmpty
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.blue1.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              'Confirmer',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────
  // PAY ACTION
  // ─────────────────────────────
  void _onPay() async {
    if (_selectedMethod.isEmpty) {
      Get.snackbar(
        'Méthode requise',
        'Choisissez une méthode de paiement.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isProcessing = true);
    _timer?.cancel();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    // Navigate to QR ticket page
    Get.offNamed('/ticket-qr');
  }
}
