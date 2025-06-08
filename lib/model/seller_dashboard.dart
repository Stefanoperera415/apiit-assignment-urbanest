import 'package:urbanest_app/model/booking.dart';
import 'package:urbanest_app/model/offer.dart';
import 'package:urbanest_app/model/rent_request.dart';

class SellerDashboard {
  final List<Booking>? bookings;
  final List<Offer>? receivedOffers;
  final List<RentRequest>? receivedRentRequests;

  SellerDashboard({
    this.bookings,
    this.receivedOffers,
    this.receivedRentRequests,
  });

// In seller_dashboard.dart
factory SellerDashboard.fromJson(Map<String, dynamic> json) {
  try {
    return SellerDashboard(
      bookings: json['bookings'] != null 
          ? (json['bookings'] as List).map((bookingJson) {
              try {
                return Booking.fromJson(bookingJson);
              } catch (e) {
                print('Error parsing booking: $e');
                return Booking(
                  userId: '',
                  listingId: '',
                  checkInDate: '',
                  checkOutDate: '',
                  guests: 0,
                  status: '',
                  paymentMethod: '',
                  cardNumber: '',
                  expirationDate: '',
                  securityCode: '',
                  country: '',
                  postalCode: '',
                  totalAmount: 0.0,
                );
              }
            }).toList()
          : [],
      receivedOffers: json['received_offers'] != null
          ? (json['received_offers'] as List).map((offerJson) {
              try {
                return Offer.fromJson(offerJson);
              } catch (e) {
                print('Error parsing offer: $e');
                return Offer(
                  userId: '',
                  listingId: '',
                  fullName: '',
                  dob: DateTime.now(),
                  email: '',
                  phone: '',
                  offerAmount: 0.0,
                );
              }
            }).toList()
          : [],
      receivedRentRequests: json['received_rent_requests'] != null
          ? (json['received_rent_requests'] as List).map((rentRequestJson) {
              try {
                return RentRequest.fromJson(rentRequestJson);
              } catch (e) {
                print('Error parsing rent request: $e');
                return RentRequest(
                  userId: '',
                  listingId: '',
                  status: '',
                  fullName: '',
                  dob: DateTime.now(),
                  email: '',
                  phone: '',
                  address: '',
                  jobTitle: '',
                  employmentStatus: '',
                  monthlyIncome: 0.0,
                  salarySlipPath: '',
                );
              }
            }).toList()
          : [],
    );
  } catch (e) {
    print('Error creating SellerDashboard: $e');
    return SellerDashboard();
  }
}
}