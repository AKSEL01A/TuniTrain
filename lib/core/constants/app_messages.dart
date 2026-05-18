library;

/// Centralised UI strings — titles and bodies for snackbars, empty states,
/// and error feedback shown across the app.
///
/// Keeping strings here makes future localisation (intl / easy_localization)
/// a one-file change instead of a project-wide grep.
abstract final class AppMessages {
  // ── Generic ───────────────────────────────────────────────────────────────
  static const String error = 'Erreur';
  static const String warning = 'Attention';
  static const String retry = 'Réessayer';
  static const String unexpectedError = 'Une erreur inattendue est survenue.';
  static const String networkError = 'Vérifiez votre connexion et réessayez.';
  static const String loadingError = 'Erreur de chargement';

  // ── Location ──────────────────────────────────────────────────────────────
  static const String locationPermissionTitle = 'Permission refusée';
  static const String locationPermissionBody =
      'Activez la localisation dans les paramètres';

  // ── Search / Train ────────────────────────────────────────────────────────
  static const String selectDateTime = 'Sélectionnez la date et l\'heure';
  static const String selectStations = 'Choisissez les stations';
  static const String noTrainsTitle = 'Aucun train';
  static const String noTrainsBody = 'Aucun trajet disponible';

  // ── Ticket ────────────────────────────────────────────────────────────────
  static const String ticketCancelledTitle = 'Billet annulé';
  static const String ticketCancellationError =
      'Impossible d\'annuler le billet.';
  static const String emptyTicketsActive = 'Aucun voyage à venir';
  static const String emptyTicketsActiveBody =
      'Réservez votre prochain train\npour le voir ici.';
  static const String emptyTicketsPast = 'Aucun voyage passé';
  static const String emptyTicketsPastBody =
      'Vos trajets terminés\napparaîtront ici.';

  // ── Subscription / Panel ──────────────────────────────────────────────────
  static const String stepIncompleteTitle = 'Attention';
  static const String stepIncompleteBody = 'Veuillez compléter cette étape';
  static const String subscriptionCreated = 'Abonnement créé';
  static const String noTicketTitle = 'Aucun billet';
  static const String selectOneTicketBody =
      'Sélectionnez au moins un train aller.';
  static const String emptySubscriptions = 'Aucun abonnement';
  static const String emptySubscriptionsBody =
      'Souscrivez à un abonnement\npour voyager librement.';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String fillAllFields = 'Fill all fields';
  static const String loginError = 'Login Error';
  static const String googleLoginError = 'Google Login Error';

  // ── Map ───────────────────────────────────────────────────────────────────
  static const String noTimetable = 'Aucun horaire disponible';
  static const String loadingMap = 'Chargement de la carte…';
}
