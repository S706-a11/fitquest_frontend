import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.register(name, email, password);
      print('user after registration: $_user');
      if (_user == null) {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
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
        _error = 'Registration failed. Please try again.';
      }
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
      final response = await ApiService.getUserById(int.parse(_user!.id));

      _user = User.fromJson(response);
      notifyListeners();
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // Update XP
  Future<void> addXp(int xpAmount) async {
    if (_user == null) return;

    try {
      final newXp = _user!.xp + xpAmount;
      int newLevel = _user!.level;
      int remainingXp = newXp;

      // Level up logic
      while (remainingXp >= newLevel * 100) {
        remainingXp -= newLevel * 100;
        newLevel++;
      }

      await ApiService.updateUser(
        userId: int.parse(_user!.id),
        level: newLevel,
        xp: remainingXp,
      );

      await refreshUser();
    } catch (e) {
      print('Error updating XP: $e');
    }
  }

  // Manually set user (e.g. after profile update)
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Clear user data (e.g. on logout/delete)
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
