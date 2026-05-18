import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/auth/forgot_password_controller.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1B4F8A),
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mot de passe oublié ?',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1B4F8A),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Entrez votre email pour recevoir un lien de réinitialisation.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF4A90C4),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 36),

            Text(
              'Email',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1B4F8A),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),

            // EMAIL INPUT
            TextField(
              controller: emailController,
              onChanged: controller.setEmail,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1B4F8A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'votre@email.com',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFFAAAAAA),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF2E6DB4),
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xFFF0F4FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB0C8E8),
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB0C8E8),
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E6DB4),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 28),

            // BUTTON WITH LOADING STATE
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.sendResetEmail();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E6DB4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Envoyer le lien',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
