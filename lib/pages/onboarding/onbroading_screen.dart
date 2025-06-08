import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:urbanest_app/data/onboarding_data.dart';
import 'package:urbanest_app/pages/login_page.dart';
import 'package:urbanest_app/pages/onboarding/front_page.dart';
import 'package:urbanest_app/pages/onboarding/shared_onboarding_screen_page.dart';
import 'package:urbanest_app/widget/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool showDetailsPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      showDetailsPage = index == 3;
                    });
                  },
                  children: [
                    FrontPage(),
                    SharedOnboardingScreen(
                      title: OnboardingData().onboardingDataList[0].title,
                      imageUrl: OnboardingData().onboardingDataList[0].imageUrl,
                      description:
                          OnboardingData().onboardingDataList[0].description,
                    ),
                    SharedOnboardingScreen(
                      title: OnboardingData().onboardingDataList[1].title,
                      imageUrl: OnboardingData().onboardingDataList[1].imageUrl,
                      description:
                          OnboardingData().onboardingDataList[1].description,
                    ),
                    SharedOnboardingScreen(
                      title: OnboardingData().onboardingDataList[2].title,
                      imageUrl: OnboardingData().onboardingDataList[2].imageUrl,
                      description:
                          OnboardingData().onboardingDataList[2].description,
                    ),
                  ],
                ),
                
                Positioned(
                  
                  bottom: 150, 
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: 4,
                      effect: WormEffect(
                        activeDotColor: Colors.black,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: GestureDetector(
                      onTap: () {
                        if (showDetailsPage) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: CustomButton(
                        buttonName: showDetailsPage ? "Get Started" : "Next",
                        buttonColor: Colors.black,
                        borderRadiusButton: 100,
                        borderColor: Colors.transparent,
                        buttonNameColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}