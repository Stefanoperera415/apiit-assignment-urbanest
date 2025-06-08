import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanest_app/controllers/auth_provider.dart';
import 'package:urbanest_app/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  //final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showSignup = false;
  
  late AnimationController _animationController;
  late Animation<double> _cardPositionAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _cardPositionAnimation = Tween<double>(
      begin: 0.4,
      end: 0.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
 // _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _toggleSignup() {
    setState(() {
      _showSignup = !_showSignup;
      if (_showSignup) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error)),
        );
      }
    }
  }
  
  Future<void> _signup() async {
    if (_signupFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );
      
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Background image with blur effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/pexels-kien-14498466.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Draggable white card
          AnimatedBuilder(
            animation: _cardPositionAnimation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * _cardPositionAnimation.value,
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 && _showSignup) {
                      _toggleSignup();
                    } else if (details.delta.dy < 0 && !_showSignup) {
                      _toggleSignup();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _showSignup ? _buildSignupForm(theme, isLoading) : _buildLoginForm(theme, isLoading),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginForm(ThemeData theme, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email_outlined, color: Colors.blueGrey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter an email";
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return "Please enter a valid email";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock_outline, color: Colors.blueGrey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword 
                      ? Icons.visibility_off_outlined 
                      : Icons.visibility_outlined,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter the password";
              if (value.length < 6) return 'Password must be at least 6 characters long';
              return null;
            },
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset functionality would go here')),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.blue[700], fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 3),
          ElevatedButton(
            onPressed: isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: Size(
                MediaQuery.of(context).size.width * 0.860,
                MediaQuery.of(context).size.height * 0.070,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _toggleSignup,
            child: Text(
              "Don't have an account? SignUp here",
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: <Widget>[
              Expanded(child: Divider(color: Colors.black, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('OR', style: TextStyle(color: Colors.black)),
              ),
              Expanded(child: Divider(color: Colors.black, thickness: 1)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google login would go here')),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/google (1).png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 30),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Facebook login would go here')),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1877F2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.facebook, size: 45, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSignupForm(ThemeData theme, bool isLoading) {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _toggleSignup,
              ),
              Text(
                'Create Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Full Name",
              prefixIcon: Icon(Icons.person_outline, color: Colors.blueGrey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter your name";
              return null;
            },
          ),
          const SizedBox(height: 20),
          // TextFormField(
          //   controller: _phoneController,
          //   keyboardType: TextInputType.phone,
          //   decoration: InputDecoration(
          //     labelText: "Phone Number",
          //     prefixIcon: Icon(Icons.phone_outlined, color: Colors.blueGrey),
          //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
          //     focusedBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(13),
          //       borderSide: BorderSide(color: Colors.black),
          //     ),
          //   ),
          //   validator: (value) {
          //     if (value == null || value.isEmpty) return "Please enter your phone number";
          //     return null;
          //   },
          // ),
          // const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email_outlined, color: Colors.blueGrey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter an email";
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return "Please enter a valid email";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock_outline, color: Colors.blueGrey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword 
                      ? Icons.visibility_off_outlined 
                      : Icons.visibility_outlined,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Please enter a password";
              if (value.length < 6) return 'Password must be at least 6 characters long';
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              prefixIcon: Icon(Icons.lock_outline, color: Colors.blueGrey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword 
                      ? Icons.visibility_off_outlined 
                      : Icons.visibility_outlined,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Please confirm your password";
              if (value != _passwordController.text) return "Passwords don't match";
              return null;
            },
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: isLoading ? null : _signup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: Size(
                MediaQuery.of(context).size.width * 0.860,
                MediaQuery.of(context).size.height * 0.070,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _toggleSignup,
            child: Text(
              "Already have an account? Login here",
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}