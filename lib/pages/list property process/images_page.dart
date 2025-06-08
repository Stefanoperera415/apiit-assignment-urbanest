import 'dart:io';
import 'package:flutter/material.dart';

class ImagesPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final File? coverImage;
  final List<File?> otherImages;
  final Function(int, bool) onPickImage;

  const ImagesPage({
    Key? key,
    required this.formKey,
    required this.coverImage,
    required this.otherImages,
    required this.onPickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Images',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload high-quality photos to showcase your property',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Cover Image
          Text(
            'Cover Image (Main Photo)',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onPickImage(0, true),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                border: Border.all(
                  color: isDark ? Colors.white38 : Colors.grey[300]!,
                  width: coverImage == null ? 1 : 0,
                ),
              ),
              child: coverImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(coverImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: isDark ? Colors.white70 : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add cover photo',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Additional Images
          Text(
            'Additional Images (up to 4)',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: List.generate(4, (index) {
              return GestureDetector(
                onTap: () => onPickImage(index, false),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    border: Border.all(
                      color: isDark ? Colors.white38 : Colors.grey[300]!,
                      width: otherImages[index] == null ? 1 : 0,
                    ),
                  ),
                  child: otherImages[index] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(otherImages[index]!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 30,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add photo ${index + 1}',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
