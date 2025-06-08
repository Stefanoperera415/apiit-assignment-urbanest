// make_an_offer_provider.dart
import 'package:flutter/foundation.dart';
import 'package:urbanest_app/model/offer.dart';
import 'package:urbanest_app/services/api_service.dart';

class MakeAnOfferController with ChangeNotifier {
  final ApiService _apiService;

  List<Offer> _offers = [];
  bool _isLoading = false;
  String _error = '';
  Offer? _currentOffer;

  MakeAnOfferController(this._apiService);

  // Getters
  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;
  String get error => _error;
  Offer? get currentOffer => _currentOffer;

  // Fetch all offers for current user
  Future<void> fetchOffers() async {
    try {
      _setLoading(true);
      _error = '';
      _offers = await _apiService.getOffers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching offers: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get single offer by ID
  Future<void> getOfferById(String id) async {
    try {
      _setLoading(true);
      _error = '';
      _currentOffer = await _apiService.getOffer(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching offer: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create new offer
  Future<void> createOffer({
    required String listingId,
    required String fullName,
    required DateTime dob,
    required String email,
    required String phone,
    required double offerAmount,
  }) async {
    try {
      _setLoading(true);
      _error = '';
      final newOffer = await _apiService.createOffer(
        listingId: listingId,
        fullName: fullName,
        dob: dob,
        email: email,
        phone: phone,
        offerAmount: offerAmount,
      );
      _offers.add(newOffer);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating offer: $e');
      }
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete offer
  Future<void> deleteOffer(String id) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.deleteOffer(id);
      _offers.removeWhere((offer) => offer.id == id);
      if (_currentOffer?.id == id) {
        _currentOffer = null;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error deleting offer: $e');
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