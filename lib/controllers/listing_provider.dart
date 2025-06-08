import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/services/api_service.dart';

class ListingController with ChangeNotifier {
  final ApiService _apiService;

  List<Listing> _listings = [];
  bool _isLoading = false;
  String _error = '';
  Listing? _currentListing;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  ListingController(this._apiService);

  // Getters
  List<Listing> get listings => _listings;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get error => _error;
  Listing? get currentListing => _currentListing;
  bool get hasMore => _hasMore;

  // In ListingController
  int getListingCountByUserId(String userId) {
    return _listings.where((listing) => listing.userId == userId).length;
  }

  // In ListingController
  Future<int> fetchListingCountByUserId(String userId) async {
    try {
      _setLoading(true);
      final response = await _apiService.getListingsByUserId(userId);
      _setLoading(false);
      return response.length;
    } catch (e) {
      _setLoading(false);
      return 0;
    }
  }

  // In ListingController
  Future<int> getUserListingCount(String userId) async {
    try {
      _setLoading(true);
      final response = await _apiService.getListingsByUserId(userId);
      _setLoading(false);
      return response.length;
    } catch (e) {
      _setLoading(false);
      return 0;
    }
  }

  // Fetch all listings
 // In ListingController class
Future<void> fetchListings({String? method}) async {
  try {
    _setLoading(true);
    _error = '';
    _currentPage = 1;
    _hasMore = true;
    final newListings = await _apiService.getListings(
      page: _currentPage,
      method: method, // Add method parameter
    );
    _listings = newListings;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    if (kDebugMode) {
      print('Error fetching listings: $e');
    }
    notifyListeners();
  } finally {
    _setLoading(false);
  }
}

Future<void> loadMoreListings({String? method}) async {
  if (_isLoadingMore || !_hasMore) return;

  try {
    _setLoadingMore(true);
    _currentPage++;
    final newListings = await _apiService.getListings(
      page: _currentPage,
      method: method, // Add method parameter
    );

    if (newListings.isEmpty) {
      _hasMore = false;
    } else {
      _listings.addAll(newListings);
    }

    notifyListeners();
  } catch (e) {
    _currentPage--; // Revert page increment if error occurs
    if (kDebugMode) {
      print('Error loading more listings: $e');
    }
  } finally {
    _setLoadingMore(false);
  }
}

  // Get single listing by ID
  Future<void> getListingById(String id) async {
    try {
      _setLoading(true);
      _error = '';
      _currentListing = await _apiService.getListing(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching listing: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create new listing
  // listing_provider.dart
  Future<void> createListing(
    Listing listing, {
    File? coverImage,
    List<File>? otherImages,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      _setLoading(true);
      _error = '';

      // First create the listing
      final newListing = await _apiService.createListing(
        listing,
        coverImage: coverImage,
        otherImages: otherImages,
      );

      // Then save payment details if provided
      if (paymentDetails != null) {
        await _apiService.savePaymentDetails(newListing.id!, paymentDetails);
      }

      _listings.add(newListing);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error creating listing: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Update existing listing
  Future<void> updateListing(
    Listing listing, {
    File? coverImage,
    List<File>? otherImages,
  }) async {
    try {
      _setLoading(true);
      _error = '';

      Listing updatedListing;

      if (coverImage != null || otherImages != null) {
        // Update with images
        updatedListing = await _apiService.updateListingWithImages(
          listing,
          coverImage: coverImage,
          otherImages: otherImages, offers: [],
        );
      } else {
        // Regular update without images
        updatedListing = await _apiService.updateListing(listing);
      }

      // Update the local state
      final index = _listings.indexWhere((l) => l.id == updatedListing.id);
      if (index != -1) {
        _listings[index] = updatedListing;
      }
      if (_currentListing?.id == updatedListing.id) {
        _currentListing = updatedListing;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating listing: $e');
      }
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete listing
  Future<void> deleteListing(String id) async {
    try {
      _setLoading(true);
      _error = '';
      await _apiService.deleteListing(id);
      _listings.removeWhere((listing) => listing.id == id);
      if (_currentListing?.id == id) {
        _currentListing = null;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error deleting listing: $e');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Add this method to your ListingController class
Future<void> updateListingWithImages(
  Listing listing, {
  File? coverImage,
  List<File>? otherImages,
  required List<String> offers,
}) async {
  try {
    _setLoading(true);
    _error = '';

    final updatedListing = await _apiService.updateListingWithImages(
      listing,
      coverImage: coverImage,
      otherImages: otherImages,
      offers: offers,
    );

    // Update the local state
    final index = _listings.indexWhere((l) => l.id == updatedListing.id);
    if (index != -1) {
      _listings[index] = updatedListing;
    }
    if (_currentListing?.id == updatedListing.id) {
      _currentListing = updatedListing;
    }

    notifyListeners();
  } catch (e) {
    _error = e.toString();
    if (kDebugMode) {
      print('Error updating listing with images: $e');
    }
    notifyListeners();
    rethrow;
  } finally {
    _setLoading(false);
  }
}

  
  
  

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingMore(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }
}
