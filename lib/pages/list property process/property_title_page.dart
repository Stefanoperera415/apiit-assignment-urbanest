import 'package:flutter/material.dart';


class PropertyTitlePage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String propertyTitle;
  final Function(String) onChanged;

  const PropertyTitlePage({
    Key? key,
    required this.formKey,
    required this.propertyTitle,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Give your property a title',
              style: TextStyle(
                fontSize: 25, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make it descriptive and attractive to potential buyers/renters',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Property Title',
                hintText: 'e.g. Beautiful 3-Bedroom Apartment in Downtown',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87, 
                  fontWeight: FontWeight.w600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white38 : Colors.black87,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white70 : Colors.black87,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white38 : Colors.black54,
                  ),
                ),
                filled: true,
                fillColor: isDark ? Colors.black12 : Colors.grey[50],
              ),
              style: TextStyle(
                fontSize: 14, 
                color: isDark ? Colors.white : Colors.black,
              ),
              initialValue: propertyTitle,
              onChanged: onChanged,
              validator: (val) => val == null || val.isEmpty
                  ? 'Please enter property title'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
