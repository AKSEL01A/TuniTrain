import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/purchase/panel_controller.dart';
import 'package:tuni_train/controller/purchase/subscription_controller.dart';
import 'package:tuni_train/controller/purchase/ticket_controller.dart';
import 'package:tuni_train/screen/page/purchase/subscription_success_page.dart'; // ← fix path if different

// ─────────────────────────────────────────────────────────────────────────────
//  PaymentPage
// ─────────────────────────────────────────────────────────────────────────────
enum PaymentType { ticket, subscription }

class PaymentPage extends StatefulWidget {
  final PaymentType type;
  const PaymentPage({super.key, this.type = PaymentType.ticket});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  PanelController? get panelCtrl {
    if (Get.isRegistered<PanelController>()) {
      return Get.find<PanelController>();
    }
    return null;
  }

  SubscriptionController get subCtrl => Get.find<SubscriptionController>();

  bool get _isSub => widget.type == PaymentType.subscription;

  double get _amount {
    if (_isSub) return subCtrl.currentPrice;

    final ctrl = panelCtrl;
    if (ctrl == null) return 0;

    return ctrl.totalPrice.value;
  }

  // ── Timer (5 min = 300 s) ──────────────────────────────────────────────
  static const int _totalSeconds = 300;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;
  late AnimationController _pulseCtrl;

  String _selectedMethod = ''; // 'wallet' | 'google' | 'apple' | 'card' | 'd17'
  bool _termsAccepted = false;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        _onTimeout();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _onTimeout() {
    Get.offAllNamed('/home');
    Get.snackbar(
      'Temps expiré',
      'Votre session de paiement a expiré.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }

  String get _timerLabel {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_remainingSeconds > 120) return AppColors.green;
    if (_remainingSeconds > 60) return AppColors.sand;
    return AppColors.red;
  }

  List<_PayMethod> get _methods => [
    _PayMethod(
      id: 'wallet',
      label: 'Mon Portefeuille',
      sublabel: 'Solde disponible',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.blue1,
      colorBg: AppColors.bluePale,
    ),
    _PayMethod(
      id: 'google',
      label: 'Google Pay',
      sublabel: 'Payer via Google',
      icon: Icons.g_mobiledata_rounded,
      color: const Color(0xFF4285F4),
      colorBg: const Color(0xFFE8F0FE),
    ),
    _PayMethod(
      id: 'apple',
      label: 'Apple Pay',
      sublabel: 'Payer via Apple',
      icon: Icons.apple_rounded,
      color: const Color(0xFF1C1C1E),
      colorBg: const Color(0xFFF2F2F7),
    ),
    _PayMethod(
      id: 'card',
      label: 'Carte Bancaire',
      sublabel: 'Visa / Mastercard',
      icon: Icons.credit_card_rounded,
      color: const Color(0xFF7B2FBE),
      colorBg: const Color(0xFFF3E8FF),
    ),
    _PayMethod(
      id: 'd17',
      label: 'D17',
      sublabel: 'Paiement mobile Tunisien',
      icon: Icons.smartphone_rounded,
      color: const Color(0xFFE65100),
      colorBg: const Color(0xFFFFF3E0),
    ),
  ];

  bool get _canPay => _selectedMethod.isNotEmpty && _termsAccepted && !_paying;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.blue1,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Paiement sécurisé',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                final pulse = _remainingSeconds <= 60;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: pulse
                        ? AppColors.red.withValues(
                            alpha: 0.15 + _pulseCtrl.value * 0.25,
                          )
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _timerColor.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_rounded, color: _timerColor, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        _timerLabel,
                        style: GoogleFonts.poppins(
                          color: _timerColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimerBar(),
            const SizedBox(height: 24),
            _buildOrderSummary(),
            const SizedBox(height: 28),
            _sectionLabel(
              icon: Icons.payment_rounded,
              label: 'Mode de paiement',
            ),
            const SizedBox(height: 12),
            ..._methods.map((m) => _buildMethodTile(m)),
            const SizedBox(height: 28),
            _buildTerms(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── TIMER BAR ──────────────────────────────────────────────────────
  Widget _buildTimerBar() {
    final progress = _remainingSeconds / _totalSeconds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: _timerColor, size: 14),
            const SizedBox(width: 6),
            Text(
              'Session réservée pendant ',
              style: GoogleFonts.poppins(
                color: AppColors.blue3,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _timerLabel,
              style: GoogleFonts.poppins(
                color: _timerColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFDDE6F5),
            valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
          ),
        ),
      ],
    );
  }

  // ── ORDER SUMMARY ──────────────────────────────────────────────────
  Widget _buildOrderSummary() {
    if (_isSub) {
      final total = subCtrl.currentPrice;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDE6F5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue1.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.card_membership_rounded,
                  color: AppColors.blue3,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Récapitulatif abonnement',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),
            _detailRow(Icons.confirmation_num_rounded, 'Abonnement SNCFT'),
            const SizedBox(height: 4),
            _detailRow(Icons.verified_rounded, 'QR code dynamique'),
            const SizedBox(height: 4),
            _detailRow(Icons.security_rounded, 'Paiement sécurisé'),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(3)} DT',
                  style: GoogleFonts.poppins(
                    color: AppColors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final ctrl = panelCtrl;

    if (ctrl == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDE6F5)),
        ),
        child: Text(
          'Aucune commande trouvée.',
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final allerJourney = ctrl.journeyAller.value;
    final retourJourney = ctrl.journeyRetour.value;
    final total = ctrl.totalPrice.value;
    final classLabel = ctrl.selectedClass.value == '1st'
        ? '1ère classe'
        : '2ème classe';
    final pax = ctrl.totalPassengers;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE6F5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.blue3,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Récapitulatif commande',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),
          if (allerJourney != null)
            _summaryRow(
              '🚆 Aller',
              '${allerJourney.fromStation} → ${allerJourney.toStation}',
              sub:
                  '${allerJourney.departureTime} · ${allerJourney.arrivalTime}',
              priceLabel: ctrl.allerPriceLabel,
            ),
          if (retourJourney != null) ...[
            const SizedBox(height: 8),
            _summaryRow(
              '🔁 Retour',
              '${retourJourney.fromStation} → ${retourJourney.toStation}',
              sub:
                  '${retourJourney.departureTime} · ${retourJourney.arrivalTime}',
              priceLabel: ctrl.retourPriceLabel,
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 10),
          _detailRow(Icons.airline_seat_recline_extra_rounded, classLabel),
          const SizedBox(height: 4),
          _detailRow(Icons.people_alt_rounded, '$pax passager(s)'),
          const SizedBox(height: 4),
          _detailRow(Icons.local_offer_rounded, ctrl.selectedOffer.value),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${total.toStringAsFixed(3)} DT',
                style: GoogleFonts.poppins(
                  color: AppColors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    String? sub,
    required String priceLabel,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sub != null)
                Text(
                  sub,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        Text(
          priceLabel,
          style: GoogleFonts.poppins(
            color: AppColors.sand,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blue3, size: 13),
        const SizedBox(width: 7),
        Text(
          label,
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
        ),
      ],
    );
  }

  // ── METHOD TILE ────────────────────────────────────────────────────
  Widget _buildMethodTile(_PayMethod m) {
    final selected = _selectedMethod == m.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = m.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? m.colorBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? m.color : const Color(0xFFDDE6F5),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: m.color.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? m.color.withValues(alpha: 0.15)
                    : const Color(0xFFF2F5FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                m.icon,
                color: selected ? m.color : Colors.grey.shade400,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.label,
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    m.sublabel,
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
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? m.color : Colors.transparent,
                border: Border.all(
                  color: selected ? m.color : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── TERMS ──────────────────────────────────────────────────────────
  Widget _buildTerms() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _termsAccepted ? AppColors.greenBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _termsAccepted
              ? AppColors.green.withValues(alpha: 0.4)
              : const Color(0xFFDDE6F5),
          width: _termsAccepted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel_rounded, color: AppColors.blue3, size: 15),
              const SizedBox(width: 8),
              Text(
                'Conditions de vente',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => setState(() => _termsAccepted = !_termsAccepted),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _termsAccepted
                        ? AppColors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: _termsAccepted
                          ? AppColors.green
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: _termsAccepted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 13,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 12,
                      ),
                      children: [
                        const TextSpan(text: 'J\'ai lu et j\'accepte '),
                        TextSpan(
                          text: 'les conditions générales de vente',
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(
                          text:
                              ' ainsi que la politique de remboursement de la SNCFT.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ─────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_canPay && !_paying)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.sand,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _selectedMethod.isEmpty && !_termsAccepted
                          ? 'Choisissez un mode de paiement et acceptez les conditions.'
                          : _selectedMethod.isEmpty
                          ? 'Choisissez un mode de paiement.'
                          : 'Acceptez les conditions pour continuer.',
                      style: GoogleFonts.poppins(
                        color: AppColors.sand,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total à payer',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        '${_amount.toStringAsFixed(3)} DT',
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
                onTap: _canPay ? _onPayPressed : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _canPay
                          ? [AppColors.blue2, AppColors.blue1]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _canPay
                        ? [
                            BoxShadow(
                              color: AppColors.blue1.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: _paying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Payer',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_rounded,
                color: AppColors.green,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                'Paiement 100% sécurisé · Chiffrement SSL',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ON PAY — saves real ticket + payment to Firestore (no fake delay)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onPayPressed() async {
    setState(() => _paying = true);
    _timer?.cancel();

    try {
      if (_isSub) {
        // subscription → save abonnement (also starts QR rotation in ctrl)
        await Get.find<SubscriptionController>().purchase();
      } else {
        // ticket → save ticket + payment
        final ticketCtrl = Get.find<TicketController>();
        ticketCtrl.paymentMethod = _selectedMethod;
        await ticketCtrl.saveTicket();
        await ticketCtrl.savePayment();
      }
    } catch (e) {
      debugPrint('🚨 Payment flow error: $e');
      if (!mounted) return;
      setState(() => _paying = false);
      _startTimer();
      Get.snackbar(
        'Erreur',
        'Le paiement a échoué. Veuillez réessayer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
      return;
    }

    if (!mounted) return;
    setState(() => _paying = false);

    if (_isSub) {
      Get.off(() => const SubscriptionSuccessPage());
    } else {
      Get.offAllNamed(
        '/payment_success',
        arguments: {'paymentMethod': _selectedMethod},
      );
    }
  }

  // ── HELPERS ────────────────────────────────────────────────────────
  Widget _sectionLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.bluePale,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.blue1, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static const String _termsText = '''

  ''';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Data class for payment methods (UI only)
// ─────────────────────────────────────────────────────────────────────────────
class _PayMethod {
  final String id;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final Color colorBg;

  const _PayMethod({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.colorBg,
  });
}
