// main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/auth_provider.dart';
import 'package:urbanest_app/controllers/booking_provider.dart';
import 'package:urbanest_app/controllers/listing_provider.dart';
import 'package:urbanest_app/controllers/make_an_offer_provider.dart';
import 'package:urbanest_app/controllers/rent_request_provider.dart';
import 'package:urbanest_app/controllers/seller_dashboard_provider.dart';
import 'package:urbanest_app/pages/list%20property%20process/property_listing_screen.dart';
import 'package:urbanest_app/pages/login_page.dart';
import 'package:urbanest_app/pages/main_page.dart';
import 'package:urbanest_app/pages/onboarding/onbroading_screen.dart';
import 'package:urbanest_app/services/api_service.dart';
import 'package:urbanest_app/theme_provider.dart';
import 'package:urbanest_app/widget/favouites_provider.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingController(ApiService())),
        ChangeNotifierProvider(
          create: (_) => ListingController(ApiService()),
          child: PropertyListingScreen(),
        ),
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => BookingController(ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => RentRequestController(ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => MakeAnOfferController(ApiService()),
        ),
        ChangeNotifierProvider(create: (context) => SellerDashboardProvider(context.read<ApiService>())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Urbanest",
          themeMode: themeProvider.currentTheme,
          theme: ThemeData(
            fontFamily: GoogleFonts.poppins().fontFamily,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey[100],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black87,
              unselectedItemColor: Colors.grey,
            ),
            cardColor: Colors.white,
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              bodyMedium: TextStyle(color: Colors.black87),
              bodySmall: TextStyle(color: Colors.black54),
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: Colors.white,
              filled: true,
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: GoogleFonts.poppins().fontFamily,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
              elevation: 1,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1F1F1F),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
            ),
            cardColor: const Color(0xFF1E1E1E),
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              bodyMedium: TextStyle(color: Colors.white70),
              bodySmall: TextStyle(color: Colors.white54),
            ),
            iconTheme: const IconThemeData(color: Colors.white70),
            inputDecorationTheme: const InputDecorationTheme(
              fillColor: Color(0xFF2A2A2A),
              filled: true,
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          home: const SplashScreen(),
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginPage(),
            '/main': (context) => const MainPage(),
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Add a small delay for the splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Initialize auth provider (loads saved user data)
    await authProvider.initialize();
    
    // Check if user is logged in
    if (authProvider.currentUser != null) {
      // User is logged in, go to main page
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      // User is not logged in, go to onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/Urbanest.png'),
          fit: BoxFit.contain,
          height: 150,
        ),
      ),
    );
  }
}