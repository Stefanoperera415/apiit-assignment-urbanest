import 'package:flutter/material.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/pages/listing_details_page.dart';

class FavoritePropertyCard extends StatelessWidget {
  final Listing listing;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const FavoritePropertyCard({
    super.key,
    required this.listing,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailsPage(listing: listing),
            ),
          );
        },
        child: Stack(
          children: [
            // Property Image with overlay
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.network(
                    listing.coverImage ?? 'https://via.placeholder.com/300',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.home,
                        size: 60,
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),

            // Content overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.city,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.countryRegion,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Favorite button (top right)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  // Prevent the card tap from triggering when clicking the favorite button
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[800]?.withOpacity(0.7)
                        : Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    onPressed: onFavoriteToggle,
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    iconSize: 24,
                  ),
                ),
              ),
            ),

            // Status badge (top left)
            if (listing.status != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(listing.status!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    listing.status!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'for rent':
        return Colors.blue.shade800;
      case 'booking open':
        return Colors.green.shade800;
      case 'sold':
        return Colors.red.shade800;
      default: // 'for sale' and others
        return const Color.fromARGB(255, 38, 25, 21);
    }
  }
}