import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/listing_provider.dart';
import 'package:urbanest_app/model/listing.dart';

class UpdateListingScreen extends StatefulWidget {
  final Listing listing;

  const UpdateListingScreen({super.key, required this.listing});

  @override
  State<UpdateListingScreen> createState() => _UpdateListingScreenState();
}

class _UpdateListingScreenState extends State<UpdateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  List<String> _selectedAmenities = [];
  File? _newCoverImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing.title);
    _priceController = TextEditingController(
      text: widget.listing.price.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.listing.description,
    );
    // Ensure offers is always initialized as a List<String>
    _selectedAmenities = widget.listing.offers != null 
        ? List<String>.from(widget.listing.offers!)
        : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _newCoverImage = File(pickedFile.path);
      });
    }
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create a fresh copy of amenities list to ensure it's a proper array
      final amenitiesArray = List<String>.from(_selectedAmenities);

      final updatedListing = Listing(
        id: widget.listing.id,
        userId: widget.listing.userId,
        title: _titleController.text,
        typeOfPlace: widget.listing.typeOfPlace,
        method: widget.listing.method,
        countryRegion: widget.listing.countryRegion,
        addressLine1: widget.listing.addressLine1,
        addressLine2: widget.listing.addressLine2,
        city: widget.listing.city,
        province: widget.listing.province,
        postalCode: widget.listing.postalCode,
        noOfGuests: widget.listing.noOfGuests,
        noOfBedrooms: widget.listing.noOfBedrooms,
        noOfBeds: widget.listing.noOfBeds,
        noOfBathrooms: widget.listing.noOfBathrooms,
        description: _descriptionController.text,
        price: int.parse(_priceController.text),
        offers: amenitiesArray, // Using the fresh array copy
        coverImage: widget.listing.coverImage,
        images: widget.listing.images,
        status: widget.listing.status,
        planName: widget.listing.planName,
        planPrice: widget.listing.planPrice,
        planDurationDays: widget.listing.planDurationDays,
      );

      final listingController = Provider.of<ListingController>(
        context,
        listen: false,
      );
      
      await listingController.updateListing(
        updatedListing,
        coverImage: _newCoverImage,
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating listing: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitUpdate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Image Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cover Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickCoverImage,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _newCoverImage != null
                                ? Image.file(_newCoverImage!, fit: BoxFit.cover)
                                : widget.listing.coverImage != null
                                    ? Image.network(
                                        widget.listing.coverImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(Icons.broken_image, size: 50),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: Icon(Icons.add_a_photo, size: 50),
                                      ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price per month',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 100) {
                          return 'Description should be at least 100 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Amenities
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amenities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'WiFi',
                            'Kitchen',
                            'Washer',
                            'Air conditioning',
                            'Heating',
                            'TV',
                            'Parking',
                            'Pool',
                            'Gym',
                          ].map((amenity) {
                            final isSelected = _selectedAmenities.contains(amenity);
                            return FilterChip(
                              label: Text(amenity),
                              selected: isSelected,
                              onSelected: (_) => _toggleAmenity(amenity),
                              selectedColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              checkmarkColor: Theme.of(context).primaryColor,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}