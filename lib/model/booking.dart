import 'package:urbanest_app/model/listing.dart';

class Booking {
  final String? id;
  final String userId;
  final String listingId;
  final String checkInDate;
  final String checkOutDate;
  final int guests;
  final String status;
  final String paymentMethod;
  final String cardNumber;
  final String expirationDate;
  final String securityCode;
  final String country;
  final String postalCode;
  final double totalAmount;
  final Listing? listing;
  final String availability; // Add this line

  Booking({
    this.id,
    required this.userId,
    required this.listingId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.status,
    required this.paymentMethod,
    required this.cardNumber,
    required this.expirationDate,
    required this.securityCode,
    required this.country,
    required this.postalCode,
    required this.totalAmount,
    this.listing,
    this.availability = 'available', // Add this with a default value
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      listingId: json['listing_id']?.toString() ?? '',
      checkInDate: json['check_in_date']?.toString() ?? '',
      checkOutDate: json['check_out_date']?.toString() ?? '',
      guests: json['guests'] ?? 0,
      status: json['status']?.toString() ?? 'confirmed',
      paymentMethod: json['payment_method']?.toString() ?? '',
      cardNumber: json['card_number']?.toString() ?? '',
      expirationDate: json['expiration_date']?.toString() ?? '',
      securityCode: json['security_code']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      totalAmount:
          (json['total_amount'] is String)
              ? double.tryParse(json['total_amount']) ?? 0.0
              : (json['total_amount']?.toDouble() ?? 0.0),
      listing:
          json['listing'] != null ? Listing.fromJson(json['listing']) : null,
      availability: json['availability']?.toString() ?? 'available', // Add this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'listing_id': listingId,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'guests': guests,
      'status': status,
      'payment_method': paymentMethod,
      'card_number': cardNumber,
      'expiration_date': expirationDate,
      'security_code': securityCode,
      'country': country,
      'postal_code': postalCode,
      'total_amount': totalAmount,
      'availability': availability, // Add this
    };
  }
}
