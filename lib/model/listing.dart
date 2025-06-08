class Listing {
  final String? id;
  final String userId;
  final String title;
  final String typeOfPlace;
  final String method;
  final String countryRegion;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String province;
  final String postalCode;
  final int noOfGuests;
  final int noOfBedrooms;
  final int noOfBeds;
  final int noOfBathrooms;
  final String description;
  final int price;
  List<String>? offers;
  String? coverImage;
  List<String>? images;
  List<String>? imagesUrls; // Add this line
  late String? planName;
  late  int? planPrice;
  late  int? planDurationDays;
  final String? status;

  Listing({
    this.offers,
    required this.userId,
    this.id,
    required this.title,
    required this.typeOfPlace,
    required this.method,
    required this.countryRegion,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.noOfGuests,
    required this.noOfBedrooms,
    required this.noOfBeds,
    required this.noOfBathrooms,
    required this.description,
    required this.price,
    this.coverImage,
    this.images,
    this.planName,
    this.planPrice,
    this.planDurationDays,
    this.status,
    this.imagesUrls,
  });

  // Factory constructor to create a Listing object from JSON
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      typeOfPlace: json['type_of_place']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      countryRegion: json['country_region']?.toString() ?? '',
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString(),
      city: json['city']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      noOfGuests: json['no_of_guests'] ?? 0,
      noOfBedrooms: json['no_of_bedrooms'] ?? 0,
      noOfBeds: json['no_of_beds'] ?? 0,
      noOfBathrooms: json['no_of_bathrooms'] ?? 0,
      description: json['description']?.toString() ?? '',
      price: json['price'] ?? 0,
      coverImage: json['cover_image_url']?.toString(),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      imagesUrls:
          json['images_urls'] !=
                  null 
              ? List<String>.from(json['images_urls'])
              : null,
      planName: json['plan_name']?.toString(),
      planPrice: json['plan_price'],
      planDurationDays: json['plan_duration_days'],
      status: json['status']?.toString(),
      offers: json['offers'] != null ? List<String>.from(json['offers']) : null,
    );
  }

  // Method to serialize the Listing object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'type_of_place': typeOfPlace,
      'method': method,
      'country_region': countryRegion,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'no_of_guests': noOfGuests,
      'no_of_bedrooms': noOfBedrooms,
      'no_of_beds': noOfBeds,
      'no_of_bathrooms': noOfBathrooms,
      'description': description,
      'price': price,
      'cover_image_url': coverImage,
      'images': images,
      'plan_name': planName,
      'plan_price': planPrice,
      'plan_duration_days': planDurationDays,
      'status': status,
      'offers': offers,
    };
  }
}
