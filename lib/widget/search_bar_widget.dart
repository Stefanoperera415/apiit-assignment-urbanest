import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSearch;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search properties...',
          hintStyle: TextStyle(fontSize: 14, color: theme.hintColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, size: 22, color: theme.iconTheme.color),
            onPressed: onSearch ?? () {},
            padding: EdgeInsets.zero,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
        ),
        style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
      ),
    );
  }
}
