import 'package:tuni_train/models/services/place.dart';

// ─── Filters ─────────────────────────────────────────────────────────────────

class PlaceFilters {
  final PlaceCategory? category;
  final double? maxPrice;
  final bool ticketingOnly;

  const PlaceFilters({
    this.category,
    this.maxPrice,
    this.ticketingOnly = false,
  });

  bool get hasFilters => category != null || maxPrice != null || ticketingOnly;

  PlaceFilters copyWith({
    PlaceCategory? category,
    double? maxPrice,
    bool? ticketingOnly,
  }) {
    return PlaceFilters(
      category: category ?? this.category,
      maxPrice: maxPrice ?? this.maxPrice,
      ticketingOnly: ticketingOnly ?? this.ticketingOnly,
    );
  }

  PlaceFilters cleared() => const PlaceFilters();
}

// ─── Abstract repository ──────────────────────────────────────────────────────

abstract class PlaceRepository {
  Future<List<Place>> getPlaces({PlaceFilters? filters});
  Future<Place?> getPlaceById(int id);
  Future<List<Place>> getFeaturedPlaces();
  Future<List<Place>> getRecommended();
}

// ─── Mock implementation ──────────────────────────────────────────────────────

class MockPlaceRepository implements PlaceRepository {
  static final List<Place> _places = [
    Place(
      id: 1,
      name: "Amphithéâtre d'El Djem",
      location: 'El Djem, Mahdia',
      latitude: 35.2965,
      longitude: 10.7072,
      price: 12.0,
      isTicketingEnabled: true,
      category: PlaceCategory.historicSite,
      description:
          "L'un des plus grands amphithéâtres romains au monde, classé au patrimoine mondial de l'UNESCO. Ce chef-d'œuvre architectural peut accueillir 35 000 spectateurs et témoigne de la grandeur de l'Empire romain en Afrique du Nord.",
      rating: 4.9,
      reviewsCount: 1243,
      imageUrls: [
        'https://images.unsplash.com/photo-1523805009345-7448845a9e53?w=800',
        'https://images.unsplash.com/photo-1541943181603-d8fe267a5dcf?w=800',
      ],
      openingHours: '08h00 – 19h00',
      tags: ['UNESCO', 'Romain', 'Historique', 'Amphithéâtre'],
      isRecommended: true,
      hasBooking: true,
      promotionText: '20% de réduction ce mois-ci !',
      createdAt: DateTime(2023, 1, 10),
    ),
    Place(
      id: 2,
      name: 'Médina de Tunis',
      location: 'Tunis Centre',
      latitude: 36.8008,
      longitude: 10.1740,
      price: 0.0,
      isTicketingEnabled: false,
      category: PlaceCategory.historicSite,
      description:
          "La médina de Tunis est l'une des médinas arabes les mieux préservées. Classée UNESCO, elle abrite des milliers de boutiques artisanales, des mosquées historiques et des palais andalous. Un voyage dans le temps au cœur de la culture tunisienne.",
      rating: 4.8,
      reviewsCount: 2156,
      imageUrls: [
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=800',
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
      ],
      openingHours: 'Toute la journée',
      tags: ['UNESCO', 'Souk', 'Artisanat', 'Culture'],
      isRecommended: true,
      createdAt: DateTime(2023, 2, 5),
    ),
    Place(
      id: 3,
      name: 'Sidi Bou Saïd',
      location: 'Sidi Bou Saïd, Tunis',
      latitude: 36.8706,
      longitude: 10.2278,
      isTicketingEnabled: false,
      category: PlaceCategory.entertainment,
      description:
          "Village pittoresque aux maisons blanches et bleues perché sur une falaise surplombant la mer Méditerranée. Ambiance artistique, galeries d'art, cafés traditionnels et vues exceptionnelles sur la baie de Tunis.",
      rating: 4.9,
      reviewsCount: 3421,
      imageUrls: [
        'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?w=800',
        'https://images.unsplash.com/photo-1568797629192-789acf8e4df3?w=800',
      ],
      openingHours: 'Toute la journée',
      tags: ['Vue mer', 'Village', 'Photographie', 'Café'],
      isRecommended: true,
      promotionText: 'Café Sidi Chabaane inclus',
      createdAt: DateTime(2023, 1, 20),
    ),
    Place(
      id: 4,
      name: 'Site de Carthage',
      location: 'Carthage, Tunis',
      latitude: 36.8521,
      longitude: 10.3248,
      price: 10.0,
      isTicketingEnabled: true,
      category: PlaceCategory.historicSite,
      description:
          "L'ancienne cité de Carthage, fondée par les Phéniciens, est l'un des sites archéologiques les plus importants d'Afrique. Les ruines des thermes d'Antonin, du tophet et de la colline de Byrsa témoignent de sa grandeur passée.",
      rating: 4.7,
      reviewsCount: 891,
      imageUrls: [
        'https://images.unsplash.com/photo-1591135824700-d28fc8ab8c85?w=800',
      ],
      openingHours: '08h30 – 17h00',
      phone: '+216 71 730 036',
      tags: ['UNESCO', 'Phénicien', 'Archéologie', 'Romain'],
      hasBooking: true,
      createdAt: DateTime(2023, 3, 1),
    ),
    Place(
      id: 5,
      name: 'Musée du Bardo',
      location: 'Le Bardo, Tunis',
      latitude: 36.8088,
      longitude: 10.1334,
      price: 11.0,
      isTicketingEnabled: true,
      category: PlaceCategory.historicSite,
      description:
          "Le Musée du Bardo est l'un des plus importants musées d'Afrique du Nord. Il abrite la plus grande collection de mosaïques romaines au monde, exposée dans un ancien palais husseïnite du XVe siècle.",
      rating: 4.8,
      reviewsCount: 1567,
      imageUrls: [
        'https://images.unsplash.com/photo-1564979045531-fa386a275b27?w=800',
      ],
      openingHours: '09h00 – 17h00 (fermé lundi)',
      phone: '+216 71 513 650',
      tags: ['Musée', 'Mosaïques', 'Art', 'Histoire'],
      isRecommended: true,
      hasBooking: true,
      createdAt: DateTime(2023, 2, 14),
    ),
    Place(
      id: 6,
      name: 'Plage de La Marsa',
      location: 'La Marsa, Tunis',
      latitude: 36.8769,
      longitude: 10.3244,
      category: PlaceCategory.entertainment,
      description:
          "La belle plage de La Marsa, à 20 km de Tunis, offre eaux turquoises, restaurants de fruits de mer et une atmosphère détendue. Idéale pour les familles en été.",
      rating: 4.5,
      reviewsCount: 4123,
      imageUrls: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        'https://images.unsplash.com/photo-1508193638397-1c4234db14d8?w=800',
      ],
      openingHours: 'Toute la journée',
      tags: ['Plage', 'Mer', 'Été', 'Famille'],
      createdAt: DateTime(2023, 4, 10),
    ),
    Place(
      id: 7,
      name: 'Restaurant Dar El Jeld',
      location: 'Médina, Tunis',
      latitude: 36.7997,
      longitude: 10.1725,
      price: 45.0,
      category: PlaceCategory.restaurant,
      description:
          "Restaurant gastronomique tunisien installé dans un palais du XVIIIe siècle au cœur de la médina. Cuisine traditionnelle raffinée — couscous, ojja, makroudh — dans un cadre d'exception.",
      rating: 4.9,
      reviewsCount: 678,
      imageUrls: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      ],
      openingHours: '12h00–15h00 · 19h00–23h00',
      phone: '+216 71 560 916',
      tags: ['Gastronomique', 'Tunisien', 'Palais', 'Romantique'],
      hasBooking: true,
      createdAt: DateTime(2023, 3, 20),
    ),
    Place(
      id: 8,
      name: 'Dougga — Cité Romaine',
      location: 'Téboursouk, Béja',
      latitude: 36.4224,
      longitude: 9.2186,
      price: 8.0,
      isTicketingEnabled: true,
      category: PlaceCategory.historicSite,
      description:
          "Dougga est la cité romaine la mieux préservée d'Afrique du Nord. Son théâtre, son forum et son Capitole sont parmi les plus beaux exemples d'architecture romaine. Classée UNESCO depuis 1997.",
      rating: 4.8,
      reviewsCount: 723,
      imageUrls: [
        'https://images.unsplash.com/photo-1574948981280-0a87d80e2ce7?w=800',
      ],
      openingHours: '08h00 – 18h00',
      tags: ['UNESCO', 'Romain', 'Archéologie', 'Théâtre'],
      isRecommended: true,
      hasBooking: true,
      createdAt: DateTime(2023, 5, 2),
    ),
    Place(
      id: 9,
      name: 'Golf & Spa Hammamet',
      location: 'Hammamet, Nabeul',
      latitude: 36.3975,
      longitude: 10.6011,
      price: 25.0,
      category: PlaceCategory.adventure,
      description:
          "Complexe golfique et spa de luxe à Hammamet. 18 trous avec vue mer, piscines, hammam traditionnel et soins bien-être pour une journée de détente totale.",
      rating: 4.6,
      reviewsCount: 312,
      imageUrls: [
        'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=800',
      ],
      openingHours: '07h00 – 21h00',
      phone: '+216 72 280 088',
      tags: ['Golf', 'Spa', 'Luxe', 'Bien-être'],
      hasBooking: true,
      createdAt: DateTime(2023, 6, 5),
    ),
    Place(
      id: 10,
      name: 'Four Seasons Tunis',
      location: 'Gammarth, Tunis',
      latitude: 36.9010,
      longitude: 10.2853,
      price: 350.0,
      category: PlaceCategory.hotel,
      description:
          "Hôtel de luxe 5 étoiles sur la côte méditerranéenne. Plage privée, piscines à débordement, restaurants gastronomiques et spa world-class dans un cadre d'exception.",
      rating: 4.9,
      reviewsCount: 1045,
      imageUrls: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
      ],
      openingHours: '24h/24',
      phone: '+216 71 910 000',
      tags: ['5 étoiles', 'Luxe', 'Plage privée', 'Spa'],
      isRecommended: true,
      hasBooking: true,
      createdAt: DateTime(2023, 7, 1),
    ),
  ];

  @override
  Future<List<Place>> getPlaces({PlaceFilters? filters}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (filters == null || !filters.hasFilters) return List.from(_places);

    return _places.where((place) {
      if (filters.category != null && place.category != filters.category) {
        return false;
      }
      if (filters.maxPrice != null && (place.price ?? 0) > filters.maxPrice!) {
        return false;
      }
      if (filters.ticketingOnly && !place.isTicketingEnabled) return false;
      return true;
    }).toList();
  }

  @override
  Future<Place?> getPlaceById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _places.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Place>> getFeaturedPlaces() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _places.where((p) => p.isRecommended).take(4).toList();
  }

  @override
  Future<List<Place>> getRecommended() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _places.where((p) => p.isRecommended).toList();
  }
}
