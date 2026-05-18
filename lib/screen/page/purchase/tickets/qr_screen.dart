import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tuni_train/core/constants/date_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/controller/purchase/ticket_controller.dart';
import 'package:tuni_train/models/purchase/tickets.dart';

class QrTicketScreen extends StatelessWidget {
  final TicketController? ticketCtrl;
  final MyTicket? directTicket;

  const QrTicketScreen({super.key, this.ticketCtrl, this.directTicket})
    : assert(
        ticketCtrl != null || directTicket != null,
        'Provide ticketCtrl or directTicket',
      );

  MyTicket? get _ticket => directTicket ?? ticketCtrl?.savedTicket.value;

  String get _qrPayload =>
      directTicket?.toQrPayload() ?? ticketCtrl?.qrPayload ?? '';

  @override
  Widget build(BuildContext context) {
    if (ticketCtrl != null) {
      return Obx(() => _buildScaffold(ticketCtrl!.savedTicket.value));
    }
    return _buildScaffold(_ticket);
  }

  Widget _buildScaffold(MyTicket? ticket) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
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
                        'Mon Billet',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: ticket == null
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.blue1),
                    )
                  : _buildContent(ticket),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MyTicket ticket) {
    return Column(
      children: [
        // ── Status banner ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.greenBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.green,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Billet Actif',
                      style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ticket.ticketCode,
                      style: GoogleFonts.poppins(
                        color: AppColors.green.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── QR code card ─────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue1.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Scannez ce QR Code',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Présentez-le au contrôleur',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDDE6F5), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: _qrPayload.isNotEmpty ? _qrPayload : ticket.ticketCode,
                  version: QrVersions.auto,
                  size: 200,
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
              const SizedBox(height: 16),
              Text(
                ticket.ticketCode,
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Journey info card ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.blue1,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue1.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Route row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.departureTime,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          ticket.fromStation,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.train_rounded,
                        color: AppColors.sand,
                        size: 20,
                      ),
                      Container(width: 40, height: 1, color: Colors.white30),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ticket.arrivalTime,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          ticket.toStation,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 12),

              // Details
              _infoRow('Train', '#${ticket.trainNumber}'),
              _infoRow('Ligne', ticket.trainLine),
              _infoRow('Date', formatFrDateFull(ticket.travelDate)),
              _infoRow('Classe', ticket.ticketClass == '1st' ? '1ère' : '2ème'),
              _infoRow('Passagers', '${ticket.passengers}'),
              _infoRow('Paiement', ticket.paymentMethod),

              const SizedBox(height: 8),
              Divider(color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total payé',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${ticket.totalPrice.toStringAsFixed(3)} DT',
                    style: GoogleFonts.poppins(
                      color: AppColors.sand,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Return leg ───────────────────────────────────────────────────
        if (ticket.isRoundTrip && ticket.returnFromStation != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sand.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.replay_circle_filled_rounded,
                      color: Color(0xFFE65100),
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trajet Retour',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFE65100),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _returnRow('De', ticket.returnFromStation ?? '—'),
                _returnRow('À', ticket.returnToStation ?? '—'),
                _returnRow('Départ', ticket.returnDepartureTime ?? '--'),
                _returnRow('Arrivée', ticket.returnArrivalTime ?? '--'),
                if (ticket.returnDate != null)
                  _returnRow(
                    'Date retour',
                    formatFrDateFull(ticket.returnDate!),
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // ── Close button ─────────────────────────────────────────────────
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDDE6F5)),
            ),
            child: Center(
              child: Text(
                'Fermer',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _returnRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xFFE65100).withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFFE65100),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
