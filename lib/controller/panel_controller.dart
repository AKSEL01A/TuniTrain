import 'package:get/get.dart';
import 'package:tuni_train/controller/search_train_controller.dart';
import 'package:tuni_train/data/zone_pricing.dart';
import 'package:tuni_train/models/train.dart';
import 'package:tuni_train/models/train_journey.dart';

class PanelController extends GetxController {
  final SearchTrainController searchCtrl = Get.find<SearchTrainController>();

  // ─────────────────────────────
  // TICKETS
  // ─────────────────────────────
  Rxn<TrainJourney> journeyAller = Rxn<TrainJourney>();
  Rxn<Train> trainAller = Rxn<Train>();
  Rxn<TrainJourney> journeyRetour = Rxn<TrainJourney>();
  Rxn<Train> trainRetour = Rxn<Train>();

  Rxn<TrainJourney> get journey => journeyAller;
  Rxn<Train> get train => trainAller;

  // ─────────────────────────────
  // SELECTIONS
  // ─────────────────────────────
  RxString selectedClass = "2nd".obs;
  RxString selectedOffer = "ORDINAIRE".obs;
  RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _syncFromSearch();
    _calculatePrice();
  }

  void _syncFromSearch() {
    journeyAller.value = searchCtrl.selectedAller.value;
    trainAller.value = searchCtrl.selectedTrain.value;
    journeyRetour.value = searchCtrl.selectedRetour.value;
    if (journeyRetour.value != null) {
      trainRetour.value = searchCtrl.getTrainById(journeyRetour.value!.trainId);
    }
  }

  void refresh() {
    _syncFromSearch();
    _calculatePrice();
  }

  int get totalPassengers => searchCtrl.totalPassengers;
  bool get hasAller => journeyAller.value != null;
  bool get hasRetour => journeyRetour.value != null;

  // ─────────────────────────────
  // DURATION
  // ─────────────────────────────
  String get durationAllerText {
    if (journeyAller.value == null) return "--";
    return searchCtrl.calcDuration(
      journeyAller.value!.departureTime,
      journeyAller.value!.arrivalTime,
    );
  }

  String get durationRetourText {
    if (journeyRetour.value == null) return "--";
    return searchCtrl.calcDuration(
      journeyRetour.value!.departureTime,
      journeyRetour.value!.arrivalTime,
    );
  }

  String get durationText => durationAllerText;

  // ─────────────────────────────
  // CLASS / OFFER
  // ─────────────────────────────
  void selectClass(String value) {
    selectedClass.value = value;
    _calculatePrice();
  }

  void selectOffer(String value) {
    selectedOffer.value = value;
    _calculatePrice();
  }

  // ─────────────────────────────
  // 🔥 ZONE-BASED PRICE CALC
  // ─────────────────────────────
  void _calculatePrice() {
    double total = 0.0;

    if (hasAller) {
      double base = ZonePricing.calcBasePrice(
        journeyAller.value!.fromStation,
        journeyAller.value!.toStation,
      );
      total += _applyModifiers(base);
    }

    if (hasRetour) {
      double base = ZonePricing.calcBasePrice(
        journeyRetour.value!.fromStation,
        journeyRetour.value!.toStation,
      );
      total += _applyModifiers(base);
    }

    if (total == 0.0 && hasAller) total = 0.800;
    totalPrice.value = total;
  }

  double _applyModifiers(double base) {
    double price = base;

    // Class modifier
    if (selectedClass.value == '1st') {
      price += 1.500;
    }

    // Offer modifier
    if (selectedOffer.value == 'JEUNE') {
      price *= 0.8;
    } else if (selectedOffer.value == 'ENFANT') {
      price *= 0.5;
    }

    // Multiply by passengers
    price *= totalPassengers;
    return price;
  }

  // ─────────────────────────────
  // DELETE
  // ─────────────────────────────
  void deleteAllerTicket() {
    journeyAller.value = null;
    trainAller.value = null;
    searchCtrl.selectedAller.value = null;
    searchCtrl.selectedTrain.value = null;
    deleteRetourTicket();
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

  void deleteTicket() => deleteAllerTicket();

  // ─────────────────────────────
  // PAYMENT
  // ─────────────────────────────
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
