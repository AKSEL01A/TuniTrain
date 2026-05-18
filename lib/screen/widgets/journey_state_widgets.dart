import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuni_train/core/widgets/app_empty_state.dart';
import 'package:tuni_train/core/widgets/loading_skeleton.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON LOADING LIST
// ─────────────────────────────────────────────────────────────────────────────

class JourneySkeletonList extends StatelessWidget {
  const JourneySkeletonList({super.key});

  @override
  Widget build(BuildContext context) => const TicketSkeletonList();
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class JourneyEmptyState extends StatelessWidget {
  /// [tab] == 0 → active/upcoming tab; 1 → history tab.
  final int tab;

  const JourneyEmptyState({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final isActive = tab == 0;

    return AppEmptyState(
      icon: isActive
          ? Icons.confirmation_number_outlined
          : Icons.history_toggle_off_rounded,
      title: isActive ? 'Aucun voyage à venir' : 'Aucun voyage passé',
      body: isActive
          ? 'Réservez votre prochain train\npour le voir ici.'
          : 'Vos trajets terminés\napparaîtront ici.',
      actionLabel: isActive ? 'Rechercher un train' : null,
      actionIcon: isActive ? Icons.search_rounded : null,
      onAction: isActive ? () => Get.toNamed('/searchtrain') : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────────────────────────────────────────

class JourneyErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const JourneyErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) => AppErrorState(onRetry: onRetry);
}
