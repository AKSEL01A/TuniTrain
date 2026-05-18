import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/constants/date_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/models/services/booking.dart';

/// Full booking list card shown in My Bookings page.
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPast = booking.isPast;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isPast ? 0.75 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.section),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.cardLg),
            boxShadow: [
              BoxShadow(
                color: isPast
                    ? Colors.black.withValues(alpha: 0.04)
                    : AppColors.blue1.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              _BookingCardHeader(booking: booking),
              _BookingCardBody(booking: booking),
              _BookingCardFooter(booking: booking),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCardHeader extends StatelessWidget {
  final Booking booking;

  const _BookingCardHeader({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPad,
        AppSpacing.cardPad,
        AppSpacing.cardPad,
        0,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              booking.type.label,
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          BookingStatusChip(status: booking.status),
        ],
      ),
    );
  }
}

class _BookingCardBody extends StatelessWidget {
  final Booking booking;

  const _BookingCardBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    final title =
        booking.serviceDetails['vehicle'] as String? ??
        booking.serviceDetails['place'] as String? ??
        booking.type.label;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPad,
        AppSpacing.xl,
        AppSpacing.cardPad,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.blue1,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Réf: ${booking.reference}',
            style: GoogleFonts.poppins(
              color: AppColors.blue3,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _infoChip(
                Icons.calendar_today_rounded,
                formatFrDate(booking.startDate),
                AppColors.bluePale,
                AppColors.blue2,
              ),
              const SizedBox(width: AppSpacing.md),
              if (booking.endDate != booking.startDate)
                _infoChip(
                  Icons.event_rounded,
                  formatFrDate(booking.endDate),
                  AppColors.sandBg,
                  AppColors.sand,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCardFooter extends StatelessWidget {
  final Booking booking;

  const _BookingCardFooter({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xl),
      decoration: BoxDecoration(
        color: booking.isActive ? AppColors.blue1 : const Color(0xFFF5F5F5),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.cardLg),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPad,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          Text(
            '${booking.totalPrice.toStringAsFixed(3)} DT',
            style: GoogleFonts.poppins(
              color: booking.isActive ? Colors.white : AppColors.blue3,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (booking.isActive)
            Row(
              children: [
                const Icon(
                  Icons.qr_code_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Voir le billet',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            Text(
              booking.status.label,
              style: GoogleFonts.poppins(
                color: AppColors.blue3,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact colored status badge used in booking cards and detail pages.
class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusChip({super.key, required this.status});

  Color get _bg => switch (status) {
    BookingStatus.confirmed => AppColors.greenBg,
    BookingStatus.pending => AppColors.sandBg,
    BookingStatus.cancelled => AppColors.redBg,
    BookingStatus.completed => AppColors.bluePale,
    BookingStatus.expired => const Color(0xFFF0F0F0),
  };

  Color get _fg => switch (status) {
    BookingStatus.confirmed => AppColors.green,
    BookingStatus.pending => AppColors.sand,
    BookingStatus.cancelled => AppColors.red,
    BookingStatus.completed => AppColors.blue2,
    BookingStatus.expired => AppColors.blue3,
  };

  IconData get _icon => switch (status) {
    BookingStatus.confirmed => Icons.check_circle_rounded,
    BookingStatus.pending => Icons.schedule_rounded,
    BookingStatus.cancelled => Icons.cancel_rounded,
    BookingStatus.completed => Icons.done_all_rounded,
    BookingStatus.expired => Icons.timer_off_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11, color: _fg),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.label,
            style: GoogleFonts.poppins(
              color: _fg,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
