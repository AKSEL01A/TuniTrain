import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tuni_train/core/constants/app_constants.dart';
import 'package:tuni_train/core/theme/app_colors.dart';
import 'package:tuni_train/core/widgets/custom_button.dart';

/// Generic centred empty-state widget with an icon, title, body text,
/// and an optional primary action button.
///
/// Used for journey tabs, subscription list, and error/no-data screens.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String body;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor = AppColors.blue3,
    this.iconBackground = AppColors.bluePale,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSizes.emptyIconSize,
              height: AppSizes.emptyIconSize,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(AppRadius.avatar),
              ),
              child: Icon(icon, color: iconColor, size: 50),
            ),
            const SizedBox(height: AppSpacing.pagePad),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.blue3,
                fontSize: 13,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl * 2),
              AppGradientButton(
                label: actionLabel!,
                icon: actionIcon,
                onTap: onAction,
                height: 46,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a wifi-off icon, error message, and retry button.
class AppErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;
  final String retryLabel;

  const AppErrorState({
    super.key,
    this.message = 'Vérifiez votre connexion et réessayez.',
    this.onRetry,
    this.retryLabel = 'Réessayer',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.redBg,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.red,
                size: 44,
              ),
            ),
            const SizedBox(height: AppSpacing.pagePad),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl * 2),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: AppSpacing.buttonPadding,
                  decoration: BoxDecoration(
                    color: AppColors.blue1,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    retryLabel,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
