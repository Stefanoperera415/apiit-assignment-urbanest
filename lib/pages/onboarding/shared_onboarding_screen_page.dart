import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SharedOnboardingScreen extends StatelessWidget {

  final String title;
  final String imageUrl;
  final String description;

  const SharedOnboardingScreen({super.key, required this.title, required this.imageUrl, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            imageUrl,
            width: 250,
           
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      
          SizedBox(
            height: 20,
          ),
      
          Text(description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}