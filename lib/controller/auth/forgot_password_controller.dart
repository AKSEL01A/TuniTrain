import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var email = ''.obs;

  void setEmail(String value) {
    email.value = value.trim();
  }

  Future<void> sendResetEmail() async {
    try {
      isLoading.value = true;

      final String userEmail = email.value.trim();

      if (userEmail.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Veuillez entrer votre email',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      await _auth.sendPasswordResetEmail(email: userEmail);

      Get.snackbar(
        'Succès',
        'Email de réinitialisation envoyé',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(seconds: 2));
      Get.back();
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Erreur',
        e.message ?? 'Erreur inconnue',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
