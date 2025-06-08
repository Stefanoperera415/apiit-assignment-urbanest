import 'package:flutter/material.dart';

class BuildFeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;

  const BuildFeatureItem({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:isDarkMode? Colors.grey.shade600: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: isDarkMode ? Colors.white: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
