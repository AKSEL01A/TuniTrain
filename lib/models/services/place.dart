// ─── Enums ───────────────────────────────────────────────────────────────────

enum PlaceCategory {
  historicSite,
  restaurant,
  hotel,
  adventure,
  entertainment,
}

extension PlaceCategoryX on PlaceCategory {
  String get label => switch (this) {
    PlaceCategory.historicSite  => 'Site historique',
    PlaceCategory.restaurant    => 'Restaurant',
    PlaceCategory.hotel         => 'Hôtel',
    PlaceCategory.adventure     => 'Aventure',
    PlaceCategory.entertainment => 'Loisirs',
  };
}

// ─── Model ───────────────────────────────────────────────────────────────────

class Place {
  final int id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final double? price;
  final bool isTicketingEnabled;
  final PlaceCategory category;
  final String description;
  final double rating;
  final int reviewsCount;
  final String? externalLink;
  final DateTime createdAt;
  final List<String> imageUrls;
  final String? openingHours;
  final String? phone;
  final String? email;
  final List<String> tags;
  bool isFavorite;
  final bool isRecommended;
  final bool hasBooking;
  final String? promotionText;
  final String? socialInstagram;

  Place({
    required this.id,
    required this.name,
    required this.location,
    this.latitude = 36.8189,
    this.longitude = 10.1658,
    this.price,
    this.isTicketingEnabled = false,
    required this.category,
    required this.description,
    this.rating = 4.0,
    this.reviewsCount = 0,
    this.externalLink,
    DateTime? createdAt,
    this.imageUrls = const [],
    this.openingHours,
    this.phone,
    this.email,
    this.tags = const [],
    this.isFavorite = false,
    this.isRecommended = false,
    this.hasBooking = false,
    this.promotionText,
    this.socialInstagram,
  }) : createdAt = createdAt ?? DateTime.now();

  Place copyWith({
    int? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    double? price,
    bool? isTicketingEnabled,
    PlaceCategory? category,
    String? description,
    double? rating,
    int? reviewsCount,
    String? externalLink,
    DateTime? createdAt,
    List<String>? imageUrls,
    String? openingHours,
    String? phone,
    String? email,
    List<String>? tags,
    bool? isFavorite,
    bool? isRecommended,
    bool? hasBooking,
    String? promotionText,
    String? socialInstagram,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      isTicketingEnabled: isTicketingEnabled ?? this.isTicketingEnabled,
      category: category ?? this.category,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      externalLink: externalLink ?? this.externalLink,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
      openingHours: openingHours ?? this.openingHours,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isRecommended: isRecommended ?? this.isRecommended,
      hasBooking: hasBooking ?? this.hasBooking,
      promotionText: promotionText ?? this.promotionText,
      socialInstagram: socialInstagram ?? this.socialInstagram,
    );
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 36.8189,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 10.1658,
      price: (json['price'] as num?)?.toDouble(),
      isTicketingEnabled: json['isTicketingEnabled'] as bool? ?? false,
      category: PlaceCategory.values.byName(json['category'] as String),
      description: json['description'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      externalLink: json['externalLink'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      openingHours: json['openingHours'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      isRecommended: json['isRecommended'] as bool? ?? false,
      hasBooking: json['hasBooking'] as bool? ?? false,
      promotionText: json['promotionText'] as String?,
      socialInstagram: json['socialInstagram'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'latitude': latitude,
    'longitude': longitude,
    'price': price,
    'isTicketingEnabled': isTicketingEnabled,
    'category': category.name,
    'description': description,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'externalLink': externalLink,
    'createdAt': createdAt.toIso8601String(),
    'imageUrls': imageUrls,
    'openingHours': openingHours,
    'phone': phone,
    'email': email,
    'tags': tags,
    'isFavorite': isFavorite,
    'isRecommended': isRecommended,
    'hasBooking': hasBooking,
    'promotionText': promotionText,
    'socialInstagram': socialInstagram,
  };
}
