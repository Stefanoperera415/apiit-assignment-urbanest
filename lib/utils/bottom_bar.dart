import 'package:flutter/material.dart';
import 'package:urbanest_app/controllers/auth_provider.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/pages/booking_form_page.dart';
import 'package:urbanest_app/pages/make_offer_page.dart';
import 'package:urbanest_app/pages/rent_request_form_page.dart';
import 'package:provider/provider.dart';

class BottomBarListing extends StatelessWidget {
  final Listing listing;

  const BottomBarListing({super.key, required this.listing});

  // Helper method to determine right button text based on listing method
  String _getActionButtonText() {
    switch (listing.method.toLowerCase()) {
      case 'sell property':
        return 'Make an Offer';
      case 'rent out property':
        return 'Request a Rent';
      case 'list vacation rental':
        return 'Book Now';
      default:
        return 'Book Now';
    }
  }

  // Helper method to determine left button text based on listing method
  String _getPriceLabelText() {
    switch (listing.method.toLowerCase()) {
      case 'sell property':
        return 'Minimum Offer';
      case 'rent out property':
        return 'Minimum Rent';
      case 'list vacation rental':
        return 'Per Night';
      default:
        return 'Price';
    }
  }

  // Helper method to determine which page to navigate to
  Widget _getActionPage() {
    switch (listing.method.toLowerCase()) {
      case 'sell property':
        return MakeOfferPage(listing: listing);
      case 'rent out property':
        return RentRequestFormPage(listing: listing);
      case 'list vacation rental':
        return BookingFormPage(listing: listing);
      default:
        return BookingFormPage(listing: listing);
    }
  }

  // Check if the current user is the owner of the listing
  bool _isCurrentUserOwner(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser?.id == listing.userId;
  }

  // Check if the listing is available (not sold, leased, or unavailable)
  bool _isListingAvailable() {
    return ![
      'sold',
      'leased',
      'unavailable',
    ].contains(listing.status?.toLowerCase());
  }

  // Get the disabled reason text
  String? _getDisabledReason(BuildContext context) {
    if (_isCurrentUserOwner(context)) {
      return 'You own this listing';
    }
    if (!_isListingAvailable()) {
      return 'This listing is ${listing.status}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final priceTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.white : Colors.black,
    );
    final labelTextStyle = TextStyle(
      fontSize: 12,
      color: isDarkMode ? Colors.white70 : Colors.black54,
    );

    final disabledReason = _getDisabledReason(context);
    final isDisabled = disabledReason != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 78, // Fixed height for the bottom bar
          child: Row(
            children: [
              // Left container showing price information
              // Inside your BottomBarListing widget's build method, update the left container's decoration:
              // Inside your BottomBarListing widget's build method, update the left container's decoration:
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            !_isListingAvailable()
                                ? isDarkMode
                                    ? Colors
                                        .amber // Brighter yellow for dark mode
                                    : Colors
                                        .yellow[700]! // Darker yellow for light mode
                                : isDarkMode
                                ? Colors.white24
                                : Colors.black12,
                        width: !_isListingAvailable() ? 1.5 : 0.8,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color:
                          !_isListingAvailable()
                              ? isDarkMode
                                  ? Colors.amber.withOpacity(
                                    0.08,
                                  ) // Subtle amber tint in dark mode
                                  : Colors
                                      .yellow[50]! // Light yellow background in light mode
                              : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getPriceLabelText(),
                          style: labelTextStyle.copyWith(
                            color:
                                !_isListingAvailable()
                                    ? isDarkMode
                                        ? Colors.amber[200]
                                        : Colors.yellow[800]
                                    : labelTextStyle.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'LKR ${listing.price.toString()}',
                          style: priceTextStyle.copyWith(
                            color:
                                !_isListingAvailable()
                                    ? isDarkMode
                                        ? Colors.amber[100]
                                        : Colors.yellow[900]
                                    : priceTextStyle.color,
                          ),
                        ),
                        if (isDisabled)
                          Text(
                            disabledReason!,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode ? Colors.red[200] : Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right action button
              Expanded(
                child:
                    isDisabled
                        ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: null, // Disabled button
                          child: Text(
                            _getActionButtonText(),
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode
                                    ? Colors.white
                                    : const Color.fromARGB(255, 50, 33, 26),
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _getActionPage(),
                              ),
                            );
                          },
                          child: Text(
                            _getActionButtonText(),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
