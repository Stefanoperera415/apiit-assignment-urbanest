import 'package:flutter/material.dart';

class PlaceListingPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String placeType;
  final String listingType;
  final Function(String) onPlaceTypeChanged;
  final Function(String) onListingTypeChanged;

  const PlaceListingPage({
    Key? key,
    required this.formKey,
    required this.placeType,
    required this.listingType,
    required this.onPlaceTypeChanged,
    required this.onListingTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place Listing',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 18),
            const Text(
              'Place Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _buildPlaceTypeCard(
              context,
              'Entire home',
              'Guests have the whole place to themselves',
              'assets/images/house.png',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildPlaceTypeCard(
              context,
              'Private room',
              'Guests have their own room in a home',
              'assets/images/interior-design.png',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildPlaceTypeCard(
              context,
              'Any Type',
              'Guests share a common space with others',
              'assets/images/building.png',
              isDark,
            ),
            const SizedBox(height: 40),
            const Text(
              'Listing Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildListingTypeCard(
                  context,
                  'Sell Property',
                  'Earn income by renting out your property to tenants',
                  'assets/images/hand.png',
                  isDark,
                ),
                _buildListingTypeCard(
                  context,
                  'Rent Out Property',
                  'Earn income by renting out your property to tenants',
                  'assets/images/home (2).png',
                  isDark,
                ),
                _buildListingTypeCard(
                  context,
                  'List Vacation Rental',
                  'Offer your property for short-term vacation bookings',
                  'assets/images/vacations (1).png',
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceTypeCard(
    BuildContext context,
    String type,
    String description,
    String imagePath,
    bool isDark,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: placeType == type
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.white38 : Colors.grey[300]!),
          width: placeType == type ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onPlaceTypeChanged(type),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Image.asset(imagePath, width: 48, height: 48, fit: BoxFit.cover),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingTypeCard(
    BuildContext context,
    String type,
    String description,
    String imagePath,
    bool isDark,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: listingType == type
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.white38 : Colors.grey[300]!),
          width: listingType == type ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onListingTypeChanged(type),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.cover),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
