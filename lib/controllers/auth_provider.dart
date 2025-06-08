import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbanest_app/model/user.dart';
import 'package:urbanest_app/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _error = '';
  User? _currentUser;

  bool get isLoading => _isLoading;
  String get error => _error;
  User? get currentUser => _currentUser;

  // Initialize auth provider with saved user data
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      _currentUser = User.fromJson(userMap);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final user = await _apiService.login(email, password);
      _currentUser = user;
      
      // Save user to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', jsonEncode(user.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final user = await _apiService.register(
        name,
        email,
        password,
        passwordConfirmation,
      );
      _currentUser = user;
      
      // Save user to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', jsonEncode(user.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    
    // Remove user from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    
    notifyListeners();
  }
}