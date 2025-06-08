import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:urbanest_app/model/rent_request.dart';
import 'package:urbanest_app/services/api_service.dart';

class RentRequestController with ChangeNotifier {
  final ApiService _apiService;

  List<RentRequest> _rentRequests = [];
  bool _isLoading = false;
  String _error = '';

  RentRequestController(this._apiService);

  // Getters
  List<RentRequest> get rentRequests => _rentRequests;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch all rent requests for current user
  Future<void> fetchRentRequests() async {
    try {
      _setLoading(true);
      _error = '';
      _rentRequests = await _apiService.getRentRequests();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching rent requests: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create rent request
  Future<void> createRentRequest({
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
      _setLoading(true);
      _error = '';
      
      final newRequest = await _apiService.createRentRequest(
        listingId: listingId,
        fullName: fullName,
        dob: dob,
        email: email,
        phone: phone,
        address: address,
        jobTitle: jobTitle,
        employmentStatus: employmentStatus,
        monthlyIncome: monthlyIncome,
        salarySlip: salarySlip,
      );

      _rentRequests.add(newRequest);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating rent request: $e');
      }
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete rent request
  Future<void> deleteRentRequest(String id) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.deleteRentRequest(id);
      _rentRequests.removeWhere((request) => request.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error deleting rent request: $e');
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