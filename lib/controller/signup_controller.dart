import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tuni_train/data/country.dart';

import '../models/client.dart';

class RegisterController extends GetxController {
  // ================= INPUT CONTROLLERS =================
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ================= STATE =================
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirm = true.obs;
  final acceptTerms = false.obs;

  // ================= FIREBASE =================
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // ================= PHONE NUMBER BY COUNTRY =================
  final selectedCountry = countries.first.obs;

  // ================= DISPOSE =================
  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // ================= REGISTER =================
  Future<void> register() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    // ---------- VALIDATION ----------
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      Get.snackbar(
        "Error",
        "Fill all fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Invalid email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        "Error",
        "Password too short",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirm) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!acceptTerms.value) {
      Get.snackbar(
        "Error",
        "Accept terms first",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // ================= AUTH =================
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // ================= CLIENT MODEL =================
      final client = Client(
        id: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: "", // ما نخزّنش password في Firestore 🔥
        createdAt: DateTime.now(),
      );

      // ================= FIRESTORE SAVE =================
      await _firestore.collection("clients").doc(uid).set(client.toMap());

      Get.snackbar(
        "Success",
        "Account created successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/accueil');
    } on FirebaseAuthException catch (e) {
      String msg = "Something went wrong";

      if (e.code == "email-already-in-use") msg = "Email already used";
      if (e.code == "weak-password") msg = "Weak password";
      if (e.code == "invalid-email") msg = "Invalid email";

      Get.snackbar(
        "Error",
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signupWithGoogle() async {
    try {
      isLoading.value = true;

      // 🔥 FORCE FULL RESET
      await _googleSignIn.signOut();
      await _auth.signOut();

      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication auth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final firebaseUser = result.user;

      if (firebaseUser != null) {
        await _firestore.collection("clients").doc(firebaseUser.uid).set({
          "id": firebaseUser.uid,
          "firstName": firebaseUser.displayName ?? "",
          "email": firebaseUser.email ?? "",
          "createdAt": DateTime.now(),

          // 🔥 NEW FIELD
          "isActive": true,
        }, SetOptions(merge: true));
      }

      Get.offAllNamed('/accueil');
    } finally {
      isLoading.value = false;
    }
  }
}
