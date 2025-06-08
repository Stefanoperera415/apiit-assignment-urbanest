import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/widget/favouites_provider.dart';
import 'package:urbanest_app/widget/favorite_property_card.dart'; // Import the new card

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoritesProvider.favoriteListings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(

                    height: 100,
                    child: Lottie.asset(
                      "assets/heart.json",
                      fit: BoxFit.contain,
                    ),
                  ),
                
                  Text(
                    'No favorites yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favoritesProvider.favoriteListings.length,
              itemBuilder: (context, index) {
                final listing = favoritesProvider.favoriteListings[index];
                return FavoritePropertyCard( // Use the new compact card
                  listing: listing,
                  isFavorite: true,
                  onFavoriteToggle: () {
                    favoritesProvider.toggleFavorite(listing);
                  },
                );
              },
            ),
    );
  }
}