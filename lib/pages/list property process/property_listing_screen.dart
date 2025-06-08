import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


import 'package:urbanest_app/controllers/listing_provider.dart';
import 'package:urbanest_app/model/listing.dart';
import 'package:urbanest_app/pages/list%20property%20process/address_page.dart';
import 'package:urbanest_app/pages/list%20property%20process/amenities_page.dart';
import 'package:urbanest_app/pages/list%20property%20process/capacity_page.dart';
import 'package:urbanest_app/pages/list%20property%20process/description_price_page.dart';
import 'package:urbanest_app/pages/list%20property%20process/images_page.dart';
import 'package:urbanest_app/pages/list%20property%20process/listing_fee_plan.dart';
import 'package:urbanest_app/pages/list%20property%20process/place_listing_page.dart';
import 'package:urbanest_app/pages/list%20property%20process/property_title_page.dart';


class PropertyListingScreen extends StatefulWidget {
  const PropertyListingScreen({Key? key}) : super(key: key);

  @override
  _PropertyListingScreenState createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int totalSteps = 7;
  final _formKeys = List.generate(7, (_) => GlobalKey<FormState>());
  final _storage = FlutterSecureStorage();

  // Form Data
  String propertyTitle = '';
  String placeType = 'Entire home';
  String listingType = 'Sell';
  String country = '';

  String streetAddress = '';
  String city = '';
  String stateProvince = '';
  String postalCode = '';
  int guests = 1;
  int bedrooms = 1;
  int beds = 1;
  int bathrooms = 1;
  Map<String, bool> amenities = {
    'WiFi': false,
    'TV': false,
    'Air Conditioning': false,
    'Kitchen': false,
    'Heating': false,
    'Washer': false,
    'Dryer': false,
    'Parking': false,
    'Pool': false,
    'Garden View': false,
    'Beach Access': false,
    'Exercise Equipment': false,
    'Lake View': false,
    'Workspace': false,
    'Water Front': false,
    'Security Camera': false,
    'Fire Pit': false,
    'BBQ Grill': false,
    'First Aid Kit': false,
    'Outdoor Area': false,
    'Outdoor Shower': false,
    'Bathtub': false,
    'City View': false,
    'Fire Extinguisher': false,
    'Refrigerator': false,
    'Microwave': false,
  };
  File? coverImage;
  List<File?> otherImages = List.filled(4, null);
  String description = '';
  String price = '';
  final ImagePicker _picker = ImagePicker();

  // Navigation
  void _nextPage() {
    if (_formKeys[_currentPage].currentState?.validate() ?? true) {
      if (_currentPage < totalSteps - 1) {
        setState(() => _currentPage++);
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitListing();
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImage(int index, bool isCover) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        if (isCover) {
          coverImage = File(pickedFile.path);
        } else {
          otherImages[index] = File(pickedFile.path);
        }
      });
    }
  }

  // property_listing_screen.dart
void _submitListing() async {
  try {
    // Get current user ID from secure storage
    final token = await _storage.read(key: 'token');
    final userId = _getUserIdFromToken(token);

    // Convert amenities map to list of selected amenities
    final selectedAmenities = amenities.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    String status;
    switch (listingType) {
      case 'Sell Property':
        status = 'For Sale';
        break;
      case 'Rent Out Property':
        status = 'For Rent';
        break;
      case 'List Vacation Rental':
        status = 'Book Now';
        break;
      default:
        status = 'Pending';
    }

    // Create the listing object but don't save it yet
    final listing = Listing(
      userId: userId ?? '',
      title: propertyTitle,
      typeOfPlace: placeType,
      method: listingType,
      countryRegion: country,
      addressLine1: streetAddress,
      city: city,
      province: stateProvince,
      postalCode: postalCode,
      noOfGuests: guests,
      noOfBedrooms: bedrooms,
      noOfBeds: beds,
      noOfBathrooms: bathrooms,
      offers: selectedAmenities,
      description: description,
      price: int.tryParse(price) ?? 0,
      coverImage: coverImage?.path,
      status: status,
      images: otherImages
          .where((image) => image != null)
          .map((image) => image!.path)
          .toList(),
    );

    // Navigate to fee plan page with the listing data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingFeePlanPage(
          listingData: listing,
          coverImage: coverImage,
          otherImages: otherImages.whereType<File>().toList(),
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error preparing listing: ${e.toString()}')),
    );
  }
}

  // Helper method to extract user ID from JWT token
  String? _getUserIdFromToken(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = json.decode(decoded);

      return payloadMap['sub']?.toString();
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _stepTitle() {
    switch (_currentPage) {
      case 0:
        return '';
      case 1:
        return '';
      case 2:
        return '';
      case 3:
        return '';
      case 4:
        return '';
      case 5:
        return '';
      case 6:
        return '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _stepTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / totalSteps,
                    minHeight: 15,
                    backgroundColor:
                        isDark
                            ? Colors.grey[700]
                            : Colors
                                .grey[200], 
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? Colors.white
                          : Colors
                              .black, 
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Step ${_currentPage + 1} of $totalSteps',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                PropertyTitlePage(
                  formKey: _formKeys[0],
                  propertyTitle: propertyTitle,
                  onChanged: (val) => propertyTitle = val,
                ),
                PlaceListingPage(
                  formKey: _formKeys[1],
                  placeType: placeType,
                  listingType: listingType,
                  onPlaceTypeChanged: (val) => setState(() => placeType = val),
                  onListingTypeChanged:
                      (val) => setState(() => listingType = val),
                ),
                AddressPage(
                  formKey: _formKeys[2],
                  country: country,
                  streetAddress: streetAddress,
                  city: city,
                  stateProvince: stateProvince,
                  postalCode: postalCode,
                  onCountryChanged: (val) => setState(() => country = val),
                  onStreetAddressChanged:
                      (val) => setState(() => streetAddress = val),
                  onCityChanged: (val) => setState(() => city = val),
                  onStateProvinceChanged:
                      (val) => setState(() => stateProvince = val),
                  onPostalCodeChanged:
                      (val) => setState(() => postalCode = val),
                ),

                CapacityPage(
                  formKey: _formKeys[3],
                  guests: guests,
                  bedrooms: bedrooms,
                  beds: beds,
                  bathrooms: bathrooms,
                  onGuestsChanged: (val) => setState(() => guests = val),
                  onBedroomsChanged: (val) => setState(() => bedrooms = val),
                  onBedsChanged: (val) => setState(() => beds = val),
                  onBathroomsChanged: (val) => setState(() => bathrooms = val),
                ),
                AmenitiesPage(
                  formKey: _formKeys[4],
                  amenities: amenities,
                  onAmenityChanged:
                      (key, value) => setState(() => amenities[key] = value),
                ),
                ImagesPage(
                  formKey: _formKeys[5],
                  coverImage: coverImage,
                  otherImages: otherImages,
                  onPickImage: _pickImage,
                ),
                DescriptionPricePage(
                  formKey: _formKeys[6],
                  description: description,
                  price: price,
                  onDescriptionChanged: (val) => description = val,
                  onPriceChanged: (val) => price = val,
                ),
              ],
            ),
          ),
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side:  BorderSide(color: isDark? Colors.white : Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(color: isDark? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white: Colors. black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == totalSteps - 1
                          ? 'Submit Listing'
                          : 'Continue',
                      style: TextStyle(color: isDark ? Colors.black : Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
