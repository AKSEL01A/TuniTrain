import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/controller/purchase/services/place_controller.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/place.dart';
import 'package:tuni_train/screen/widgets/service_section_header.dart';

class PlaceDetailPage extends StatelessWidget {
  PlaceDetailPage({super.key});

  final PlaceController ctrl = Get.find<PlaceController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final place = ctrl.selectedPlace.value;
      if (place == null) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.blue1),
          ),
        );
      }
      return _PlaceDetailScaffold(place: place, ctrl: ctrl);
    });
  }
}

class _PlaceDetailScaffold extends StatelessWidget {
  final Place place;
  final PlaceController ctrl;

  const _PlaceDetailScaffold({required this.place, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          _PlaceDetailAppBar(place: place, ctrl: ctrl),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _PlaceDetailTitle(place: place),
                if (place.description.isNotEmpty)
                  _PlaceDescriptionCard(place: place),
                _PlaceInfoCard(place: place),
                if (place.tags.isNotEmpty) _PlaceTagsCard(place: place),
                _PlaceMapCard(place: place),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _PlaceDetailCTA(place: place),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _PlaceDetailAppBar extends StatelessWidget {
  final Place place;
  final PlaceController ctrl;

  const _PlaceDetailAppBar({required this.place, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.blue1,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Obx(
            () => GestureDetector(
              onTap: () => ctrl.toggleFavorite(place.id),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  ctrl.isFavorite(place.id)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: ctrl.isFavorite(place.id)
                      ? AppColors.red
                      : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            place.imageUrls.isNotEmpty
                ? Image.network(
                    place.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.bluePale,
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        size: 48,
                        color: AppColors.blue3,
                      ),
                    ),
                  )
                : Container(color: AppColors.bluePale),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Title card ───────────────────────────────────────────────────────────────

class _PlaceDetailTitle extends StatelessWidget {
  final Place place;

  const _PlaceDetailTitle({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.section,
        AppSpacing.section,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue1.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if ((place.price ?? 0) > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      place.price!.toStringAsFixed(3),
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'DT / entrée',
                      style: GoogleFonts.poppins(
                        color: AppColors.blue3,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    'GRATUIT',
                    style: GoogleFonts.poppins(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.place_rounded, size: 14, color: AppColors.blue3),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  place.location,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              StarRatingWidget(
                rating: place.rating,
                reviewsCount: place.reviewsCount,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bluePale,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  place.category.label,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (place.isRecommended) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.sandBg,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.thumb_up_rounded,
                    size: 11,
                    color: AppColors.sand,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Recommandé',
                    style: GoogleFonts.poppins(
                      color: AppColors.sand,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (place.promotionText != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    size: 11,
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    place.promotionText!,
                    style: GoogleFonts.poppins(
                      color: AppColors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Description ──────────────────────────────────────────────────────────────

class _PlaceDescriptionCard extends StatelessWidget {
  final Place place;

  const _PlaceDescriptionCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.section,
        AppSpacing.section,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À propos',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            place.description,
            style: GoogleFonts.poppins(
              color: AppColors.blue2,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _PlaceInfoCard extends StatelessWidget {
  final Place place;

  const _PlaceInfoCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.section,
        AppSpacing.section,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (place.openingHours != null)
            _infoRow(Icons.schedule_rounded, 'Horaires', place.openingHours!),
          if (place.phone != null)
            _infoRow(Icons.phone_rounded, 'Téléphone', place.phone!),
          if (place.email != null)
            _infoRow(Icons.email_rounded, 'Email', place.email!),
          if (place.externalLink != null)
            _infoRow(Icons.link_rounded, 'Site web', place.externalLink!),
          if (place.socialInstagram != null)
            _infoRow(
              Icons.camera_alt_rounded,
              'Instagram',
              place.socialInstagram!,
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, size: 16, color: AppColors.blue1),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tags Card ────────────────────────────────────────────────────────────────

class _PlaceTagsCard extends StatelessWidget {
  final Place place;

  const _PlaceTagsCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.section,
        AppSpacing.section,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: place.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bluePale,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '#$tag',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue2,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Map placeholder ──────────────────────────────────────────────────────────

class _PlaceMapCard extends StatelessWidget {
  final Place place;

  const _PlaceMapCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.section,
        AppSpacing.section,
        0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.cardPad,
              AppSpacing.cardPad,
              AppSpacing.cardPad,
              AppSpacing.xl,
            ),
            child: Text(
              'Localisation',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            height: 160,
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.cardPad,
              0,
              AppSpacing.cardPad,
              AppSpacing.cardPad,
            ),
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.map_rounded, size: 48, color: AppColors.blue3),
                Positioned(
                  bottom: AppSpacing.xl,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue1,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      place.location,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CTA ─────────────────────────────────────────────────────────────────────

class _PlaceDetailCTA extends StatelessWidget {
  final Place place;

  const _PlaceDetailCTA({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.xl,
        AppSpacing.section,
        AppSpacing.xl + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if ((place.price ?? 0) > 0) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix d\'entrée',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${place.price!.toStringAsFixed(3)} DT',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue1,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.section),
          ],
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: AppSizes.buttonHeight,
                decoration: BoxDecoration(
                  gradient: AppColors.ctaGradient,
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue1.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    place.isTicketingEnabled
                        ? 'Réserver un billet'
                        : 'Plus d\'infos',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
