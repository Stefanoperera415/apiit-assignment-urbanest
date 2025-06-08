
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DescriptionPricePage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String description;
  final String price;
  final Function(String) onDescriptionChanged;
  final Function(String) onPriceChanged;

  const DescriptionPricePage({
    Key? key,
    required this.formKey,
    required this.description,
    required this.price,
    required this.onDescriptionChanged,
    required this.onPriceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Section
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: const ValueKey('description_section'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Property Description',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Describe your property in detail to attract potential buyers/renters',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: description,
                    maxLines: 5,
                    minLines: 3,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe the property features, location advantages, etc.',
                      hintStyle: TextStyle(fontSize: 13, color: isDarkMode ? Colors.white70 : Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 1.5,
                        ),
                      ),
                      labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(color: isDarkMode ? Colors.white : Colors.black),
                    onChanged: onDescriptionChanged,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Please enter a description' : null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Price Section
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: const ValueKey('price_section'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Pricing',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: price,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Price (LKR)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.dividerColor,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                      prefixIcon: Icon(
                        Icons.monetization_on,
                        color: theme.iconTheme.color?.withOpacity(0.6),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      suffixIcon: price.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: theme.hintColor),
                              onPressed: () => onPriceChanged(''),
                            )
                          : null,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(color: isDarkMode ? Colors.white : Colors.black),
                    onChanged: onPriceChanged,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter a price';
                      }
                      final n = num.tryParse(val);
                      if (n == null || n <= 0) {
                        return 'Enter a valid positive price';
                      }
                      return null;
                    },
                  ),
                  if (price.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'LKR ${_formatPrice(price)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(String price) {
    final number = num.tryParse(price);
    if (number == null) return '';
    
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }
}
