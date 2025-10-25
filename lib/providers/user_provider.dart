import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Load user on app start
  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.login(email, password);
      if (_user == null) {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    print('UserProvider: Starting registration for $name, $email');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.register(name, email, password);
      print('UserProvider: AuthService.register returned user: ${_user?.id}');

      if (_user == null) {
        _error = 'Registration failed';
        print('UserProvider: Registration failed - user is null');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('UserProvider: Registration successful for user ${_user!.id}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('UserProvider: Registration exception: $e');

      // Parse error message for user-friendly feedback
      final errorStr = e.toString();
      if (errorStr.contains('duplicate key') ||
          errorStr.contains('IX_users_email')) {
        _error =
            'This email is already registered. Please login or use a different email.';
      } else if (errorStr.contains('display_name') ||
          errorStr.contains('not-null constraint')) {
        _error = 'Name is required. Please enter your name.';
      } else if (errorStr.contains('500')) {
        _error = 'Server error. Please try again later.';
      } else if (errorStr.contains('400')) {
        _error = 'Invalid input. Please check your information.';
      } else {
        _error = errorStr; // Show the actual error message for debugging
      }

      print('UserProvider: Set error message: $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_user == null) return;

    try {
      final updatedUser = await UserService.getUserById(_user!.id);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // Set user (for profile updates)
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Clear user (for logout/delete)
  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Update XP
  Future<void> addXp(int xpAmount) async {
    if (_user == null) return;

    try {
      // Prefer backend to award XP and handle level-ups atomically
      await UserService.addXp(userId: _user!.id, xpAmount: xpAmount);
      await refreshUser();
    } catch (e) {
      print('Error updating XP: $e');
    }
  }

  // Ensure user is not over-cap on XP; if XP >= level*100, let backend normalize
  // by calling addXp with 0 (no-op award that should trigger re-evaluation server-side).
  // Returns true if a level-up occurred.
  Future<bool> ensureLevelConsistency() async {
    if (_user == null) return false;
    try {
      final beforeLevel = _user!.level;
      final cap = beforeLevel * 100;
      if (_user!.xp >= cap) {
        await UserService.addXp(userId: _user!.id, xpAmount: 0);
        await refreshUser();
        return _user!.level > beforeLevel;
      }
    } catch (e) {
      print('ensureLevelConsistency error: $e');
    }
    return false;
  }
}
