import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/purchase/achats_controller.dart';

class AchatsPage extends StatelessWidget {
  const AchatsPage({super.key});

  AchatsController get ctrl => Get.put(AchatsController());

  @override
  Widget build(BuildContext context) {
    final c = ctrl;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.blue1,
              onRefresh: c.reload,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats row ──────────────────────────────────────────
                    _buildStatsRow(c),
                    const SizedBox(height: 28),

                    // ── 3 main action buttons ──────────────────────────────
                    _buildSectionLabel('Que voulez-vous faire ?'),
                    const SizedBox(height: 14),
                    _buildActionCard(
                      icon: Icons.train_rounded,
                      title: 'Rechercher un train',
                      subtitle: 'Achetez un billet aller ou aller-retour',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B4F8A), Color(0xFF2E6DB4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Get.toNamed('/searchtrain'),
                      badge: null,
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      icon: Icons.card_membership_rounded,
                      title: 'Acheter un abonnement',
                      subtitle: 'Voyages illimités — hebdo, mensuel ou annuel',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00838F), Color(0xFF00ACC1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Get.toNamed('/subscription'),
                      badge: null,
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      icon: Icons.grid_view_rounded,
                      title: 'Explorer les services',
                      subtitle: 'Location voitures, lieux touristiques & plus',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => Get.toNamed('/services'),
                      badge: null,
                    ),

                    const SizedBox(height: 32),

                    // ── Recent purchases ───────────────────────────────────
                    _buildRecentSection(c),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4F8A), Color(0xFF2E6DB4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Achats',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Billets, abonnements & services',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STATS ROW ────────────────────────────────────────────────────────────
  Widget _buildStatsRow(AchatsController c) {
    return Obx(() {
      if (c.isLoading.value) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.blue1),
          ),
        );
      }

      return Row(
        children: [
          _statCard(
            label: 'Billets actifs',
            value: '${c.activeTickets.value}',
            icon: Icons.confirmation_number_rounded,
            color: AppColors.blue1,
            bg: AppColors.bluePale,
          ),
          const SizedBox(width: 10),
          _statCard(
            label: 'Abonnements',
            value: '${c.activeAbonnements.value}',
            icon: Icons.card_membership_rounded,
            color: const Color(0xFF00838F),
            bg: const Color(0xFFE0F7FA),
          ),
          const SizedBox(width: 10),
          _statCard(
            label: 'Total dépensé',
            value: '${c.totalSpent.value.toStringAsFixed(0)} DT',
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF6A1B9A),
            bg: const Color(0xFFF3E5F5),
          ),
        ],
      );
    });
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACTION CARD ──────────────────────────────────────────────────────────
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Arrow
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── RECENT PURCHASES ─────────────────────────────────────────────────────
  Widget _buildRecentSection(AchatsController c) {
    return Obx(() {
      if (c.isLoading.value) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionLabel('Achats récents'),
              GestureDetector(
                onTap: () => Get.toNamed('/my-journeys'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bluePale,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Voir tout',
                    style: GoogleFonts.poppins(
                      color: AppColors.blue1,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (c.hasError.value)
            _buildErrorState(c)
          else if (c.recentPurchases.isEmpty)
            _buildEmptyState()
          else
            ...c.recentPurchases.map(_buildPurchaseRow),
        ],
      );
    });
  }

  Widget _buildPurchaseRow(RecentPurchase p) {
    final isTicket = p.type == 'ticket';
    final color = isTicket ? AppColors.blue1 : const Color(0xFF00838F);
    final bg = isTicket ? AppColors.bluePale : const Color(0xFFE0F7FA);
    final icon = isTicket
        ? Icons.confirmation_number_rounded
        : Icons.card_membership_rounded;

    Color statusColor;
    String statusLabel;
    switch (p.status) {
      case 'active':
        statusColor = AppColors.green;
        statusLabel = 'Actif';
        break;
      case 'expired':
        statusColor = AppColors.blue3;
        statusLabel = 'Expiré';
        break;
      case 'pending':
        statusColor = AppColors.sand;
        statusLabel = 'En attente';
        break;
      default:
        statusColor = AppColors.blue3;
        statusLabel = p.status;
    }

    final dateStr = DateFormat('dd MMM yyyy', 'fr_FR').format(p.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      p.subtitle,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· $dateStr',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Price + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${p.amount.toStringAsFixed(2)} DT',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.bluePale,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.blue3,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun achat pour le moment',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Commencez par rechercher un train !',
            style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Get.toNamed('/searchtrain'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E6DB4), Color(0xFF1B4F8A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Rechercher un train',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AchatsController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.red,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            'Impossible de charger vos achats',
            style: GoogleFonts.poppins(
              color: AppColors.red,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: c.reload,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Réessayer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppColors.blue1,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
