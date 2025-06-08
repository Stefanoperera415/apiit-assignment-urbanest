import 'package:flutter/material.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/utils/amenity_icon.dart';

class AmenitiesSection extends StatelessWidget {
  final Listing listing;

  const AmenitiesSection({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 30),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          padding: EdgeInsets.zero,
          children: listing.offers!
              .map(
                (amenity) => Row(
                  children: [
                    Icon(
                      getAmenityIcon(amenity),
                      size: 23,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        amenity,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
