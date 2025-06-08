import 'package:flutter/material.dart';
import 'package:urbanest_app/model/listing.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Listing> _favoriteListings = [];

  List<Listing> get favoriteListings => _favoriteListings;

  bool isFavorite(Listing listing) {
    return _favoriteListings.any((fav) => fav.id == listing.id);
  }

  void toggleFavorite(Listing listing) {
    if (isFavorite(listing)) {
      _favoriteListings.removeWhere((fav) => fav.id == listing.id);
    } else {
      _favoriteListings.add(listing);
    }
    notifyListeners();
  }
}