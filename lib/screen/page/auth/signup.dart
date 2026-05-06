import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/data/country.dart';
import 'package:tuni_train/controller/signup_controller.dart';

// ─── Register Page ────────────────────────────────────────────────
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFB0C8E8),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF1B4F8A),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Text(
                'Créer un compte',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1B4F8A),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rejoignez TuniTrain dès maintenant',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4A90C4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),

              _buildLabel('Prénom'),
              _buildField(
                controller: controller.firstNameController,
                hint: 'Jean',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              _buildLabel('Nom'),
              _buildField(
                controller: controller.lastNameController,
                hint: 'Dupont',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Email
              _buildLabel('Email'),
              const SizedBox(height: 8),
              _buildField(
                controller: controller.emailController,
                hint: 'votre@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Phone with country picker
              _buildLabel('Numéro de téléphone'),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFB0C8E8),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Country picker button
                      GestureDetector(
                        onTap: () => _showCountryPicker(context, controller),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Color(0xFFB0C8E8),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                controller.selectedCountry.value.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.selectedCountry.value.code,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF1B4F8A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF2E6DB4),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Phone input
                      Expanded(
                        child: TextField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1B4F8A),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'XX XXX XXX',
                            hintStyle: GoogleFonts.poppins(
                              color: const Color(0xFFAAAAAA),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              _buildLabel('Mot de passe'),
              const SizedBox(height: 8),
              Obx(
                () => _buildField(
                  controller: controller.passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: controller.obscurePassword.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF2E6DB4),
                      size: 18,
                    ),
                    onPressed: () => controller.obscurePassword.value =
                        !controller.obscurePassword.value,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm password
              _buildLabel('Confirmer le mot de passe'),
              const SizedBox(height: 8),
              Obx(
                () => _buildField(
                  controller: controller.confirmPasswordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscure: controller.obscureConfirm.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureConfirm.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF2E6DB4),
                      size: 18,
                    ),
                    onPressed: () => controller.obscureConfirm.value =
                        !controller.obscureConfirm.value,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Terms checkbox
              Obx(
                () => GestureDetector(
                  onTap: () => controller.acceptTerms.value =
                      !controller.acceptTerms.value,
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: controller.acceptTerms.value
                              ? const Color(0xFF2E6DB4)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFF2E6DB4),
                            width: 1.5,
                          ),
                        ),
                        child: controller.acceptTerms.value
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF4A90C4),
                              fontSize: 12,
                            ),
                            children: [
                              const TextSpan(text: "J'accepte les "),
                              TextSpan(
                                text: "conditions d'utilisation",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF1B4F8A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Register button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6DB4),
                      disabledBackgroundColor: const Color(0xFF7AB8D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "S'inscrire",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFB0C8E8))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "ou s'inscrire avec",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF4A90C4),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFB0C8E8))),
                ],
              ),
              const SizedBox(height: 20),

              // Social buttons
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata,
                      iconColor: const Color(0xFFDB4437),
                      onTap: controller.signupWithGoogle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Login link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4A90C4),
                      fontSize: 13,
                    ),
                    children: [
                      const TextSpan(text: "Déjà un compte ? "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            "Se connecter",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF1B4F8A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context, RegisterController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFB0C8E8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choisir un pays',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1B4F8A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (_, index) {
                  final country = countries[index];

                  return ListTile(
                    leading: Text(
                      country.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    title: Text(
                      country.name,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1B4F8A),
                        fontSize: 14,
                      ),
                    ),
                    trailing: Text(
                      country.code,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF4A90C4),
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {
                      controller.selectedCountry.value = country;
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(color: const Color(0xFF1B4F8A), fontSize: 12),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: const Color(0xFF1B4F8A), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xFFAAAAAA),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF2E6DB4), size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF0F4FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0C8E8), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0C8E8), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E6DB4), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB0C8E8), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1B4F8A),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
