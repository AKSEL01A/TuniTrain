import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tuni_train/controller/auth/auth_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Model — recent purchase item
// ─────────────────────────────────────────────────────────────────────────────
class RecentPurchase {
  final String id;
  final String type; // 'ticket' | 'abonnement'
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String status; // 'active' | 'expired' | 'pending'

  const RecentPurchase({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory RecentPurchase.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final isTicket = d['ticketCode'] != null;
    return RecentPurchase(
      id: doc.id,
      type: isTicket ? 'ticket' : 'abonnement',
      title: isTicket
          ? '${d['fromStation'] ?? ''} → ${d['toStation'] ?? ''}'
          : 'Abonnement ${d['typeName'] ?? ''}',
      subtitle: isTicket
          ? d['ticketCode'] ?? ''
          : '${d['fromStation'] ?? ''} → ${d['toStation'] ?? ''}',
      amount: (d['totalPrice'] as num?)?.toDouble() ?? 0.0,
      date: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: d['status'] ?? 'active',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AchatsController
// ─────────────────────────────────────────────────────────────────────────────
class AchatsController extends GetxController {
  final _db = FirebaseFirestore.instance;

  final recentPurchases = <RecentPurchase>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  // Stats
  final totalSpent = 0.0.obs;
  final activeTickets = 0.obs;
  final activeAbonnements = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final user = Get.find<AuthController>().client.value;
      if (user == null) {
        isLoading.value = false;
        return;
      }

      // Load last 5 tickets
      final ticketsSnap = await _db
          .collection('Tickets')
          .where('userId', isEqualTo: user.id)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      // Load last 3 subscriptions
      final subsSnap = await _db
          .collection('Subscriptions')
          .where('userId', isEqualTo: user.id)
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      final all = [
        ...ticketsSnap.docs.map(RecentPurchase.fromFirestore),
        ...subsSnap.docs.map(RecentPurchase.fromFirestore),
      ];

      // Sort by date desc
      all.sort((a, b) => b.date.compareTo(a.date));
      recentPurchases.assignAll(all.take(5));

      // Compute stats
      totalSpent.value = all.fold(0.0, (sum, p) => sum + p.amount);
      activeTickets.value = all
          .where((p) => p.type == 'ticket' && p.status == 'active')
          .length;
      activeAbonnements.value = all
          .where((p) => p.type == 'abonnement' && p.status == 'active')
          .length;
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() => loadPurchases();
}
