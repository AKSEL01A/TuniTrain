import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/purchase/ticket_controller.dart';
import 'package:tuni_train/controller/purchase/panel_controller.dart';

class SendSheet extends StatelessWidget {
  final TicketController ctrl;
  const SendSheet({super.key, required this.ctrl});

  // Journey info from PanelController
  PanelController? get _panel {
    try {
      return Get.find<PanelController>();
    } catch (_) {
      return null;
    }
  }

  String get _from => _panel?.journeyAller.value?.fromStation ?? '—';
  String get _to => _panel?.journeyAller.value?.toStation ?? '—';
  String get _depTime => _panel?.journeyAller.value?.departureTime ?? '--:--';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Obx(
          () => ctrl.isSent.value ? _buildSentState() : _buildForm(context),
        ),
      ),
    );
  }

  // ─── FORM ─────────────────────────────────────────────────────────────────
  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(
          child: Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Recevoir mon billet',
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choisissez comment recevoir votre billet et QR Code.',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // Method tiles
        Row(
          children: [
            Expanded(child: _methodTile('email', Icons.email_rounded, 'Email')),
            const SizedBox(width: 12),
            Expanded(child: _methodTile('sms', Icons.sms_rounded, 'SMS')),
          ],
        ),
        const SizedBox(height: 16),

        // Input field
        Obx(() {
          if (ctrl.sendMethod.value.isEmpty) return const SizedBox.shrink();
          final isEmail = ctrl.sendMethod.value == 'email';
          return TextField(
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : TextInputType.phone,
            onChanged: (v) {
              ctrl.sendInput.value = v;
              ctrl.sendError.value = ''; // clear error on type
            },
            decoration: InputDecoration(
              hintText: isEmail ? 'votre@email.com' : '+216 XX XXX XXX',
              hintStyle: GoogleFonts.poppins(
                color: AppColors.blue3,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                isEmail ? Icons.email_outlined : Icons.phone_outlined,
                color: AppColors.blue3,
              ),
              filled: true,
              fillColor: AppColors.bluePale,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.red),
              ),
            ),
          );
        }),

        // Error message
        Obx(() {
          if (ctrl.sendError.value.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  ctrl.sendError.value,
                  style: GoogleFonts.poppins(
                    color: AppColors.red,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),

        // Link preview + send button
        Obx(() {
          if (ctrl.sendMethod.value.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              const SizedBox(height: 12),
              // Link preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sandBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.sand.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      color: AppColors.sand,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ctrl.ticketLink,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: AppColors.sand,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Send button
              Obx(
                () => GestureDetector(
                  onTap: ctrl.isSending.value ? null : ctrl.sendTicket,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: ctrl.isSending.value
                            ? [Colors.grey.shade400, Colors.grey.shade300]
                            : [AppColors.blue2, AppColors.blue1],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: ctrl.isSending.value
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.blue1.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: ctrl.isSending.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Envoi en cours…',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              ctrl.sendMethod.value == 'email'
                                  ? '📧 Envoyer par email'
                                  : '📱 Envoyer par SMS',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ─── METHOD TILE ──────────────────────────────────────────────────────────
  Widget _methodTile(String id, IconData icon, String label) {
    return Obx(() {
      final selected = ctrl.sendMethod.value == id;
      return GestureDetector(
        onTap: () {
          ctrl.sendMethod.value = id;
          ctrl.sendInput.value = '';
          ctrl.sendError.value = '';
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.bluePale : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.blue1 : const Color(0xFFDDE6F5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.blue1 : AppColors.blue3,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: selected ? AppColors.blue1 : AppColors.blue3,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── SENT STATE ───────────────────────────────────────────────────────────
  Widget _buildSentState() {
    final byEmail = ctrl.sendMethod.value == 'email';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.greenBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.green,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Billet envoyé !',
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          byEmail
              ? 'Un email avec votre QR Code a été envoyé à :\n${ctrl.sendInput.value}'
              : 'Un SMS avec le lien a été envoyé au :\n${ctrl.sendInput.value}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppColors.blue3,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Link preview
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bluePale,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, color: AppColors.blue1, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ctrl.ticketLink,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Send again (different method)
        GestureDetector(
          onTap: () {
            ctrl.sendMethod.value = byEmail ? 'sms' : 'email';
            ctrl.sendInput.value = '';
            ctrl.isSent.value = false;
            ctrl.sendError.value = '';
          },
          child: Text(
            byEmail ? 'Envoyer aussi par SMS' : 'Envoyer aussi par email',
            style: GoogleFonts.poppins(
              color: AppColors.blue3,
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.blue3,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Close
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.blue2, AppColors.blue1],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
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
        ),
      ],
    );
  }
}
