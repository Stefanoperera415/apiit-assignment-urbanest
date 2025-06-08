// File: lib/utils/build_property_features.dart
import 'package:flutter/material.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/utils/build_feature_item.dart';

class BuildPropertyFeatures extends StatelessWidget {
  final Listing listing;

  const BuildPropertyFeatures({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blueGrey.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BuildFeatureItem(
            icon: Icons.people_outline,
            text: '${listing.noOfGuests} Guests',
            iconColor: isDarkMode? Colors.white: Colors. black,
            textColor: isDarkMode ? Colors.white : Colors.black,
          ),
          BuildFeatureItem(
            icon: Icons.bed_outlined,
            text: '${listing.noOfBedrooms} Bedrooms',
            iconColor:  isDarkMode? Colors.white: Colors. black,
            textColor: isDarkMode ? Colors.white : Colors.black,
          ),
          BuildFeatureItem(
            icon: Icons.bed,
            text: '${listing.noOfBeds} Beds',
            iconColor:  isDarkMode? Colors.white: Colors. black,
            textColor:isDarkMode ? Colors.white : Colors.black,
          ),
          BuildFeatureItem(
            icon: Icons.bathtub_outlined,
            text: '${listing.noOfBathrooms} Baths',
            iconColor: isDarkMode? Colors.white: Colors. black,
            textColor: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }
}
