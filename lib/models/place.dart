enum PlaceType { HISTORIC_SITE, RESTAURANT, HOTEL, ADVENTURE, ENTERTAINMENT }

class Place {
  int? id;
  String? name;
  String? location;
  double? price;
  bool isTicketingEnabled;
  PlaceType? type;
  String? description;
  double? rating;
  String? externalLink;
  DateTime? createdAt;
  String? imageUrl;

  // Constructor
  Place({
    this.id,
    this.name,
    this.location,
    this.price,
    this.isTicketingEnabled = false,
    this.type,
    this.description,
    this.rating,
    this.externalLink,
    this.createdAt,
    this.imageUrl,
  });

  // Methods mta3 el-Diagramme
  List<dynamic> getAllOffers() {
    return [];
  }

  List<Place> searchPlaces(String query) {
    return [];
  }

  void showOnMap() {
    // logic bech t7el el map
  }

  void selectOffer() {
    // logic
  }

  List<Place> filterByType(PlaceType type) {
    return [];
  }
}
