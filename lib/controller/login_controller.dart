import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  // Instance متاع Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      isLoading.value = false;

      Get.offAllNamed(
        '/accueil',
      ); // Navigue vers la page d'accueil après le login
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String message = "Une erreur est survenue";
      if (e.code == 'user-not-found') {
        message = "Aucun utilisateur trouvé pour cet email.";
      } else if (e.code == 'wrong-password') {
        message = "Mot de passe incorrect.";
      } else if (e.code == 'invalid-email') {
        message = "L'adresse email n'est pas valide.";
      }

      Get.snackbar(
        'Erreur de connexion',
        message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // user cancelled
      if (googleUser == null) {
        isLoading.value = false;
        debugPrint("❌ Google sign-in cancelled");
        return;
      }

      debugPrint("✅ Selected Google account:");
      debugPrint("👉 Name: ${googleUser.displayName}");
      debugPrint("👉 Email: ${googleUser.email}");
      debugPrint("👉 ID: ${googleUser.id}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint("🔥 Firebase login success:");
      debugPrint("👉 UID: ${userCredential.user?.uid}");
      debugPrint("👉 Email: ${userCredential.user?.email}");

      isLoading.value = false;

      Get.offAllNamed('/accueil');

      Get.snackbar(
        "Success",
        "Google login successful",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;

      debugPrint("❌ LOGIN ERROR: $e");

      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
