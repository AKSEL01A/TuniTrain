import 'package:get/get.dart';
import 'package:tuni_train/models/services/car_rental.dart';
import 'package:tuni_train/models/services/place.dart';
import 'package:tuni_train/data/services/car_rental_repository.dart';
import 'package:tuni_train/data/services/place_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NewsItem model
// ─────────────────────────────────────────────────────────────────────────────
class NewsItem {
  final String id;
  final String title;
  final String body;
  final String type; // 'info' | 'warning' | 'success'
  final DateTime date;

  const NewsItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.date,
  });

  // 🔥 Uncomment when Firestore is connected:
  // factory NewsItem.fromMap(String id, Map<String, dynamic> map) => NewsItem(
  //   id: id,
  //   title: map['title'] ?? '',
  //   body: map['body'] ?? '',
  //   type: map['type'] ?? 'info',
  //   date: (map['date'] as Timestamp).toDate(),
  // );
}

// ─────────────────────────────────────────────────────────────────────────────
//  AccueilController
// ─────────────────────────────────────────────────────────────────────────────
class AccueilController extends GetxController {
  final CarRentalRepository _carRepo;
  final PlaceRepository _placeRepo;

  AccueilController({CarRentalRepository? carRepo, PlaceRepository? placeRepo})
    : _carRepo = carRepo ?? MockCarRentalRepository(),
      _placeRepo = placeRepo ?? MockPlaceRepository();

  // ── News ──────────────────────────────────────────────────────────────────
  final newsList = <NewsItem>[].obs;
  final isLoadingNews = true.obs;
  final dismissedIds = <String>{}.obs;

  // ── Services ──────────────────────────────────────────────────────────────
  final featuredCars = <CarRental>[].obs;
  final featuredPlaces = <Place>[].obs;
  final isLoadingData = true.obs;
  final hasError = false.obs;

  // ── Derived ───────────────────────────────────────────────────────────────
  List<NewsItem> get visibleNews =>
      newsList.where((n) => !dismissedIds.contains(n.id)).toList();

  bool get hasAlerts => visibleNews.any((n) => n.type == 'warning');

  @override
  void onInit() {
    super.onInit();
    _loadNews();
    _loadServices();
  }

  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadNews() async {
    isLoadingNews.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    // 🔥 Firestore version (uncomment when ready):
    // final snap = await FirebaseFirestore.instance
    //     .collection('actualites')
    //     .orderBy('date', descending: true)
    //     .get();
    // newsList.assignAll(snap.docs.map((d) => NewsItem.fromMap(d.id, d.data())));

    newsList.assignAll([
      NewsItem(
        id: '1',
        title: 'Perturbations ligne Tunis–Sousse',
        body: 'Des retards prévus entre 14h et 18h — travaux de maintenance.',
        type: 'warning',
        date: DateTime.now(),
      ),
      NewsItem(
        id: '2',
        title: 'Nouveau tarif étudiant',
        body:
            '50% de réduction sur tous les trajets avec votre carte étudiante.',
        type: 'success',
        date: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NewsItem(
        id: '3',
        title: 'Maintenance dimanche',
        body: 'Service interrompu de 2h à 6h du matin pour maintenance.',
        type: 'info',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    isLoadingNews.value = false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadServices() async {
    isLoadingData.value = true;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _carRepo.getFeaturedCars(),
        _placeRepo.getFeaturedPlaces(),
      ]);
      featuredCars.assignAll((results[0] as List<CarRental>).take(3));
      featuredPlaces.assignAll((results[1] as List<Place>).take(3));
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoadingData.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  void dismissNews(String id) => dismissedIds.add(id);
  Future<void> refreshNews() => _loadNews();
  Future<void> refreshAll() async =>
      Future.wait([_loadNews(), _loadServices()]);
}
