import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/ticket_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  🔥 SEND BOTTOM SHEET  (email / SMS)
// ─────────────────────────────────────────────────────────────────────────────
class SendSheet extends StatelessWidget {
  final TicketController ctrl;
  const SendSheet({super.key, required this.ctrl});

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
          () => ctrl.isSent.value
              ? _buildSentState(context)
              : _buildForm(context),
        ),
      ),
    );
  }

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
          'Choisissez comment recevoir le lien vers votre billet et QR Code.',
          style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // Method selection
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
          if (ctrl.sendMethod.value == 'email') {
            return TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => ctrl.sendInput.value = v,
              decoration: InputDecoration(
                hintText: 'votre@email.com',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.blue3,
                ),
                filled: true,
                fillColor: AppColors.bluePale,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          } else if (ctrl.sendMethod.value == 'sms') {
            return TextField(
              keyboardType: TextInputType.phone,
              onChanged: (v) => ctrl.sendInput.value = v,
              decoration: InputDecoration(
                hintText: '+216 XX XXX XXX',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.blue3,
                ),
                filled: true,
                fillColor: AppColors.bluePale,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

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
              GestureDetector(
                onTap: ctrl.isSending.value ? null : ctrl.sendTicket,
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
                    child: ctrl.isSending.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Envoyer le lien',
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
        }),
      ],
    );
  }

  Widget _methodTile(String id, IconData icon, String label) {
    return Obx(() {
      final selected = ctrl.sendMethod.value == id;
      return GestureDetector(
        onTap: () {
          ctrl.sendMethod.value = id;
          ctrl.sendInput.value = '';
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

  Widget _buildSentState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
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
          'Lien envoyé !',
          style: GoogleFonts.poppins(
            color: AppColors.blue1,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ouvrez le lien pour accéder à votre QR code\net toutes les informations de votre voyage.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: AppColors.blue3,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 20),
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
