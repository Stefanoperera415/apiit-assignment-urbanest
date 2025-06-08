import 'package:flutter/foundation.dart';
import 'package:urbanest_app/model/seller_dashboard.dart';
import 'package:urbanest_app/services/api_service.dart';

class SellerDashboardProvider with ChangeNotifier {
  final ApiService _apiService;

  SellerDashboard? _dashboardData;
  bool _isLoading = false;
  String _error = '';

  SellerDashboardProvider(this._apiService);

  // Getters
  SellerDashboard? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
  try {
    _setLoading(true);
    _error = '';
    final data = await _apiService.getSellerDashboard();
    if (data != null) {
      _dashboardData = data;
    } else {
      _error = 'Failed to load dashboard data';
    }
    notifyListeners();
  } catch (e) {
    _error = 'Error: ${e.toString()}';
    if (kDebugMode) {
      print('Error fetching seller dashboard: $e');
    }
    notifyListeners();
  } finally {
    _setLoading(false);
  }
}

  // Accept offer
  Future<void> acceptOffer(String offerId) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.acceptOffer(offerId);
      await fetchDashboardData(); // Refresh data after action
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error accepting offer: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Reject offer
  Future<void> rejectOffer(String offerId) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.rejectOffer(offerId);
      await fetchDashboardData(); // Refresh data after action
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error rejecting offer: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Accept rent request
  Future<void> acceptRentRequest(String rentRequestId) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.acceptRentRequest(rentRequestId);
      await fetchDashboardData(); // Refresh data after action
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error accepting rent request: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Reject rent request
  Future<void> rejectRentRequest(String rentRequestId) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.rejectRentRequest(rentRequestId);
      await fetchDashboardData(); // Refresh data after action
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error rejecting rent request: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Mark booking as unavailable
  Future<void> markBookingAsUnavailable(String bookingId) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.markBookingAsUnavailable(bookingId);
      await fetchDashboardData(); // Refresh data after action
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error marking booking as unavailable: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Mark booking as available
  Future<void> markBookingAsAvailable(String bookingId) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.markBookingAsAvailable(bookingId);
      await fetchDashboardData(); // Refresh data after action
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error marking booking as available: $e');
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