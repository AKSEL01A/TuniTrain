import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuni_train/controller/auth_controller.dart';
import 'package:tuni_train/controller/my_journey_controller.dart';
import 'package:tuni_train/controller/panel_controller.dart';

import 'package:tuni_train/models/tickets.dart';

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

  String paymentMethod = '';

  // 🔥 Firestore collection
  static const String _collection = 'Tickets';

  // ─────────────────────────────────────────────────────────────
  // GENERATE TICKET CODE
  // ─────────────────────────────────────────────────────────────
  String generateTicketCode() {
    final now = DateTime.now();

    final rnd = Random().nextInt(9000) + 1000;

    return 'TT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$rnd';
  }

  // ─────────────────────────────────────────────────────────────
  // SAVE TICKET
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

      // 🔥 Logged user
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

      // ─────────────────────────────────────────────────────────
      // FIRESTORE DATA
      // ─────────────────────────────────────────────────────────
      final Map<String, dynamic> data = {
        'userId': user.id,
        'ticketCode': code,

        'fromStation': aller.fromStation,
        'toStation': aller.toStation,

        'departureTime': aller.departureTime.toString(),
        'arrivalTime': aller.arrivalTime.toString(),

        'travelDate': panelCtrl.searchCtrl.departureDateTime.value ?? now,

        'trainLine': aller.lineId,

        // 🔥 convert safely to String
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

      // ─────────────────────────────────────────────────────────
      // SAVE TO FIRESTORE
      // ─────────────────────────────────────────────────────────
      final ref = await _db.collection(_collection).add(data);

      debugPrint('✅ Ticket saved: ${ref.id}');

      // ─────────────────────────────────────────────────────────
      // LOCAL MODEL
      // ─────────────────────────────────────────────────────────
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

        // 🔥 if MyTicket.trainNumber is String
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

      // 🔥 Update MyJourney immediately
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
  // PUSH TO MY JOURNEY LIST
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
  // SEND TICKET
  // ─────────────────────────────────────────────────────────────
  Future<void> sendTicket() async {
    if (sendMethod.value.isEmpty || sendInput.value.trim().isEmpty) {
      Get.snackbar(
        'Champ vide',
        sendMethod.value == 'email'
            ? 'Entrez votre adresse email.'
            : 'Entrez votre numéro de téléphone.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      isSending.value = true;

      await Future.delayed(const Duration(seconds: 2));

      debugPrint(
        '📨 Ticket sent via ${sendMethod.value} to ${sendInput.value}',
      );

      isSent.value = true;
    } catch (e) {
      debugPrint('🚨 SEND ERROR: $e');

      Get.snackbar(
        'Erreur',
        "L'envoi a échoué.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // TICKET LINK
  // ─────────────────────────────────────────────────────────────
  String get ticketLink {
    return 'https://tunitrain.app/ticket/${savedTicket.value?.ticketCode ?? ''}';
  }

  // ─────────────────────────────────────────────────────────────
  // QR PAYLOAD
  // ─────────────────────────────────────────────────────────────
  String get qrPayload {
    return savedTicket.value?.toQrPayload() ?? '';
  }

  // ─────────────────────────────────────────────────────────────
  // RESET SEND
  // ─────────────────────────────────────────────────────────────
  void resetSend() {
    sendMethod.value = '';

    sendInput.value = '';

    isSent.value = false;

    isSending.value = false;
  }
}
