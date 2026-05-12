import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuni_train/controller/auth_controller.dart';
import 'package:tuni_train/models/tickets.dart';

class MyJourneyController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 Same collection name as TicketController
  static const String _collection = 'Tickets';

  RxBool isLoading = true.obs;
  RxBool hasError = false.obs;
  RxString errorMsg = ''.obs;
  RxList<MyTicket> allTickets = <MyTicket>[].obs;
  RxInt selectedTab = 0.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LOAD FROM FIRESTORE — filtered by userId
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> loadTickets() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final uid = Get.find<AuthController>().client.value?.id;

      if (uid == null || uid.isEmpty) {
        debugPrint('🚨 MyJourneyController: No authenticated user');
        allTickets.clear();
        return;
      }

      debugPrint('🎫 Loading tickets for userId: $uid');

      // 🔥 Try with orderBy first (needs composite index)
      try {
        final snap = await _db
            .collection(_collection)
            .where('userId', isEqualTo: uid)
            .orderBy('travelDate', descending: false)
            .get();

        allTickets.value = snap.docs
            .map((d) => MyTicket.fromFirestore(d))
            .toList();
      } catch (indexError) {
        // Composite index not yet created → fallback: filter only, sort in Dart
        debugPrint('⚠️  Index missing, using fallback: $indexError');
        final snap = await _db
            .collection(_collection)
            .where('userId', isEqualTo: uid)
            .get();

        final list = snap.docs.map((d) => MyTicket.fromFirestore(d)).toList();
        list.sort((a, b) => a.travelDate.compareTo(b.travelDate));
        allTickets.value = list;
      }

      debugPrint('✅ Loaded ${allTickets.length} tickets for user $uid');
    } catch (e) {
      hasError.value = true;
      errorMsg.value = e.toString();
      debugPrint('🚨 MyJourneyController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadTickets();

  // ─────────────────────────────────────────────────────────────────────────
  //  CANCEL TICKET
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> cancelTicket(MyTicket ticket) async {
    try {
      await _db.collection(_collection).doc(ticket.id).delete();
      allTickets.removeWhere((t) => t.id == ticket.id);
      Get.snackbar(
        'Billet annulé',
        'Le billet ${ticket.ticketCode} a été supprimé.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        "Impossible d'annuler le billet.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FILTERED LISTS
  // ─────────────────────────────────────────────────────────────────────────
  List<MyTicket> get activeTickets {
    final now = DateTime.now();

    return allTickets.where((t) {
      final departure = _ticketDepartureDateTime(t);

      return departure.isAfter(now) && _matchesSearch(t);
    }).toList()..sort(
      (a, b) =>
          _ticketDepartureDateTime(a).compareTo(_ticketDepartureDateTime(b)),
    );
  }

  List<MyTicket> get pastTickets {
    final now = DateTime.now();

    return allTickets.where((t) {
      final departure = _ticketDepartureDateTime(t);

      return departure.isBefore(now) && _matchesSearch(t);
    }).toList()..sort(
      (a, b) =>
          _ticketDepartureDateTime(b).compareTo(_ticketDepartureDateTime(a)),
    );
  }

  DateTime _ticketDepartureDateTime(MyTicket ticket) {
    try {
      final parts = ticket.departureTime.split(':');

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return DateTime(
        ticket.travelDate.year,
        ticket.travelDate.month,
        ticket.travelDate.day,
        hour,
        minute,
      );
    } catch (_) {
      return ticket.travelDate;
    }
  }

  List<MyTicket> get displayedTickets =>
      selectedTab.value == 0 ? activeTickets : pastTickets;

  bool _matchesSearch(MyTicket t) {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) return true;
    return t.fromStation.toLowerCase().contains(q) ||
        t.toStation.toLowerCase().contains(q) ||
        t.ticketCode.toLowerCase().contains(q);
  }

  int get activeCount => activeTickets.length;
  int get pastCount => pastTickets.length;

  int? minutesUntilDeparture(MyTicket ticket) {
    final departure = _ticketDepartureDateTime(ticket);

    final diff = departure.difference(DateTime.now()).inMinutes;

    return diff >= 0 ? diff : null;
  }

  String countdownLabel(MyTicket ticket) {
    final mins = minutesUntilDeparture(ticket);
    if (mins == null) return 'Terminé';
    if (mins < 60) return 'Dans ${mins}min';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (m == 0) return 'Dans ${h}h';
    return 'Dans ${h}h ${m}min';
  }

  Color countdownColor(MyTicket ticket) {
    final mins = minutesUntilDeparture(ticket);
    if (mins == null) return const Color(0xFF9E9E9E);
    if (mins < 30) return const Color(0xFFD32F2F);
    if (mins < 120) return const Color(0xFFE65100);
    return const Color(0xFF2E7D32);
  }
}
