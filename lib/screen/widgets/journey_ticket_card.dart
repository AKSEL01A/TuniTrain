import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/constants/date_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/core/widgets/info_chip.dart';
import 'package:tuni_train/controller/mon_journee/my_journey_controller.dart';
import 'package:tuni_train/models/purchase/payment_methods.dart';
import 'package:tuni_train/models/purchase/tickets.dart';
import 'package:tuni_train/screen/page/mon_journee/journey_route_screen.dart';
import 'package:tuni_train/screen/page/purchase/tickets/qr_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TICKET CARD
// ─────────────────────────────────────────────────────────────────────────────

class JourneyTicketCard extends StatelessWidget {
  final MyTicket ticket;
  final MyJourneyController ctrl;

  const JourneyTicketCard({
    super.key,
    required this.ticket,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = ctrl.minutesUntilDeparture(ticket) == null;
    final countdownLabel = ctrl.countdownLabel(ticket);
    final countdownColor = ctrl.countdownColor(ticket);

    return Container(
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
      child: Opacity(
        opacity: isPast ? 0.65 : 1.0,
        child: Column(
          children: [
            _TicketTopRow(
              ticket: ticket,
              isPast: isPast,
              countdownLabel: countdownLabel,
              countdownColor: countdownColor,
            ),
            _TicketRouteRow(ticket: ticket, isPast: isPast),
            if (ticket.isRoundTrip && ticket.returnFromStation != null)
              _TicketReturnLeg(ticket: ticket),
            const SizedBox(height: AppSpacing.xxl),
            _TicketDashedDivider(),
            _TicketInfoChips(ticket: ticket, isPast: isPast),
            const SizedBox(height: AppSpacing.xl),
            _TicketCtaBar(ticket: ticket, isPast: isPast),
          ],
        ),
      ),
    );
  }
}

// ─── Top row: line badge + ticket code + countdown ───────────────────────────

class _TicketTopRow extends StatelessWidget {
  final MyTicket ticket;
  final bool isPast;
  final String countdownLabel;
  final Color countdownColor;

  const _TicketTopRow({
    required this.ticket,
    required this.isPast,
    required this.countdownLabel,
    required this.countdownColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.xxl,
        AppSpacing.section,
        0,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs + 1,
            ),
            decoration: BoxDecoration(
              color: isPast ? const Color(0xFFF0F0F0) : AppColors.bluePale,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              ticket.trainLine.isNotEmpty ? ticket.trainLine : 'SNCFT',
              style: GoogleFonts.poppins(
                color: isPast ? Colors.grey : AppColors.blue1,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            ticket.ticketCode,
            style: GoogleFonts.poppins(
              color: AppColors.blue3,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs + 5,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isPast
                  ? const Color(0xFFF0F0F0)
                  : countdownColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Row(
              children: [
                Icon(
                  isPast ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  color: isPast ? Colors.grey : countdownColor,
                  size: 11,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  countdownLabel,
                  style: GoogleFonts.poppins(
                    color: isPast ? Colors.grey : countdownColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

// ─── Route row: departure ←→ arrival ─────────────────────────────────────────

class _TicketRouteRow extends StatelessWidget {
  final MyTicket ticket;
  final bool isPast;

  const _TicketRouteRow({required this.ticket, required this.isPast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.xxl,
        AppSpacing.section,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.departureTime,
                  style: GoogleFonts.poppins(
                    color: isPast ? Colors.grey.shade600 : AppColors.blue1,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  ticket.fromStation,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _RouteMidSection(ticket: ticket, isPast: isPast),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ticket.arrivalTime,
                  style: GoogleFonts.poppins(
                    color: isPast ? Colors.grey.shade600 : AppColors.blue1,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  ticket.toStation,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
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

class _RouteMidSection extends StatelessWidget {
  final MyTicket ticket;
  final bool isPast;

  const _RouteMidSection({required this.ticket, required this.isPast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isPast ? const Color(0xFFF0F0F0) : AppColors.sandBg,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Text(
            formatFrDate(ticket.travelDate),
            style: GoogleFonts.poppins(
              color: isPast ? Colors.grey : AppColors.sand,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _dot(isPast),
            _line(isPast),
            Icon(
              Icons.train_rounded,
              color: isPast ? Colors.grey.shade400 : AppColors.blue2,
              size: AppSizes.iconMd,
            ),
            _line(isPast),
            _dot(isPast),
          ],
        ),
      ],
    );
  }

  Widget _dot(bool isPast) => Container(
    width: 4,
    height: 4,
    decoration: BoxDecoration(
      color: isPast ? Colors.grey.shade300 : AppColors.blue3,
      shape: BoxShape.circle,
    ),
  );

  Widget _line(bool isPast) => Container(
    width: 26,
    height: 1,
    color: isPast ? Colors.grey.shade200 : const Color(0xFFB0C8E8),
  );
}

// ─── Return leg banner ───────────────────────────────────────────────────────

class _TicketReturnLeg extends StatelessWidget {
  final MyTicket ticket;

  const _TicketReturnLeg({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.section,
        AppSpacing.lg,
        AppSpacing.section,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.sand.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.replay_circle_filled_rounded,
              color: Color(0xFFE65100),
              size: 14,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Retour: ${ticket.returnDepartureTime ?? '--'} · '
                '${ticket.returnFromStation} → ${ticket.returnToStation}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE65100),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (ticket.returnDate != null)
              Text(
                formatFrDate(ticket.returnDate!),
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE65100),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashed divider ──────────────────────────────────────────────────────────

class _TicketDashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.section),
      child: LayoutBuilder(
        builder: (_, c) {
          final n = (c.maxWidth / 8).floor();
          return Row(
            children: List.generate(
              n,
              (_) => Expanded(
                child: Container(
                  height: 1,
                  color: (n % 2 == 0)
                      ? const Color(0xFFDDE6F5)
                      : Colors.transparent,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Info chips: class / passengers / price / payment ────────────────────────

class _TicketInfoChips extends StatelessWidget {
  final MyTicket ticket;
  final bool isPast;

  const _TicketInfoChips({required this.ticket, required this.isPast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InfoChip(
            icon: Icons.airline_seat_recline_extra_rounded,
            label: 'CLASSE',
            value: ticket.ticketClass == '1st' ? '1ère CL' : '2ème CL',
            color: AppColors.blue1,
            background: AppColors.bluePale,
            muted: isPast,
          ),
          const InfoChipDivider(),
          InfoChip(
            icon: Icons.people_alt_rounded,
            label: 'PASSAGERS',
            value: '${ticket.passengers}',
            color: AppColors.green,
            background: AppColors.greenBg,
            muted: isPast,
          ),
          const InfoChipDivider(),
          InfoChip(
            icon: Icons.monetization_on_rounded,
            label: 'PRIX',
            value: '${ticket.totalPrice.toStringAsFixed(3)} DT',
            color: AppColors.sand,
            background: AppColors.sandBg,
            muted: isPast,
          ),
          const InfoChipDivider(),
          InfoChip(
            icon: PaymentMethods.icon(ticket.paymentMethod),
            label: 'PAIEMENT',
            value: PaymentMethods.label(ticket.paymentMethod),
            color: PaymentMethods.chipColor,
            background: PaymentMethods.chipBg,
            muted: isPast,
          ),
        ],
      ),
    );
  }
}

// ─── CTA bar: view QR / view route ───────────────────────────────────────────

class _TicketCtaBar extends StatelessWidget {
  final MyTicket ticket;
  final bool isPast;

  const _TicketCtaBar({required this.ticket, required this.isPast});

  @override
  Widget build(BuildContext context) {
    if (isPast) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F0F0),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppRadius.cardLg),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPad,
          vertical: AppSpacing.xl,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.grey,
              size: 15,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Voyage terminé',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.cardLg),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPad,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // View ticket QR
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(
                () => QrTicketScreen(directTicket: ticket),
                transition: Transition.downToUp,
                duration: AppDurations.navigation,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_rounded,
                    color: Colors.white,
                    size: AppSizes.iconSm + 2,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Voir le billet',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: 1,
            height: 22,
            color: Colors.white.withValues(alpha: 0.25),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          ),

          // View route
          GestureDetector(
            onTap: () => Get.to(
              () => JourneyRouteScreen(ticket: ticket),
              transition: Transition.rightToLeft,
              duration: AppDurations.navigation,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.route_rounded,
                  color: Colors.white70,
                  size: AppSizes.iconSm,
                ),
                const SizedBox(width: AppSpacing.xs + 1),
                Text(
                  'Voir Votre Trajet',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white54,
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
