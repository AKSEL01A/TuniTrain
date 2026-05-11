import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/panel_controller.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────
  late final AnimationController _checkCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _confettiCtrl;
  late final AnimationController _pulseCtrl;

  // ── Animations ─────────────────────────────────────────────────────────
  late final Animation<double> _checkAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  // ── Confetti particles ─────────────────────────────────────────────────
  final List<_Particle> _particles = List.generate(
    40,
    (i) => _Particle(seed: i),
  );

  PanelController? _panelCtrl;

  @override
  void initState() {
    super.initState();

    // Try to get panel controller (may not exist if navigated directly)
    try {
      _panelCtrl = Get.find<PanelController>();
    } catch (_) {}

    // ── Check circle draw animation ─────────────────────────────────────
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkAnim = CurvedAnimation(
      parent: _checkCtrl,
      curve: Curves.easeOutCubic,
    );

    // ── Scale bounce for the circle ─────────────────────────────────────
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);

    // ── Slide-up for the card below ─────────────────────────────────────
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = CurvedAnimation(
      parent: _slideCtrl,
      curve: Curves.easeOutCubic,
    );
    _fadeAnim = _slideAnim;

    // ── Confetti ────────────────────────────────────────────────────────
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ── Pulse on circle ─────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // ── Sequence ────────────────────────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _confettiCtrl.forward();
    _scaleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _checkCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _scaleCtrl.dispose();
    _slideCtrl.dispose();
    _confettiCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Ticket info from PanelController ────────────────────────────────────
  String get _fromStation => _panelCtrl?.journeyAller.value?.fromStation ?? '—';
  String get _toStation => _panelCtrl?.journeyAller.value?.toStation ?? '—';
  String get _departureTime =>
      _panelCtrl?.journeyAller.value?.departureTime ?? '--:--';
  String get _arrivalTime =>
      _panelCtrl?.journeyAller.value?.arrivalTime ?? '--:--';
  bool get _isRoundTrip => _panelCtrl?.hasRetour ?? false;
  String get _returnFrom => _panelCtrl?.journeyRetour.value?.fromStation ?? '—';
  String get _returnTo => _panelCtrl?.journeyRetour.value?.toStation ?? '—';
  String get _returnDep =>
      _panelCtrl?.journeyRetour.value?.departureTime ?? '--:--';
  double get _totalPrice => _panelCtrl?.totalPrice.value ?? 0.0;
  int get _passengers => _panelCtrl?.totalPassengers ?? 1;
  String get _ticketClass =>
      _panelCtrl?.selectedClass.value == '1st' ? '1ère CL' : '2ème CL';

  // Fake ticket code for display
  String get _ticketCode {
    final now = DateTime.now();
    return 'TT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(1000 + now.millisecond % 9000)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Stack(
        children: [
          // ── Confetti layer ─────────────────────────────────────────────
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiCtrl.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // ── Success circle ──────────────────────────────────────
                  _buildSuccessCircle(),

                  const SizedBox(height: 28),

                  // ── Title + subtitle ────────────────────────────────────
                  AnimatedBuilder(
                    animation: _slideAnim,
                    builder: (_, child) => Opacity(
                      opacity: _fadeAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - _slideAnim.value)),
                        child: child,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Paiement réussi !',
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Vos billets ont été confirmés.\nBon voyage ! 🚆',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.blue3,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Ticket card ──────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _slideAnim,
                    builder: (_, child) => Opacity(
                      opacity: _fadeAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - _slideAnim.value)),
                        child: child,
                      ),
                    ),
                    child: _buildTicketCard(),
                  ),

                  const SizedBox(height: 20),

                  // ── Info chips row ───────────────────────────────────────
                  AnimatedBuilder(
                    animation: _slideAnim,
                    builder: (_, child) => Opacity(
                      opacity: _fadeAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 70 * (1 - _slideAnim.value)),
                        child: child,
                      ),
                    ),
                    child: _buildInfoChips(),
                  ),

                  const SizedBox(height: 32),

                  // ── Action buttons ───────────────────────────────────────
                  AnimatedBuilder(
                    animation: _slideAnim,
                    builder: (_, child) => Opacity(
                      opacity: _fadeAnim.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 90 * (1 - _slideAnim.value)),
                        child: child,
                      ),
                    ),
                    child: _buildActions(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SUCCESS CIRCLE  (animated check)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSuccessCircle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnim, _pulseCtrl, _checkAnim]),
      builder: (_, __) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring
                Transform.scale(
                  scale: 1.0 + _pulseCtrl.value * 0.12,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.green.withOpacity(
                        0.08 + _pulseCtrl.value * 0.06,
                      ),
                    ),
                  ),
                ),

                // Outer ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.withOpacity(0.15),
                  ),
                ),

                // Inner filled circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x5543A047),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                ),

                // Animated checkmark
                CustomPaint(
                  size: const Size(48, 48),
                  painter: _CheckPainter(progress: _checkAnim.value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TICKET CARD  (train ticket style)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Line badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.train_rounded,
                        color: Colors.white70,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'SNCFT',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ticket code
                Text(
                  _ticketCode,
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),

                // Confirmed badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.green.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.green,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Confirmé',
                        style: GoogleFonts.poppins(
                          color: AppColors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Route row – ALLER
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
            child: Row(
              children: [
                // FROM
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _departureTime,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _fromStation,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Center arrow
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sand.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ALLER',
                          style: GoogleFonts.poppins(
                            color: AppColors.sand,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white38,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 1,
                            color: Colors.white24,
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white54,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // TO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _arrivalTime,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _toStation,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Return leg (if round-trip)
          if (_isRoundTrip) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sand.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'RETOUR',
                        style: GoogleFonts.poppins(
                          color: AppColors.sand,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$_returnDep · $_returnFrom → $_returnTo',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Dashed divider with notches
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.bgPage,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, c) {
                      final n = (c.maxWidth / 10).floor();
                      return Row(
                        children: List.generate(
                          n,
                          (_) => Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.20),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.bgPage,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Bottom chips
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ticketChip(
                  Icons.people_alt_rounded,
                  '$_passengers passager${_passengers > 1 ? 's' : ''}',
                ),
                _vDivider(),
                _ticketChip(
                  Icons.airline_seat_recline_extra_rounded,
                  _ticketClass,
                ),
                _vDivider(),
                _ticketChip(
                  Icons.monetization_on_rounded,
                  '${_totalPrice.toStringAsFixed(3)} DT',
                ),
                _vDivider(),
                _ticketChip(
                  _isRoundTrip
                      ? Icons.swap_horiz_rounded
                      : Icons.arrow_right_alt_rounded,
                  _isRoundTrip ? 'A/R' : 'Simple',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketChip(IconData icon, String label) => Row(
    children: [
      Icon(icon, color: Colors.white54, size: 13),
      const SizedBox(width: 5),
      Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _vDivider() =>
      Container(width: 1, height: 16, color: Colors.white.withOpacity(0.15));

  // ══════════════════════════════════════════════════════════════════════════
  //  INFO CHIPS ROW (below ticket)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildInfoChips() {
    return Row(
      children: [
        Expanded(
          child: _infoTile(
            icon: Icons.shield_rounded,
            iconColor: AppColors.green,
            iconBg: AppColors.greenBg,
            label: 'Paiement sécurisé',
            sub: 'Chiffrement SSL',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoTile(
            icon: Icons.email_rounded,
            iconColor: AppColors.blue1,
            iconBg: AppColors.bluePale,
            label: 'Billet envoyé',
            sub: 'Par email & SMS',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoTile(
            icon: Icons.qr_code_rounded,
            iconColor: AppColors.sand,
            iconBg: AppColors.sandBg,
            label: 'QR Code',
            sub: 'Prêt à scanner',
          ),
        ),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildActions() {
    return Column(
      children: [
        // Primary: View my tickets
        GestureDetector(
          onTap: () => Get.offAllNamed('/my-journeys'),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.blue2, AppColors.blue1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue1.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.confirmation_number_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Voir mes billets',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary: Back home
        GestureDetector(
          onTap: () => Get.offAllNamed('/home'),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDE6F5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue1.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.home_rounded,
                  color: AppColors.blue1,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Retour à l\'accueil',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Tertiary: Book another
        GestureDetector(
          onTap: () => Get.offAllNamed('/search'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.blue3,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                'Réserver un autre trajet',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.blue3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHECKMARK PAINTER  – draws the tick progressively
// ─────────────────────────────────────────────────────────────────────────────
class _CheckPainter extends CustomPainter {
  final double progress;

  const _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Check path: from (8,24) → (20,34) → (40,14)
    final path = Path()
      ..moveTo(size.width * 0.17, size.height * 0.50)
      ..lineTo(size.width * 0.42, size.height * 0.71)
      ..lineTo(size.width * 0.83, size.height * 0.29);

    final metrics = path.computeMetrics().first;
    final extracted = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(extracted, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONFETTI
// ─────────────────────────────────────────────────────────────────────────────
class _Particle {
  late final double x; // 0–1 of screen width
  late final double speed; // fall speed
  late final double size;
  late final Color color;
  late final double rotation;
  late final double rotSpeed;
  late final double wobble;

  static const _colors = [
    Color(0xFF1565C0),
    Color(0xFF43A047),
    Color(0xFFE65100),
    Color(0xFFFDD835),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFFE53935),
  ];

  _Particle({required int seed}) {
    final rng = math.Random(seed * 7919);
    x = rng.nextDouble();
    speed = 0.3 + rng.nextDouble() * 0.7;
    size = 5 + rng.nextDouble() * 8;
    color = _colors[rng.nextInt(_colors.length)];
    rotation = rng.nextDouble() * math.pi * 2;
    rotSpeed = (rng.nextDouble() - 0.5) * 8;
    wobble = rng.nextDouble() * math.pi * 2;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress; // 0→1

  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    for (final p in particles) {
      final t = (progress * (1 / p.speed)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final y = -20.0 + size.height * 1.2 * t;
      final x = p.x * size.width + math.sin(t * math.pi * 3 + p.wobble) * 28;
      final rot = p.rotation + p.rotSpeed * t;

      // Fade out near the bottom
      final alpha = (1.0 - (t - 0.7).clamp(0.0, 0.3) / 0.3).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withOpacity(alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      // Alternate between rect and circle
      if (particles.indexOf(p) % 2 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.5,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
