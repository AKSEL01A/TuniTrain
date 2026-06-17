import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/auth/login_controller.dart';
import 'package:tuni_train/screen/page/auth/forgot_password_screen.dart';
import 'package:tuni_train/screen/page/auth/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final LoginController _controller = Get.put(LoginController());

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(color: const Color(0xFF1B4F8A), fontSize: 12),
    );
  }

  Widget _buildTextField({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E6DB4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Center(
                child: Text(
                  'Bon retour 👋',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF000000),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Connectez-vous à votre compte',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4A90C4),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Email
              _buildLabel('Email'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _controller.emailController,
                hint: 'votre@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password
              _buildLabel('Mot de passe'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _controller.passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF2E6DB4),
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.to(() => ForgotPasswordPage()),
                  child: Text(
                    'Mot de passe oublié ?',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E6DB4),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Login button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading.value
                        ? null
                        : _controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6DB4),
                      disabledBackgroundColor: const Color(0xFF7AB8D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Se connecter',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFB0C8E8))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'ou continuer avec',
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
                      onTap: _controller.loginWithGoogle,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 32),

              // Sign up
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4A90C4),
                      fontSize: 13,
                    ),
                    children: [
                      const TextSpan(text: "Pas de compte ? "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Get.to(() => const RegisterPage()),
                          child: Text(
                            "S'inscrire",
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
            ],
          ),
        ),
      ),
    );
  }
}
