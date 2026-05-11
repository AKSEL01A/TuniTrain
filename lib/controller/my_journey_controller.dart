import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/tickets.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MyJourneyController
//  Fetches Tickets purchased by the current user from Firestore,
//  filters them into ACTIVE (not yet expired) and PAST (expired / used).
// ─────────────────────────────────────────────────────────────────────────────
class MyJourneyController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── State ──────────────────────────────────────────────────────────────
  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;
  RxString errorMsg = ''.obs;

  // ── Raw list from Firestore ─────────────────────────────────────────────
  RxList<Ticket> allTickets = <Ticket>[].obs;

  // ── Tab filter: 0 = active/upcoming, 1 = past/expired ──────────────────
  RxInt selectedTab = 0.obs;

  // ── Search / filter ─────────────────────────────────────────────────────
  RxString searchQuery = ''.obs;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  // ── Filtered lists ────────────────────────────────────────────────────
  List<Ticket> get activeTickets {
    final now = DateTime.now();
    return allTickets.where((t) {
      final notExpired =
          t.travelDate.isAfter(now) ||
          (t.travelDate.year == now.year &&
              t.travelDate.month == now.month &&
              t.travelDate.day == now.day);
      return notExpired && _matchesSearch(t);
    }).toList()..sort((a, b) => a.travelDate.compareTo(b.travelDate));
  }

  List<Ticket> get pastTickets {
    final now = DateTime.now();
    return allTickets.where((t) {
        final expired = t.travelDate.isBefore(
          DateTime(now.year, now.month, now.day),
        );
        return expired && _matchesSearch(t);
      }).toList()
      ..sort((a, b) => b.travelDate.compareTo(a.travelDate)); // newest first
  }

  List<Ticket> get displayedTickets =>
      selectedTab.value == 0 ? activeTickets : pastTickets;

  bool _matchesSearch(Ticket t) {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) return true;
    return t.fromStation.toLowerCase().contains(q) ||
        t.toStation.toLowerCase().contains(q) ||
        t.ticketCode.toLowerCase().contains(q);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LOAD FROM FIRESTORE
  //  Collection: 'Tickets'  →  documents owned by current user
  //  (Replace 'userId' field name with whatever your schema uses)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> loadTickets() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      // ── If you have Firebase Auth, filter by uid: ──────────────────────
      // final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      // final snap = await _db
      //     .collection('Tickets')
      //     .where('userId', isEqualTo: uid)
      //     .get();

      // ── For now: fetch all Tickets (swap with line above when auth ready) ─
      final snap = await _db
          .collection('Tickets')
          .orderBy('travelDate', descending: false)
          .get();

      allTickets.value = snap.docs.map((d) => Ticket.fromFirestore(d)).toList();

      debugPrint('🎫 Loaded ${allTickets.length} Tickets');
    } catch (e) {
      hasError.value = true;
      errorMsg.value = e.toString();
      debugPrint('🚨 MyJourneyController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh
  Future<void> refresh() => loadTickets();

  /// Cancel / delete a Ticket
  Future<void> cancelTicket(Ticket ticket) async {
    try {
      await _db.collection('Tickets').doc(ticket.firestoreId).delete();
      allTickets.removeWhere((t) => t.firestoreId == ticket.firestoreId);
      Get.snackbar(
        'Billet annulé',
        'Le billet ${ticket.ticketCode} a été supprimé.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'annuler le billet.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  int get activeCount => activeTickets.length;
  int get pastCount => pastTickets.length;

  /// How many minutes remain before departure (returns null if in the past)
  int? minutesUntilDeparture(Ticket ticket) {
    final diff = ticket.travelDate.difference(DateTime.now()).inMinutes;
    return diff >= 0 ? diff : null;
  }

  String countdownLabel(Ticket ticket) {
    final mins = minutesUntilDeparture(ticket);
    if (mins == null) return 'Terminé';
    if (mins < 60) return 'Dans ${mins}min';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (m == 0) return 'Dans ${h}h';
    return 'Dans ${h}h ${m}min';
  }

  Color countdownColor(Ticket ticket) {
    final mins = minutesUntilDeparture(ticket);
    if (mins == null) return const Color(0xFF9E9E9E);
    if (mins < 30) return const Color(0xFFD32F2F); // red – urgent
    if (mins < 120) return const Color(0xFFE65100); // orange – soon
    return const Color(0xFF2E7D32); // green – plenty of time
  }
}
