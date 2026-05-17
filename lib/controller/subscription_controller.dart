import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuni_train/models/station.dart';
import 'package:tuni_train/models/subscription.dart';
import 'package:tuni_train/models/train_line.dart';

// ── Plan model from Firestore ─────────────────────────────────────────────────
class SubscriptionPlan {
  final String id;
  final String type;
  final double price;
  final double studentPrice;
  final String label;
  final String duration;
  final String description;

  const SubscriptionPlan({
    required this.id,
    required this.type,
    required this.price,
    required this.studentPrice,
    required this.label,
    required this.duration,
    required this.description,
  });

  factory SubscriptionPlan.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return SubscriptionPlan(
      id: doc.id,
      type: m['type'] ?? '',
      price: (m['price'] as num?)?.toDouble() ?? 0,
      studentPrice: (m['studentPrice'] as num?)?.toDouble() ?? 0,
      label: m['label'] ?? '',
      duration: m['duration'] ?? '',
      description: m['description'] ?? '',
    );
  }

  SubscriptionType get subscriptionType {
    switch (type) {
      case 'weekly':
        return SubscriptionType.weekly;
      case 'annual':
        return SubscriptionType.annual;
      default:
        return SubscriptionType.monthly;
    }
  }

  double priceFor(bool isStudent) => isStudent ? studentPrice : price;
}

class SubscriptionController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // ── Loading ───────────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool purchaseSuccess = false.obs;
  final Rx<String?> error = Rx<String?>(null);

  // ── Firestore data ────────────────────────────────────────────────────────
  final RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;
  final RxList<TrainLine> lines = <TrainLine>[].obs;
  final RxList<Station> stations = <Station>[].obs;

  // ── Saved sub info ────────────────────────────────────────────────────────
  final RxString savedSubId = ''.obs;
  final RxString savedQrCode = ''.obs;

  // ── Step ──────────────────────────────────────────────────────────────────
  final RxInt currentStep = 0.obs;

  // ── Selections ────────────────────────────────────────────────────────────
  final Rxn<SubscriptionPlan> selectedPlan = Rxn<SubscriptionPlan>();
  final RxBool isStudent = false.obs;
  final Rxn<TrainLine> selectedLine = Rxn<TrainLine>();
  final Rxn<Station> fromStation = Rxn<Station>();
  final Rxn<Station> toStation = Rxn<Station>();

  // ── User photo (base64) ───────────────────────────────────────────────────
  final Rxn<File> userPhotoFile = Rxn<File>();
  final RxString userPhotoBase64 = ''.obs;

  // ── Personal ──────────────────────────────────────────────────────────────
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController universityCtrl = TextEditingController();
  final TextEditingController studentIdCtrl = TextEditingController();

  // ── Rotating QR (refreshes every 30s) ────────────────────────────────────
  final RxString liveQrCode = ''.obs;
  Timer? _qrTimer;

  // ── Computed ──────────────────────────────────────────────────────────────
  List<Station> get filteredStations {
    final line = selectedLine.value;
    if (line == null) return stations.toList();
    return stations
        .where(
          (s) => line.stations.contains(s.name) || s.lineIds.contains(line.id),
        )
        .toList()
      ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
  }

  double get currentPrice => selectedPlan.value?.priceFor(isStudent.value) ?? 0;

  bool get canGoNext {
    switch (currentStep.value) {
      case 0:
        return selectedPlan.value != null;
      case 1:
        return selectedLine.value != null;
      case 2:
        return fromStation.value != null && toStation.value != null;
      case 3:
        if (firstNameCtrl.text.isEmpty ||
            lastNameCtrl.text.isEmpty ||
            emailCtrl.text.isEmpty)
          return false;
        if (isStudent.value && universityCtrl.text.isEmpty) return false;
        return true;
      default:
        return true;
    }
  }

  String get typeName => selectedPlan.value?.label ?? '';
  String get durationLabel => selectedPlan.value?.duration ?? '';
  SubscriptionType get selectedType =>
      selectedPlan.value?.subscriptionType ?? SubscriptionType.monthly;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _prefillUserInfo();
  }

  @override
  void onClose() {
    _qrTimer?.cancel();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    universityCtrl.dispose();
    studentIdCtrl.dispose();
    super.onClose();
  }

  // ── Firestore load ────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _db.collection('subscriptionPlans').orderBy('order').get(),
        _db.collection('trainLines').get(),
        _db.collection('stations').orderBy('stopOrder').get(),
      ]);

      plans.value = results[0].docs
          .map((d) => SubscriptionPlan.fromFirestore(d))
          .toList();
      if (plans.isEmpty) _fallbackPlans();

      lines.value = results[1].docs
          .map((d) => TrainLine.fromFirestore(d))
          .where((l) => l.isActive)
          .toList();

      stations.value = results[2].docs
          .map((d) => Station.fromFirestore(d))
          .where((s) => s.isActive)
          .toList();
    } catch (e) {
      debugPrint('🚨 Load: $e');
      _fallbackPlans();
    } finally {
      isLoading.value = false;
    }
  }

  void _fallbackPlans() {
    plans.value = [
      const SubscriptionPlan(
        id: 'weekly',
        type: 'weekly',
        price: 8.0,
        studentPrice: 4.0,
        label: 'Hebdomadaire',
        duration: '7 jours',
        description: 'Voyages illimités 7 jours',
      ),
      const SubscriptionPlan(
        id: 'monthly',
        type: 'monthly',
        price: 28.0,
        studentPrice: 14.0,
        label: 'Mensuel',
        duration: '1 mois',
        description: 'Voyages illimités 1 mois',
      ),
      const SubscriptionPlan(
        id: 'annual',
        type: 'annual',
        price: 280.0,
        studentPrice: 140.0,
        label: 'Annuel',
        duration: '1 an',
        description: 'Voyages illimités 1 an',
      ),
    ];
  }

  void _prefillUserInfo() {
    final user = _auth.currentUser;
    if (user == null) return;
    emailCtrl.text = user.email ?? '';
    final parts = (user.displayName ?? '').split(' ');
    if (parts.isNotEmpty) firstNameCtrl.text = parts.first;
    if (parts.length > 1) lastNameCtrl.text = parts.sublist(1).join(' ');
  }

  // ── Photo picker → base64 ─────────────────────────────────────────────────
  Future<void> pickUserPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 400,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      userPhotoFile.value = file;
      userPhotoBase64.value = base64Encode(bytes);
      debugPrint('📸 Photo encoded: ${userPhotoBase64.value.length} chars');
    } catch (e) {
      debugPrint('📸 Pick error: $e');
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void nextStep() {
    if (!canGoNext) {
      Get.snackbar(
        'Attention',
        'Veuillez compléter cette étape',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (currentStep.value < 4) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goToStep(int step) {
    if (step <= currentStep.value) currentStep.value = step;
  }

  // ── Selections ────────────────────────────────────────────────────────────
  void selectPlan(SubscriptionPlan plan) => selectedPlan.value = plan;
  void toggleStudent() => isStudent.value = !isStudent.value;

  void selectLine(TrainLine line) {
    selectedLine.value = line;
    fromStation.value = null;
    toStation.value = null;
  }

  void selectFromStation(Station s) {
    fromStation.value = s;
    if (toStation.value?.id == s.id) toStation.value = null;
  }

  void selectToStation(Station s) => toStation.value = s;

  // ── Purchase → saves to "abonnements" ────────────────────────────────────
  Future<void> purchase() async {
    isSaving.value = true;
    error.value = null;
    try {
      final user = _auth.currentUser;
      final userId = user?.uid ?? 'guest';
      final now = DateTime.now();
      final type = selectedType;
      final endDate = Subscription.endDateFor(type, now);
      final baseQr = _buildBaseQr(userId, now);

      final status = isStudent.value
          ? SubscriptionStatus.pending
          : SubscriptionStatus.active;

      final Map<String, dynamic> doc = {
        // Identity
        'userId': userId,
        'firstName': firstNameCtrl.text.trim(),
        'lastName': lastNameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phoneNumber': phoneCtrl.text.trim(),

        // Photo stored as base64 string
        'photoBase64': userPhotoBase64.value,

        // Plan
        'planId': selectedPlan.value!.id,
        'type': type.name,
        'label': typeName,
        'duration': durationLabel,
        'price': currentPrice,

        // Status
        'status': status.name,
        'isStudent': isStudent.value,

        // Student
        if (isStudent.value) ...{
          'university': universityCtrl.text.trim(),
          'studentId': studentIdCtrl.text.trim(),
        },

        // Route
        'lineId': selectedLine.value!.id,
        'lineName': selectedLine.value!.name,
        'fromStation': fromStation.value!.name,
        'toStation': toStation.value!.name,

        // Validity
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endDate),

        // QR — base token stored, UI generates rotating code from it
        'qrBaseToken': baseQr,

        // Metadata
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _db.collection('abonnements').add(doc);
      savedSubId.value = docRef.id;
      savedQrCode.value = baseQr;

      // Start the rotating QR timer
      _startQrRotation(docRef.id, baseQr);

      debugPrint('✅ abonnements/${docRef.id} | status: ${status.name}');
      purchaseSuccess.value = true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ── Rotating QR logic ─────────────────────────────────────────────────────
  // Format: BASE_TOKEN|TIMESTAMP_SLOT|HMAC
  // Changes every 30 seconds. Controller verifies by checking slot ±1.
  String _buildBaseQr(String userId, DateTime now) {
    final rand = Random().nextInt(9999999).toString().padLeft(7, '0');
    return 'SUB-$userId-${now.millisecondsSinceEpoch}-$rand';
  }

  String _generateRotatingQr(String subId, String baseToken) {
    // 30-second slot: each slot has a unique index
    final slot = DateTime.now().millisecondsSinceEpoch ~/ 30000;
    final payload = '$subId|$baseToken|$slot';
    // Simple hash for demo — in production use HMAC-SHA256
    final hash = payload.hashCode.abs().toRadixString(16).padLeft(8, '0');
    return 'TUNITRAIN|$subId|$slot|$hash';
  }

  void _startQrRotation(String subId, String baseToken) {
    // Generate immediately
    liveQrCode.value = _generateRotatingQr(subId, baseToken);

    // Refresh every 30 seconds
    _qrTimer?.cancel();
    _qrTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      liveQrCode.value = _generateRotatingQr(subId, baseToken);
      debugPrint('🔄 QR rotated: ${liveQrCode.value.substring(0, 30)}…');
    });
  }

  // Call this when reopening an existing subscription (from MyJourneyPage)
  void resumeQrRotation(String subId, String baseToken) {
    _startQrRotation(subId, baseToken);
  }

  void stopQrRotation() {
    _qrTimer?.cancel();
    liveQrCode.value = '';
  }

  void reset() {
    _qrTimer?.cancel();
    currentStep.value = 0;
    selectedPlan.value = null;
    isStudent.value = false;
    selectedLine.value = null;
    fromStation.value = null;
    toStation.value = null;
    purchaseSuccess.value = false;
    savedSubId.value = '';
    savedQrCode.value = '';
    liveQrCode.value = '';
    userPhotoFile.value = null;
    userPhotoBase64.value = '';
    firstNameCtrl.clear();
    lastNameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    universityCtrl.clear();
    studentIdCtrl.clear();
  }
}
