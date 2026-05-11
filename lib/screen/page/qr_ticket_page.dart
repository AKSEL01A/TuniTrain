import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/panel_controller.dart';
import 'package:tuni_train/models/train_journey.dart';
import 'package:tuni_train/data/zone_pricing.dart';

class QrTicketPage extends StatelessWidget {
  QrTicketPage({super.key});

  final PanelController ctrl = Get.find<PanelController>();

  // Generate a unique booking reference
  String get _bookingRef {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final ref = _bookingRef; // stable during build
    final aller = ctrl.journeyAller.value;
    final retour = ctrl.journeyRetour.value;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                children: [
                  _buildSuccessBanner(),
                  const SizedBox(height: 20),
                  if (aller != null)
                    _buildTicket(
                      journey: aller,
                      label: 'ALLER',
                      labelColor: const Color(0xFF1565C0),
                      labelBg: const Color(0xFFE3F2FD),
                      qrData: _buildQrData(aller, ref, 'ALLER'),
                      bookingRef: ref,
                    ),
                  if (retour != null) ...[
                    const SizedBox(height: 20),
                    _buildTicket(
                      journey: retour,
                      label: 'RETOUR',
                      labelColor: const Color(0xFFE65100),
                      labelBg: const Color(0xFFFFF3E0),
                      qrData: _buildQrData(retour, ref, 'RETOUR'),
                      bookingRef: ref,
                    ),
                  ],
                  const SizedBox(height: 28),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildQrData(TrainJourney j, String ref, String type) {
    return [
      'REF:$ref',
      'TYPE:$type',
      'FROM:${j.fromStation}',
      'TO:${j.toStation}',
      'DEP:${j.departureTime}',
      'ARR:${j.arrivalTime}',
      'TRAIN:${j.trainId}',
      'PAX:${ctrl.totalPassengers}',
      'PRICE:${ZonePricing.formatPrice(ctrl.totalPrice.value)}',
    ].join('|');
  }

  // ─────────────────────────────
  // HEADER
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
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Votre billet',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Get.offAllNamed('/home'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.home_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text('Accueil',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
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

  // ─────────────────────────────
  // SUCCESS BANNER
  // ─────────────────────────────
  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.green, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paiement confirmé !',
                    style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  'Vos billets sont prêts. Présentez le QR code au contrôleur.',
                  style: GoogleFonts.poppins(
                      color: AppColors.green.withOpacity(0.8),
                      fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────
  // TICKET CARD WITH QR
  // ─────────────────────────────
  Widget _buildTicket({
    required TrainJourney journey,
    required String label,
    required Color labelColor,
    required Color labelBg,
    required String qrData,
    required String bookingRef,
  }) {
    final basePrice = ZonePricing.calcBasePrice(
        journey.fromStation, journey.toStation);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.blue1, AppColors.blue2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: labelColor.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(label,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5)),
                ),
                const Spacer(),
                const Icon(Icons.train_rounded,
                    color: Colors.white54, size: 14),
                const SizedBox(width: 5),
                Text('Train #${journey.trainId}',
                    style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // ── Route ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(journey.departureTime,
                          style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 28,
                              fontWeight: FontWeight.w900)),
                      Text(journey.fromStation,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      ctrl.searchCtrl.calcDuration(
                          journey.departureTime, journey.arrivalTime),
                      style: GoogleFonts.poppins(
                          color: AppColors.sand,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: AppColors.blue3,
                                shape: BoxShape.circle)),
                        Container(
                            width: 30,
                            height: 1,
                            color: const Color(0xFFB0C8E8)),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.blue2, size: 16),
                        Container(
                            width: 30,
                            height: 1,
                            color: const Color(0xFFB0C8E8)),
                        Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: AppColors.blue3,
                                shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ctrl.searchCtrl.getStopsText(journey),
                      style: GoogleFonts.poppins(
                          color: AppColors.blue3, fontSize: 9),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(journey.arrivalTime,
                          style: GoogleFonts.poppins(
                              color: AppColors.blue1,
                              fontSize: 28,
                              fontWeight: FontWeight.w900)),
                      Text(journey.toStation,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(
                              color: AppColors.blue3,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Dashed divider ──────────────────────────
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        color: AppColors.bgPage, shape: BoxShape.circle)),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, c) {
                      final n = (c.maxWidth / 12).floor();
                      return Row(
                        children: List.generate(
                          n,
                          (_) => Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFDDE6F5),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        color: AppColors.bgPage, shape: BoxShape.circle)),
              ],
            ),
          ),

          // ── QR Code + Info ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // QR Code
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDDE6F5)),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 110,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.blue1,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.blue1,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.confirmation_num_rounded,
                          'Réf.', bookingRef),
                      const SizedBox(height: 8),
                      _infoRow(Icons.person_rounded, 'Passagers',
                          '${ctrl.totalPassengers}'),
                      const SizedBox(height: 8),
                      _infoRow(
                        Icons.airline_seat_recline_extra_rounded,
                        'Classe',
                        ctrl.selectedClass.value == '1st'
                            ? '1ère'
                            : '2ème',
                      ),
                      const SizedBox(height: 8),
                      _infoRow(
                        Icons.monetization_on_rounded,
                        'Prix / billet',
                        ZonePricing.formatPrice(basePrice),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.green, size: 12),
                            const SizedBox(width: 5),
                            Text('Valide',
                                style: GoogleFonts.poppins(
                                    color: AppColors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blue3, size: 13),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label  ',
                  style: GoogleFonts.poppins(
                      color: AppColors.blue3,
                      fontSize: 10),
                ),
                TextSpan(
                  text: value,
                  style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────
  // ACTION BUTTONS
  // ─────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.snackbar('Bientôt disponible',
                  'Téléchargement PDF arrive prochainement.',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDDE6F5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download_rounded,
                      color: AppColors.blue1, size: 18),
                  const SizedBox(width: 8),
                  Text('Télécharger',
                      style: GoogleFonts.poppins(
                          color: AppColors.blue1,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Get.offAllNamed('/home'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue2, AppColors.blue1],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('Accueil',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}