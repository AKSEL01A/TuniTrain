import 'package:flutter/material.dart';
import 'package:tuni_train/core/constants/app_constants.dart';

// ─── Shimmer box ─────────────────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;

  const _Shimmer({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F8),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}

// ─── Car card skeleton ────────────────────────────────────────────────────────

class CarCardSkeleton extends StatelessWidget {
  const CarCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.section),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F8),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.cardLg),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _Shimmer(width: 140, height: 16),
                    const Spacer(),
                    const _Shimmer(width: 60, height: 20),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _Shimmer(width: 100, height: 12),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: const [
                    _Shimmer(width: 60, height: 12),
                    SizedBox(width: AppSpacing.xl),
                    _Shimmer(width: 70, height: 12),
                    SizedBox(width: AppSpacing.xl),
                    _Shimmer(width: 55, height: 12),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const _Shimmer(width: 120, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollable list of [CarCardSkeleton] widgets.
class CarListSkeleton extends StatelessWidget {
  final int count;

  const CarListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.listPadding,
      itemCount: count,
      itemBuilder: (_, _) => const CarCardSkeleton(),
    );
  }
}

// ─── Place card skeleton ──────────────────────────────────────────────────────

class PlaceCardSkeleton extends StatelessWidget {
  const PlaceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.section),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2F8),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.cardLg),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _Shimmer(width: 150, height: 16),
                    const Spacer(),
                    const _Shimmer(width: 50, height: 18),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _Shimmer(width: 120, height: 12),
                const SizedBox(height: AppSpacing.xs),
                const _Shimmer(width: 100, height: 12),
                const SizedBox(height: AppSpacing.xl),
                const _Shimmer(width: 90, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollable list of [PlaceCardSkeleton] widgets.
class PlaceListSkeleton extends StatelessWidget {
  final int count;

  const PlaceListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.listPadding,
      itemCount: count,
      itemBuilder: (_, _) => const PlaceCardSkeleton(),
    );
  }
}

// ─── Booking card skeleton ────────────────────────────────────────────────────

class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.section),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.cardPad,
              AppSpacing.cardPad,
              AppSpacing.cardPad,
              0,
            ),
            child: Row(
              children: const [
                _Shimmer(width: 110, height: 24),
                Spacer(),
                _Shimmer(width: 70, height: 24),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Shimmer(width: 180, height: 18),
                SizedBox(height: AppSpacing.md),
                _Shimmer(width: 120, height: 12),
                SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    _Shimmer(width: 90, height: 28),
                    SizedBox(width: AppSpacing.md),
                    _Shimmer(width: 90, height: 28),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2F8),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.cardLg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollable list of [BookingCardSkeleton] widgets.
class BookingListSkeleton extends StatelessWidget {
  final int count;

  const BookingListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.listPadding,
      itemCount: count,
      itemBuilder: (_, _) => const BookingCardSkeleton(),
    );
  }
}

// ─── Services home skeleton ───────────────────────────────────────────────────

class ServicesHomeSkeleton extends StatelessWidget {
  const ServicesHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.listPadding,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Shimmer(width: 200, height: 20),
          const SizedBox(height: AppSpacing.xl),
          // Horizontal scroll shimmer
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (_, _) => Container(
                width: 220,
                height: 170,
                margin: const EdgeInsets.only(right: AppSpacing.section),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F8),
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.pagePad),
          const _Shimmer(width: 160, height: 20),
          const SizedBox(height: AppSpacing.xl),
          // 2-col grid shimmer
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: AppSpacing.section,
              mainAxisSpacing: AppSpacing.section,
            ),
            itemCount: 8,
            itemBuilder: (_, _) => Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F8),
                borderRadius: BorderRadius.circular(AppRadius.cardLg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
