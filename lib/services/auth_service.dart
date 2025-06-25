import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Save login state
      await _saveLoginState(true);

      return response;
    } on AuthException catch (e) {
      throw _getAuthErrorMessage(e.message);
    }
  }

  // Create user with email and password
  Future<AuthResponse> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // DO NOT save login state after signup
      // User needs to login manually after signup
      if (response.user != null) {
        // Force sign out after successful signup
        await signOut();
      }

      return response;
    } on AuthException catch (e) {
      throw _getAuthErrorMessage(e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _saveLoginState(false);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _getAuthErrorMessage(e.message);
    }
  }

  // Save login state to SharedPreferences
  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // Check if user is logged in (from SharedPreferences)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Check if app is first time opened
  Future<bool> isFirstTimeOpened() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstTimeOpened') ?? true;
  }

  // Set first time opened to false
  Future<void> setFirstTimeOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTimeOpened', false);
  }

  // Get auth error message
  String _getAuthErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password.';
    } else if (message.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (message.contains('Password should be at least')) {
      return 'Password should be at least 6 characters.';
    } else if (message.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('Email not confirmed')) {
      return 'Please check your email and confirm your account.';
    }
    return message.isNotEmpty
        ? message
        : 'An error occurred. Please try again.';
  }
}
