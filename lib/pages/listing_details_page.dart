import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/utils/build_property_features.dart'; 
import 'package:urbanest_app/utils/amenities_section.dart';
import 'package:urbanest_app/utils/bottom_bar.dart';
import 'package:urbanest_app/widget/favouites_provider.dart';

class ListingDetailsPage extends StatelessWidget {
  final Listing listing;

  const ListingDetailsPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(listing);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: CircleAvatar(
            backgroundColor: isDarkMode
                ? colorScheme.surface.withOpacity(0.7)
                : colorScheme.surface.withOpacity(0.9),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 16),
            child: CircleAvatar(
              backgroundColor: isDarkMode
                  ? colorScheme.surface.withOpacity(0.7)
                  : colorScheme.surface.withOpacity(0.9),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : colorScheme.onSurface,
                ),
                onPressed: () {
                  favoritesProvider.toggleFavorite(listing);
                },
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildImageCarousel(context)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([  
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                       
                      ),
                    ),
                    
                  ],
                ),
                //price container
                
                const SizedBox(height: 12),
                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${listing.city},${listing.province} ,${listing.countryRegion}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                BuildPropertyFeatures(listing: listing),
                const SizedBox(height: 32),
                // Description
                Text(
                  'About this property',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  listing.description,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 60),

                // Amenities Section
                if (listing.offers != null && listing.offers!.isNotEmpty)
                 AmenitiesSection(listing: listing),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomSheet: BottomBarListing(listing: listing),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    final images = listing.imagesUrls ?? listing.images ?? [];
    if (images.isEmpty && listing.coverImage != null) {
      images.insert(0, listing.coverImage!);
    }

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: CarouselSlider(
            options: CarouselOptions(
              height: double.infinity,
              aspectRatio: 16 / 9,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              enlargeCenterPage: true,
            ),
            items: images.map((image) {
              final imageUrl = image.startsWith('http')
                  ? image
                  : 'http://192.168.1.101:8000/storage/$image';

              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${images.length} photos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}