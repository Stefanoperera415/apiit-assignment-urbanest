import 'package:flutter/material.dart';

class AmenitiesPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, bool> amenities;
  final Function(String, bool) onAmenityChanged;

  const AmenitiesPage({
    Key? key,
    required this.formKey,
    required this.amenities,
    required this.onAmenityChanged,
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
              'Select Amenities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose all that apply to your property',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amenities.keys.map((key) {
                return GestureDetector(
                  onTap: () {
                    // Toggles the selected state
                    onAmenityChanged(key, !(amenities[key] ?? false));
                  },
                  child: Chip(
                    label: Text(
                      key,
                      style: TextStyle(
                        color: amenities[key]!
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    backgroundColor: amenities[key]!
                        ? (isDark ? Colors.white12 : Colors.black.withOpacity(0.1))
                        : (isDark ? Colors.black26 : Colors.grey[300]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: amenities[key]!
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark ? Colors.white38 : Colors.grey[400]!),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
