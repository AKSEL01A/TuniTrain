import 'package:flutter/material.dart';

import 'package:tuni_train/core/constants/app_constants.dart';

/// A single shimmer-style placeholder rectangle.
/// Use inside skeleton loading layouts to indicate content is loading.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F8),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A standard skeleton card that mimics a ticket card while data loads.
class TicketSkeletonCard extends StatelessWidget {
  const TicketSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.section),
      height: AppSizes.skeletonCardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.section,
              AppSpacing.section,
              AppSpacing.section,
              0,
            ),
            child: Row(
              children: [
                const ShimmerBox(width: 60, height: 26, radius: AppRadius.sm),
                const SizedBox(width: AppSpacing.lg),
                const ShimmerBox(width: 100, height: 14, radius: 7),
                const Spacer(),
                const ShimmerBox(width: 80, height: 24, radius: AppRadius.md),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.section,
              AppSpacing.xxl,
              AppSpacing.section,
              0,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 70, height: 30, radius: AppRadius.sm),
                    const SizedBox(height: AppSpacing.xs),
                    const ShimmerBox(width: 90, height: 12, radius: AppRadius.xs + 1),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    const ShimmerBox(width: 70, height: 18, radius: AppRadius.sm),
                    const SizedBox(height: AppSpacing.sm),
                    const ShimmerBox(width: 100, height: 10, radius: AppRadius.xs + 1),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const ShimmerBox(width: 70, height: 30, radius: AppRadius.sm),
                    const SizedBox(height: AppSpacing.xs),
                    const ShimmerBox(width: 90, height: 12, radius: AppRadius.xs + 1),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrollable list of [TicketSkeletonCard] widgets shown while tickets load.
class TicketSkeletonList extends StatelessWidget {
  final int count;

  const TicketSkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.listPadding,
      itemCount: count,
      itemBuilder: (_, _) => const TicketSkeletonCard(),
    );
  }
}
