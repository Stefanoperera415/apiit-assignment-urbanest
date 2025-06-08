import 'package:flutter/material.dart';
import 'package:urbanest_app/pages/booking_page.dart';
import 'package:urbanest_app/pages/favourite_page.dart';
import 'package:urbanest_app/pages/homepage.dart';
import 'package:urbanest_app/pages/profile_page.dart' show ProfilePage;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    FavouritePage(),
    BookingsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        ),

        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,

        currentIndex: _currentIndex,
        onTap: (index) {
          if (index >= 0 && index < _pages.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 25),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 25),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, size: 25),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 25),
            label: 'Profile',
          ),
        ],
      ),
      body: _pages[_currentIndex],
    );
  }
}
