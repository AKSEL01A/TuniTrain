import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/models/client.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<Client> client = Rxn<Client>();

  Client? get user => client.value;

  @override
  void onInit() {
    super.onInit();

    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await loadUser(firebaseUser.uid);
      } else {
        client.value = null;
      }
    });
  }

  // ─────────────────────────────
  // LOAD USER (STRONG + DEBUG)
  // ─────────────────────────────
  Future<void> loadUser(String uid) async {
    try {
      debugPrint("\n🚀 =====================");
      debugPrint("LOAD USER START");
      debugPrint("UID: $uid");

      final db = FirebaseFirestore.instance;

      DocumentSnapshot<Map<String, dynamic>>? doc;
      String role = "";

      // ─────────────────────────────
      // TRY CLIENT
      // ─────────────────────────────
      final clientSnap = await db.collection('clients').doc(uid).get();

      if (clientSnap.exists) {
        doc = clientSnap;
        role = "client";
      }

      // ─────────────────────────────
      // TRY ADMIN IF NOT CLIENT
      // ─────────────────────────────
      if (doc == null) {
        final adminSnap = await db.collection('administrateurs').doc(uid).get();

        if (adminSnap.exists) {
          doc = adminSnap;
          role = "admin";
        }
      }

      // ─────────────────────────────
      // NOT FOUND
      // ─────────────────────────────
      if (doc == null || doc.data() == null) {
        debugPrint("❌ USER NOT FOUND IN FIRESTORE");
        client.value = null;
        return;
      }

      final data = doc.data()!;

      // ─────────────────────────────
      // DEBUG DATA
      // ─────────────────────────────
      debugPrint("📦 RAW DATA:");
      data.forEach((k, v) => debugPrint("$k => $v"));

      // ─────────────────────────────
      // CREATE USER MODEL
      // ─────────────────────────────
      final loadedUser = Client.fromMap(data, doc.id);

      client.value = loadedUser;

      // ─────────────────────────────
      // SUCCESS LOGS
      // ─────────────────────────────
      debugPrint("✅ USER LOADED SUCCESSFULLY");
      debugPrint("ROLE: $role");
      debugPrint("NAME: ${loadedUser.firstName} ${loadedUser.lastName}");
      debugPrint("EMAIL: ${loadedUser.email}");
      debugPrint("PHONE: ${loadedUser.phone}");
      debugPrint("CREATED: ${loadedUser.createdAt}");

      debugPrint("=====================\n");
    } catch (e, st) {
      debugPrint("🔥 LOAD USER ERROR: $e");
      debugPrint(st.toString());
      client.value = null;
    }
  }

  // ─────────────────────────────
  // LOGOUT
  // ─────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    client.value = null;
  }
}
