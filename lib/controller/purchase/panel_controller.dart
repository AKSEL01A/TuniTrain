import 'package:get/get.dart';
import 'package:tuni_train/controller/trains/search_train_controller.dart';
import 'package:tuni_train/data/firestore_service.dart';
import 'package:tuni_train/models/trains/train.dart';
import 'package:tuni_train/models/trains/train_journey.dart';

class PanelController extends GetxController {
  final SearchTrainController searchCtrl = Get.find<SearchTrainController>();

  // ───────── ALLER ticket ─────────
  Rxn<TrainJourney> journeyAller = Rxn<TrainJourney>();
  Rxn<Train> trainAller = Rxn<Train>();

  // ───────── RETOUR ticket ─────────
  Rxn<TrainJourney> journeyRetour = Rxn<TrainJourney>();
  Rxn<Train> trainRetour = Rxn<Train>();

  // Legacy getters (keep panel_page.dart working without changes)
  Rxn<TrainJourney> get journey => journeyAller;
  Rxn<Train> get train => trainAller;

  // ───────── SELECTIONS ─────────
  RxString selectedClass = "2nd".obs; // "2nd" | "1st"
  RxString selectedOffer = "ORDINAIRE".obs;

  // ───────── PRICE ─────────
  RxDouble totalPrice = 0.0.obs;

  // Class multiplier  (1st class costs 1.6× 2nd class — adjust as needed)
  static const double _firstClassMultiplier = 1.6;

  @override
  void onInit() {
    super.onInit();
    _syncFromSearch();
    _calculatePrice();
  }

  // ─────────────────────────────
  // SYNC from SearchTrainController every time panel becomes visible
  // ─────────────────────────────
  void _syncFromSearch() {
    journeyAller.value = searchCtrl.selectedAller.value;
    trainAller.value = searchCtrl.selectedTrain.value;

    journeyRetour.value = searchCtrl.selectedRetour.value;
    if (journeyRetour.value != null) {
      trainRetour.value = searchCtrl.getTrainById(journeyRetour.value!.trainId);
    }
  }

  /// Call this when PanelPage is pushed / becomes visible after retour select
  @override
  void refresh() {
    _syncFromSearch();
    _calculatePrice();
  }

  // ─────────────────────────────
  // COMPUTED HELPERS
  // ─────────────────────────────
  int get totalPassengers =>
      searchCtrl.adults.value +
      searchCtrl.children.value +
      searchCtrl.babies.value;

  bool get hasAller => journeyAller.value != null;
  bool get hasRetour => journeyRetour.value != null;

  String get durationAllerText {
    if (!hasAller) return "--";
    return searchCtrl.calcDuration(
      journeyAller.value!.departureTime,
      journeyAller.value!.arrivalTime,
    );
  }

  String get durationRetourText {
    if (!hasRetour) return "--";
    return searchCtrl.calcDuration(
      journeyRetour.value!.departureTime,
      journeyRetour.value!.arrivalTime,
    );
  }

  // Legacy — used by old panel_page references
  String get durationText => durationAllerText;

  // ─────────────────────────────
  // BASE PRICE per ticket (2nd class)
  // ─────────────────────────────

  /// Price for the aller leg (2nd class, 1 passenger)
  double get allerBasePrice {
    final j = journeyAller.value;
    if (j == null) return 0.0;
    // Use price stored on the journey (set by FirestoreService.calculatePrice)
    if (j.ticketPrice > 0) return j.ticketPrice;
    // Fallback: recalculate on the fly
    return FirestoreService.calculatePrice(j.fromStation, j.toStation);
  }

  /// Price for the retour leg (2nd class, 1 passenger)
  double get retourBasePrice {
    final j = journeyRetour.value;
    if (j == null) return 0.0;
    if (j.ticketPrice > 0) return j.ticketPrice;
    // Return journey is the reverse route → same zone diff → same price
    return FirestoreService.calculatePrice(j.fromStation, j.toStation);
  }

  // Price per passenger per leg for the selected class
  double _priceForClass(double basePrice) {
    return selectedClass.value == '1st'
        ? basePrice * _firstClassMultiplier
        : basePrice;
  }

  // ─────────────────────────────
  // CALCULATE TOTAL PRICE
  // ─────────────────────────────
  void _calculatePrice() {
    double total = 0.0;

    if (hasAller) {
      total += _priceForClass(allerBasePrice) * totalPassengers;
    }
    if (hasRetour) {
      total += _priceForClass(retourBasePrice) * totalPassengers;
    }

    // If nothing selected yet, show the aller base price as preview
    if (total == 0.0 && hasAller) {
      total = _priceForClass(allerBasePrice) * totalPassengers;
    }

    totalPrice.value = total;
  }

  // ─────────────────────────────
  // PRICE LABEL HELPERS  (for UI display)
  // ─────────────────────────────

  /// Price string for aller chip in the result list card
  String get allerPriceLabel {
    final p = allerBasePrice;
    return p > 0 ? '${p.toStringAsFixed(3)} DT' : '—';
  }

  /// Price string for retour chip
  String get retourPriceLabel {
    final p = retourBasePrice;
    return p > 0 ? '${p.toStringAsFixed(3)} DT' : '—';
  }

  // ─────────────────────────────
  // ACTIONS
  // ─────────────────────────────
  void selectClass(String value) {
    selectedClass.value = value;
    _calculatePrice();
  }

  void selectOffer(String value) {
    selectedOffer.value = value;
    _calculatePrice();
  }

  void deleteAllerTicket() {
    journeyAller.value = null;
    trainAller.value = null;
    searchCtrl.selectedAller.value = null;
    searchCtrl.selectedTrain.value = null;
    // Aller required → also wipe retour
    deleteRetourTicket();
    // Reset booking flow
    searchCtrl.bookingStep.value = 'ALLER';
    searchCtrl.searchMode.value = 'ALLER';
    _calculatePrice();
  }

  void deleteRetourTicket() {
    journeyRetour.value = null;
    trainRetour.value = null;
    searchCtrl.selectedRetour.value = null;
    _calculatePrice();
  }

  // Legacy — kept for old AppBar trash icon
  void deleteTicket() => deleteAllerTicket();

  void proceedToPayment() {
    if (!hasAller) {
      Get.snackbar(
        'Aucun billet',
        'Sélectionnez au moins un train aller.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed('/payment');
  }
}
