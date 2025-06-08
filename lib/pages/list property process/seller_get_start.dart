import 'package:flutter/material.dart';
import 'package:urbanest_app/pages/list%20property%20process/property_listing_screen.dart';
import 'package:urbanest_app/widget/custom_button.dart';

class SellerGetStart extends StatelessWidget {
  const SellerGetStart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // Adjust background for dark mode
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white, // Adjust app bar for dark mode
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black), // Adjust icon color for dark mode
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 145),
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white70 : Colors.white, // Adjust container color for dark mode
                  shape: BoxShape.circle
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/Urbanest.png",
                    fit: BoxFit.contain,
                    height: 100,
                  ),
                ),
              ),
             
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Colors.green, Colors.blue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                child: const Text(
                  "Start your Journey with Urbanest",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // This is required for ShaderMask
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Fill out the form to get your property listed',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white70 : Colors.black54, // Adjust text color for dark mode
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 90),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> PropertyListingScreen())),
                  child: CustomButton(
                    buttonName: "Get Started",
                    buttonColor: isDarkMode ? Colors.white: Colors.black87,
                    borderRadiusButton: 25,
                    borderColor: Colors.transparent,
                    buttonNameColor:isDarkMode ? Colors.black87: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
