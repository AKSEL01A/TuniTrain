import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // ← ADD THIS IMPORT
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuni_train/controller/auth/auth_controller.dart';
import 'package:tuni_train/controller/mon_journee/my_journey_controller.dart';
import 'package:tuni_train/controller/purchase/panel_controller.dart';
import 'package:tuni_train/models/purchase/payment.dart';

import 'package:tuni_train/models/purchase/tickets.dart';

class TicketController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────────────────────
  Rxn<MyTicket> savedTicket = Rxn<MyTicket>();

  RxBool isSaving = false.obs;
  RxBool isSaved = false.obs;

  RxString savedFirestoreId = ''.obs;

  // ─────────────────────────────────────────────────────────────
  // SEND STATE
  // ─────────────────────────────────────────────────────────────
  RxString sendMethod = ''.obs;
  RxBool isSending = false.obs;
  RxBool isSent = false.obs;
  RxString sendInput = ''.obs;
  RxString sendError = ''.obs; // ← NEW: shows validation/send errors in UI

  String paymentMethod = '';

  static const String _collection = 'Tickets';

  // ─────────────────────────────────────────────────────────────
  // GENERATE TICKET CODE — unchanged
  // ─────────────────────────────────────────────────────────────
  String generateTicketCode() {
    final now = DateTime.now();
    final rnd = Random().nextInt(9000) + 1000;
    return 'TT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$rnd';
  }

  // ─────────────────────────────────────────────────────────────
  // SAVE TICKET — unchanged
  // ─────────────────────────────────────────────────────────────
  Future<void> saveTicket() async {
    try {
      isSaving.value = true;

      final panelCtrl = Get.find<PanelController>();
      final aller = panelCtrl.journeyAller.value;

      if (aller == null) {
        debugPrint('🚨 No aller journey selected');
        return;
      }

      final retour = panelCtrl.journeyRetour.value;
      final now = DateTime.now();
      final code = generateTicketCode();
      final user = Get.find<AuthController>().client.value;

      if (user == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      debugPrint('💾 Saving ticket for user: ${user.id}');

      final Map<String, dynamic> data = {
        'userId': user.id,
        'ticketCode': code,
        'fromStation': aller.fromStation,
        'toStation': aller.toStation,
        'departureTime': aller.departureTime.toString(),
        'arrivalTime': aller.arrivalTime.toString(),
        'travelDate': panelCtrl.searchCtrl.departureDateTime.value ?? now,
        'trainLine': aller.lineId,
        'trainNumber': aller.trainId.toString(),
        'ticketClass': panelCtrl.selectedClass.value,
        'passengers': panelCtrl.totalPassengers,
        'totalPrice': panelCtrl.totalPrice.value,
        'paymentMethod': paymentMethod,
        'status': 'active',
        'isRoundTrip': retour != null,
        'returnFromStation': retour?.fromStation,
        'returnToStation': retour?.toStation,
        'returnDepartureTime': retour?.departureTime.toString(),
        'returnArrivalTime': retour?.arrivalTime.toString(),
        'returnDate': retour != null
            ? (panelCtrl.searchCtrl.returnDateTime.value ?? now)
            : null,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'phoneNumber': user.phone,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final ref = await _db.collection(_collection).add(data);
      debugPrint('✅ Ticket saved: ${ref.id}');

      final savedT = MyTicket(
        id: ref.id,
        userId: user.id,
        ticketCode: code,
        fromStation: aller.fromStation,
        toStation: aller.toStation,
        departureTime: aller.departureTime.toString(),
        arrivalTime: aller.arrivalTime.toString(),
        travelDate: panelCtrl.searchCtrl.departureDateTime.value ?? now,
        trainLine: aller.lineId,
        trainNumber: aller.trainId.toString(),
        ticketClass: panelCtrl.selectedClass.value,
        passengers: panelCtrl.totalPassengers,
        totalPrice: panelCtrl.totalPrice.value,
        paymentMethod: paymentMethod,
        status: 'active',
        isRoundTrip: retour != null,
        returnFromStation: retour?.fromStation,
        returnToStation: retour?.toStation,
        returnDepartureTime: retour?.departureTime.toString(),
        returnArrivalTime: retour?.arrivalTime.toString(),
        returnDate: retour != null
            ? (panelCtrl.searchCtrl.returnDateTime.value ?? now)
            : null,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phone,
      );

      savedTicket.value = savedT;
      savedFirestoreId.value = ref.id;
      isSaved.value = true;
      _pushToLocalList(savedT);
      debugPrint('✅ Ticket synced locally');
    } catch (e) {
      debugPrint('🚨 SAVE TICKET ERROR: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder le billet.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PUSH TO MY JOURNEY LIST — unchanged
  // ─────────────────────────────────────────────────────────────
  void _pushToLocalList(MyTicket ticket) {
    try {
      final journeyCtrl = Get.find<MyJourneyController>();
      journeyCtrl.allTickets.insert(0, ticket);
      debugPrint('✅ Added to local journey list');
    } catch (e) {
      debugPrint('ℹ️ MyJourneyController not active yet');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ SEND TICKET — REAL (Firebase Cloud Function)
  // ONLY THIS METHOD CHANGED
  // ─────────────────────────────────────────────────────────────
  Future<void> sendTicket() async {
    final input = sendInput.value.trim();
    sendError.value = '';

    // ── Validation ────────────────────────────────────────────
    if (sendMethod.value.isEmpty || input.isEmpty) {
      sendError.value = sendMethod.value == 'email'
          ? 'Entrez votre adresse email.'
          : 'Entrez votre numéro de téléphone.';
      return;
    }
    if (sendMethod.value == 'email' && !_isValidEmail(input)) {
      sendError.value = 'Adresse email invalide.';
      return;
    }
    if (sendMethod.value == 'sms' && !_isValidPhone(input)) {
      sendError.value = 'Numéro invalide. Format: +216XXXXXXXX';
      return;
    }

    final ticket = savedTicket.value;
    if (ticket == null) {
      sendError.value = 'Billet introuvable.';
      return;
    }

    try {
      isSending.value = true;

      // 🔥 Call the Cloud Function (index.js → sendTicket)
      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('sendTicket');

      await callable.call({
        'method': sendMethod.value, // 'email' or 'sms'
        'destination': input, // email address or +216xxxxxxxx
        'ticketLink': ticketLink,
        'ticketCode': ticket.ticketCode,
        'fromStation': ticket.fromStation,
        'toStation': ticket.toStation,
        'departureTime': ticket.departureTime,
      });

      debugPrint('📨 Sent via ${sendMethod.value} to $input ✅');
      isSent.value = true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('🚨 Functions error: ${e.message}');
      sendError.value = e.message ?? "L'envoi a échoué.";
      Get.snackbar(
        'Erreur',
        sendError.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('🚨 Unexpected error: $e');
      sendError.value = "Une erreur inattendue s'est produite.";
      Get.snackbar(
        'Erreur',
        sendError.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // TICKET LINK — unchanged
  // ─────────────────────────────────────────────────────────────
  String get ticketLink {
    return 'https://tunitrain.app/ticket/${savedTicket.value?.ticketCode ?? ''}';
  }

  // ─────────────────────────────────────────────────────────────
  // QR PAYLOAD — unchanged
  // ─────────────────────────────────────────────────────────────
  String get qrPayload {
    return savedTicket.value?.toQrPayload() ?? '';
  }

  // ─────────────────────────────────────────────────────────────
  // SAVE PAYMENT → Firestore "Payments" collection
  // ─────────────────────────────────────────────────────────────
 Future<void> savePayment() async {
    try {
      final user = Get.find<AuthController>().client.value;
      final panelCtrl = Get.find<PanelController>();
      final ticket = savedTicket.value;

      if (user == null) {
        debugPrint('🚨 No user — cannot save payment');
        return;
      }

      final payment = Payment(
        userId: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phone,
        paymentMethod: paymentMethod,
        amount: panelCtrl.totalPrice.value,
        status: 'success',
        ticketId: savedFirestoreId.value,
        ticketCode: ticket?.ticketCode ?? '',
        fromStation: ticket?.fromStation ?? '',
        toStation: ticket?.toStation ?? '',
        passengers: panelCtrl.totalPassengers,
        ticketClass: panelCtrl.selectedClass.value,
        isRoundTrip: ticket?.isRoundTrip ?? false,
      );

      final ref = await _db.collection('Payments').add(payment.toFirestore());
      debugPrint(
        '✅ Payment saved: ${ref.id} | $paymentMethod | ${payment.amount} DT',
      );
    } catch (e) {
      debugPrint('🚨 SAVE PAYMENT ERROR: $e');
    }
  }

  
  // ─────────────────────────────────────────────────────────────
  // RESET SEND — +sendError reset added
  // ─────────────────────────────────────────────────────────────
  void resetSend() {
    sendMethod.value = '';
    sendInput.value = '';
    isSent.value = false;
    isSending.value = false;
    sendError.value = ''; // ← NEW
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS — NEW
  // ─────────────────────────────────────────────────────────────
  bool _isValidEmail(String v) =>
      RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(v);

  bool _isValidPhone(String v) => RegExp(r'^\+?[0-9]{8,15}$').hasMatch(v);
}
