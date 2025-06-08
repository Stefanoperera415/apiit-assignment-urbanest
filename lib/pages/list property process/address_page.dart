import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String country;
  final String streetAddress;
  final String city;
  final String stateProvince;
  final String postalCode;
  final Function(String) onCountryChanged;
  final Function(String) onStreetAddressChanged;
  final Function(String) onCityChanged;
  final Function(String) onStateProvinceChanged;
  final Function(String) onPostalCodeChanged;

  const AddressPage({
    Key? key,
    required this.formKey,
    required this.country,
    required this.streetAddress,
    required this.city,
    required this.stateProvince,
    required this.postalCode,
    required this.onCountryChanged,
    required this.onStreetAddressChanged,
    required this.onCityChanged,
    required this.onStateProvinceChanged,
    required this.onPostalCodeChanged,
  }) : super(key: key);

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  late TextEditingController _searchController;
  late TextEditingController _countryController;
  late TextEditingController _streetAddressController;
  late TextEditingController _cityController;
  late TextEditingController _stateProvinceController;
  late TextEditingController _postalCodeController;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _countryController = TextEditingController(text: widget.country);
    _streetAddressController = TextEditingController(
      text: widget.streetAddress,
    );
    _cityController = TextEditingController(text: widget.city);
    _stateProvinceController = TextEditingController(
      text: widget.stateProvince,
    );
    _postalCodeController = TextEditingController(text: widget.postalCode);
  }

  @override
  void didUpdateWidget(covariant AddressPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.country != widget.country) {
      _countryController.text = widget.country;
    }
    if (oldWidget.streetAddress != widget.streetAddress) {
      _streetAddressController.text = widget.streetAddress;
    }
    if (oldWidget.city != widget.city) {
      _cityController.text = widget.city;
    }
    if (oldWidget.stateProvince != widget.stateProvince) {
      _stateProvinceController.text = widget.stateProvince;
    }
    if (oldWidget.postalCode != widget.postalCode) {
      _postalCodeController.text = widget.postalCode;
    }
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Location permissions are denied';
        });
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _error =
            'Location permissions are permanently denied, we cannot request permissions.';
      });
      return false;
    }

    return true;
  }

  Future<void> _searchCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool permissionGranted = await _handleLocationPermission();
      if (!permissionGranted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<Location> locations = await locationFromAddress(cityName);

      if (locations.isEmpty) {
        setState(() {
          _error = 'No locations found for "$cityName"';
          _isLoading = false;
        });
        return;
      }

      Location location = locations.first;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isEmpty) {
        setState(() {
          _error = 'No address details found for "$cityName"';
          _isLoading = false;
        });
        return;
      }

      Placemark place = placemarks.first;

      // Update values and notify parent
      widget.onCountryChanged(place.country ?? '');
      widget.onCityChanged(place.locality ?? cityName);
      widget.onStateProvinceChanged(place.administrativeArea ?? '');
      final streetAddress = [
        place.street,
        place.subLocality,
        place.subAdministrativeArea,
      ].where((s) => s != null && s.isNotEmpty).join(', ');
      widget.onStreetAddressChanged(streetAddress);
      widget.onPostalCodeChanged(''); // user inputs manually

      // Update local controllers immediately
      _countryController.text = place.country ?? '';
      _cityController.text = place.locality ?? cityName;
      _stateProvinceController.text = place.administrativeArea ?? '';
      _streetAddressController.text = streetAddress;
      _postalCodeController.text = '';

      _searchController.text = place.locality ?? cityName;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching location details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _countryController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateProvinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.black87 : Colors.white,
      labelStyle: TextStyle(
        color: isDark ? Colors.white.withOpacity(0.5) : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black87, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where is your place located?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Map + Search box
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark ? Colors.black38 : Colors.grey[300],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/south_asian_map.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    shadowColor: Colors.black26,
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) _searchCity(value.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search city',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _isLoading
                                ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              BorderSide.none, // removes default border line
                        ),
                        filled: true, // makes background filled
                        fillColor:
                            isDark
                                ? Colors.black12
                                : Colors.white, // Adjust for dark mode
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_error != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Country - read only
            TextFormField(
              controller: _countryController,
              decoration: _inputDecoration('Country'),
              readOnly: true,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _streetAddressController,
              decoration: _inputDecoration('Street Address'),
              onChanged: widget.onStreetAddressChanged,
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? 'Enter street address'
                          : null,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: _inputDecoration('City'),
                    onChanged: widget.onCityChanged,
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? 'Enter city' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateProvinceController,
                    decoration: _inputDecoration('State/Province'),
                    onChanged: widget.onStateProvinceChanged,
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Enter state/province'
                                : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              keyboardType: TextInputType.number,
              controller: _postalCodeController,
              decoration: _inputDecoration('Postal Code'),
              onChanged: widget.onPostalCodeChanged,
              validator:
                  (val) =>
                      val == null || val.isEmpty ? 'Enter postal code' : null,
            ),
          ],
        ),
      ),
    );
  }
}
