import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:urbanest_app/model/booking.dart';
import 'package:urbanest_app/model/offer.dart';
import 'package:urbanest_app/model/rent_request.dart';
import 'package:urbanest_app/model/seller_dashboard.dart';
import 'package:urbanest_app/model/user.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.101:8000/api';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Default headers for requests
  Map<String, String> get _headers => {
    "Accept": 'application/json',
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // Retrieve headers with authorization if token exists
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(_headers);
    final token = await _storage.read(key: 'token');
    if (token != null) {
      final bearerToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      headers['Authorization'] = bearerToken;
    }
    return headers;
  }

  // Get CSRF token from the server
  Future<String?> _getCsrfToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sanctum/csrf-cookie'),
        headers: _headers,
      );

      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        final xsrfToken = cookies
            .split(';')
            .firstWhere(
              (cookie) => cookie.trim().startsWith('XSRF-TOKEN='),
              orElse: () => '',
            );
        if (xsrfToken.isNotEmpty) {
          return Uri.decodeComponent(xsrfToken.split('=')[1]);
        }
      }
    } catch (e) {
      print('Error fetching CSRF token: $e');
    }
    return null;
  }

  // ========== LISTING RELATED METHODS ==========

  // Get all listings (paginated)
  Future<List<Listing>> getListings({int page = 1, String? method}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {'page': page.toString()};

      if (method != null) {
        queryParams['method'] = method;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/listings').replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List listings = data['data'] ?? [];
        return listings.map((json) => Listing.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get single listing by ID
  Future<Listing> getListing(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/listings/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Convert relative image paths to full URLs
        // if (json['cover_image'] != null) {
        //   json['cover_image'] = '$baseUrl/storage/${json['cover_image']}'.replaceAll('/api/storage', '/storage');
        // }
        // if (json['images'] != null) {
        //   json['images'] = (json['images'] as List).map((image) => '$baseUrl/storage/$image').toList();
        // }
        return Listing.fromJson(json);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Listing>> getListingsByUserId(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/listings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((json) => Listing.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Create new listing
  Future<Listing> createListing(
    Listing listing, {
    File? coverImage,
    List<File>? otherImages,
  }) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/listings'),
      );
      request.headers.addAll(headers);

      // Add all fields
      request.fields.addAll({
        'title': listing.title,
        'type_of_place': listing.typeOfPlace,
        'method': listing.method,
        'country_region': listing.countryRegion,
        'address_line1': listing.addressLine1,
        'city': listing.city,
        'province': listing.province,
        'postal_code': listing.postalCode,
        'no_of_guests': listing.noOfGuests.toString(),
        'no_of_bedrooms': listing.noOfBedrooms.toString(),
        'no_of_beds': listing.noOfBeds.toString(),
        'no_of_bathrooms': listing.noOfBathrooms.toString(),
        'description': listing.description,
        'price': listing.price.toString(),
        'status': listing.status ?? 'Pending',
        'plan_name': listing.planName ?? '',
        'plan_price': listing.planPrice?.toString() ?? '0',
        'plan_duration_days': listing.planDurationDays?.toString() ?? '0',
      });

      // Add images if they exist
      if (coverImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('cover_image', coverImage.path),
        );
      }

      if (otherImages != null) {
        for (var image in otherImages) {
          request.files.add(
            await http.MultipartFile.fromPath('images[]', image.path),
          );
        }
      }

      // Add offers
      if (listing.offers != null) {
        for (var offer in listing.offers!) {
          request.files.add(
            http.MultipartFile.fromString(
              'offers[]',
              offer,
              contentType: MediaType('text', 'plain'),
            ),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return Listing.fromJson(jsonDecode(responseBody));
      } else {
        throw _handleError(http.Response(responseBody, response.statusCode));
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> savePaymentDetails(
    String listingId,
    Map<String, dynamic> paymentDetails,
  ) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/listings/$listingId/payment'),
        headers: headers,
        body: jsonEncode(paymentDetails),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update existing listing
  Future<Listing> updateListing(Listing listing) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/listings/${listing.id}'),
        headers: headers,
        body: jsonEncode(listing.toJson()),
      );

      if (response.statusCode == 200) {
        return Listing.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  //=======================================================================

  // Update existing listing with images
  Future<Listing> updateListingWithImages(
    Listing listing, {
    File? coverImage,
    List<File>? otherImages,
    required List<String> offers,
  }) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/listings/${listing.id}'),
      );
      request.headers.addAll(headers);
      request.fields['_method'] = 'PUT'; // Laravel will treat this as PUT

      // Add all fields
      request.fields.addAll({
        'title': listing.title,
        'price': listing.price.toString(),
        'description': listing.description,
        'offers': jsonEncode(listing.offers ?? []),
      });

      // Add images if they exist
      if (coverImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('cover_image', coverImage.path),
        );
      }

      if (otherImages != null) {
        for (var image in otherImages) {
          request.files.add(
            await http.MultipartFile.fromPath('images[]', image.path),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return Listing.fromJson(jsonDecode(responseBody));
      } else {
        throw _handleError(http.Response(responseBody, response.statusCode));
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  //=======================================================================

  // Delete listing
  Future<void> deleteListing(String id) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/listings/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== BOOKING RELATED METHODS =================================

  // Get all bookings for current user
  Future<List<Booking>> getBookings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/bookings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((json) => Booking.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get single booking by ID
  Future<Booking> getBooking(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Booking.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Create new booking for a listing
  Future<Booking> createBooking({
    required String listingId,
    required String checkInDate,
    required String checkOutDate,
    required int guests,
    required String paymentMethod,
    required String cardNumber,
    required String expirationDate,
    required String securityCode,
    required String country,
    required String postalCode,
    required double totalAmount,
  }) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$listingId'),
        headers: headers,
        body: jsonEncode({
          'check_in_date': checkInDate,
          'check_out_date': checkOutDate,
          'guests': guests,
          'payment_method': paymentMethod,
          'card_number': cardNumber,
          'expiration_date': expirationDate,
          'security_code': securityCode,
          'country': country,
          'postal_code': postalCode,
          'total_amount': totalAmount,
        }),
      );

      if (response.statusCode == 201) {
        return Booking.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String id) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/bookings/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  //=======================================================================
  // =============================REnt-REquest===========================

  // Get all rent requests for current user
  Future<List<RentRequest>> getRentRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rent-requests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((json) => RentRequest.fromJson(json))
            .toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Create rent request for a listing
  Future<RentRequest> createRentRequest({
    required String listingId,
    required String fullName,
    required DateTime dob,
    required String email,
    required String phone,
    required String address,
    required String jobTitle,
    required String employmentStatus,
    required double monthlyIncome,
    required File salarySlip,
  }) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/rent-requests/$listingId/create'),
      );
      request.headers.addAll(headers);

      // Add all fields
      request.fields.addAll({
        'full_name': fullName,
        'dob': dob.toIso8601String(),
        'email': email,
        'phone': phone,
        'address': address,
        'job_title': jobTitle,
        'employment_status': employmentStatus, // Must be included
        'monthly_income': monthlyIncome.toString(),
      });

      // Add salary slip file
      request.files.add(
        await http.MultipartFile.fromPath('salary_slip', salarySlip.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return RentRequest.fromJson(jsonDecode(responseBody));
      } else {
        throw _handleError(http.Response(responseBody, response.statusCode));
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete rent request
  Future<void> deleteRentRequest(String id) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/rent-requests/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  //=======================================================================
  // ========== OFFER RELATED METHODS ==========

  // Get all offers for current user
  Future<List<Offer>> getOffers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/offers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((json) => Offer.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get single offer by ID
  Future<Offer> getOffer(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/offers/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Offer.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Create new offer for a listing
  Future<Offer> createOffer({
    required String listingId,
    required String fullName,
    required DateTime dob,
    required String email,
    required String phone,
    required double offerAmount,
  }) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/offers/$listingId/create'),
        headers: headers,
        body: jsonEncode({
          'full_name': fullName,
          'dob': dob.toIso8601String(),
          'email': email,
          'phone': phone,
          'offer_amount': offerAmount,
        }),
      );

      if (response.statusCode == 201) {
        return Offer.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete offer
  Future<void> deleteOffer(String id) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/offers/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  //=====================================================================
  // Add these methods to your ApiService class in api_service.dart
  //==============SELLER  DASHBOARD====================================
  // Get seller dashboard data
  Future<SellerDashboard> getSellerDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/seller/dashboard'),
        headers: headers,
      );

      print('Dashboard response: ${response.statusCode}');
      print('Dashboard headers: ${response.headers}');
      print('Dashboard body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Parsed JSON: $jsonData');
        return SellerDashboard.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print('Error in getSellerDashboard: $e');
      print(StackTrace.current);
      throw _handleError(e);
    }
  }

  // Accept offer
  Future<void> acceptOffer(String offerId) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/seller/offers/$offerId/accept'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Reject offer
  Future<void> rejectOffer(String offerId) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/seller/offers/$offerId/reject'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Accept rent request
  Future<void> acceptRentRequest(String rentRequestId) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/seller/rent-requests/$rentRequestId/accept'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Reject rent request
  Future<void> rejectRentRequest(String rentRequestId) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/seller/rent-requests/$rentRequestId/reject'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Mark booking as unavailable
  Future<void> markBookingAsUnavailable(String bookingId) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/seller/bookings/$bookingId/mark-unavailable'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Mark booking as available
  Future<void> markBookingAsAvailable(String bookingId) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/seller/bookings/$bookingId/mark-available'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
  // ========== AUTH METHODS ===============

  Future<User> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        user.token = data['token'];
        await _storage.write(key: 'token', value: user.token);
        return user;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final headers = await _getHeaders();
      final csrfToken = await _getCsrfToken();
      if (csrfToken != null) {
        headers['X-XSRF-TOKEN'] = csrfToken;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        user.token = data['token'].toString();
        await _storage.write(key: 'token', value: user.token);
        return user;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> hasValidToken() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<void> logout() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
      if (response.statusCode != 401 && response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      await clearToken();
      throw _handleError(e);
    }
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }

  String _handleError(dynamic error) {
    if (error is http.Response) {
      try {
        final data = jsonDecode(error.body);
        return data['message'] ?? 'Something went wrong';
      } catch (e) {
        return error.body.toString();
      }
    }
    return error.toString();
  }
}
