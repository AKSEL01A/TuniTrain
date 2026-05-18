import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthController get authCtrl => Get.find<AuthController>();

  // ─────────────────────────────
  // EMAIL LOGIN
  // ─────────────────────────────
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Fill all fields");
      return;
    }

    try {
      isLoading.value = true;

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;

      await authCtrl.loadUser(uid); // ✅ STRONG SINGLE SOURCE OF TRUTH

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────
  // GOOGLE LOGIN
  // ─────────────────────────────
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      final uid = result.user!.uid;

      await authCtrl.loadUser(uid); // ✅ SAME FLOW

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("Google Login Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
