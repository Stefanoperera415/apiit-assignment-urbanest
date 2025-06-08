import 'package:flutter/material.dart';

class CapacityPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final int guests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final Function(int) onGuestsChanged;
  final Function(int) onBedroomsChanged;
  final Function(int) onBedsChanged;
  final Function(int) onBathroomsChanged;

  const CapacityPage({
    Key? key,
    required this.formKey,
    required this.guests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.onGuestsChanged,
    required this.onBedroomsChanged,
    required this.onBedsChanged,
    required this.onBathroomsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Property Capacity',
              style: TextStyle(fontSize:  20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildStepperInput(
              label: 'Number of Guests',
              value: guests,
              onChanged: onGuestsChanged,
            ),
            const SizedBox(height: 16),
            _buildStepperInput(
              label: 'Bedrooms',
              value: bedrooms,
              onChanged: onBedroomsChanged,
            ),
            const SizedBox(height: 16),
            _buildStepperInput(
              label: 'Beds',
              value: beds,
              onChanged: onBedsChanged,
            ),
            const SizedBox(height: 16),
            _buildStepperInput(
              label: 'Bathrooms',
              value: bathrooms,
              onChanged: onBathroomsChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperInput({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.grey),
                onPressed: () {
                  if (value > 1) onChanged(value - 1);
                },
              ),
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}