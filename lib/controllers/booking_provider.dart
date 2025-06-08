import 'package:flutter/foundation.dart';
import 'package:urbanest_app/model/booking.dart';
import 'package:urbanest_app/services/api_service.dart';

class BookingController with ChangeNotifier {
  final ApiService _apiService;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String _error = '';
  Booking? _currentBooking;

  BookingController(this._apiService);

  // Getters
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String get error => _error;
  Booking? get currentBooking => _currentBooking;

  // Fetch all bookings for current user
  Future<void> fetchBookings() async {
    try {
      _setLoading(true);
      _error = '';
      _bookings = await _apiService.getBookings();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching bookings: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get single booking by ID
  Future<void> getBookingById(String id) async {
    try {
      _setLoading(true);
      _error = '';
      _currentBooking = await _apiService.getBooking(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching booking: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create new booking
  Future<void> createBooking({
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
      _setLoading(true);
      _error = '';
      
      final booking = await _apiService.createBooking(
        listingId: listingId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        guests: guests,
        paymentMethod: paymentMethod,
        cardNumber: cardNumber,
        expirationDate: expirationDate,
        securityCode: securityCode,
        country: country,
        postalCode: postalCode,
        totalAmount:totalAmount ,
      );

      _bookings.add(booking);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating booking: $e');
      }
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String id) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.cancelBooking(id);
      _bookings.removeWhere((booking) => booking.id == id);
      if (_currentBooking?.id == id) {
        _currentBooking = null;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error cancelling booking: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}