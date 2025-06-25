import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  void _initializeAuth() {
    _user = _authService.currentUser;
    _authService.authStateChanges.listen((authState) {
      _user = authState.session?.user;
      notifyListeners();
    });
  }

  // Sign in with navigation
  Future<bool> signInWithNavigation(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signInWithEmailAndPassword(email, password);

      if (context.mounted) {
        // Navigate to home using GoRouter
        context.go('/home');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Legacy sign in method (kept for backward compatibility)
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with navigation
  Future<bool> signUpWithNavigation(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.createUserWithEmailAndPassword(email, password);

      if (context.mounted) {
        // Navigate back to login screen using GoRouter
        context.go('/login');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Legacy sign up method (kept for backward compatibility)
  Future<bool> signUp(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.createUserWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out with navigation
  Future<void> signOutWithNavigation(BuildContext context) async {
    try {
      _setLoading(true);
      await _authService.signOut();

      if (context.mounted) {
        // Clear all navigation stack and go to login using GoRouter
        context.go('/login');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Legacy sign out method
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Remember login state
  Future<void> saveRememberMe(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', remember);
  }

  // Check if remember me is enabled
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberMe') ?? false;
  }

  // Save user credentials (only if remember me is enabled)
  Future<void> saveCredentials(
    String email,
    String password,
    bool remember,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString('savedEmail', email);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedEmail');
      await prefs.setBool('rememberMe', false);
    }
  }

  // Get saved credentials
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberMe') ?? false;
    if (remember) {
      return prefs.getString('savedEmail');
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  Future<bool> isFirstTimeOpened() async {
    return await _authService.isFirstTimeOpened();
  }

  Future<void> setFirstTimeOpened() async {
    await _authService.setFirstTimeOpened();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
