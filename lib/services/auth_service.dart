import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'user_service.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Login - finds user by email or creates demo login
  static Future<User?> login(String email, String password) async {
    try {
      // Get all users and find by email
      final response = await UserService.getUsers();

      // The API returns a list of users
      final List<dynamic> users =
          (response is List)
              ? response as List<dynamic>
              : (response as List<dynamic>);

      // Find user by email (case insensitive)
      dynamic userJson;
      try {
        userJson = users.firstWhere(
          (u) => u['email'].toString().toLowerCase() == email.toLowerCase(),
        );
      } catch (e) {
        userJson = null;
      }

      if (userJson != null) {
        final user = User.fromJson(userJson);
        await _saveUserLocally(user);
        return user;
      }

      // If user not found, return null
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Register - creates new user
  static Future<User?> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      // final response = await UserService.createUser(
      //   name: name,
      //   email: email,
      //   password: password,
      // );

      // final user = User.fromJson(response);
      // await _saveUserLocally(user);
      // return user;
    } catch (e) {
      print('Registration error: $e');
      rethrow; // Re-throw to let the UI handle specific error messages
    }
  }

  // Save user data locally
  static Future<void> _saveUserLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.displayName);
    await prefs.setString(_userEmailKey, user.email);
  }

  // Get current user from local storage
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);

    if (userId == null) return null;

    try {
      // Fetch fresh user data from API
      final response = await UserService.getUserById(userId);
      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching user: $e');
      // Fallback to cached data
      final name = prefs.getString(_userNameKey);
      final email = prefs.getString(_userEmailKey);

      if (name != null && email != null) {
        return User(
          id: userId,
          email: email,
          displayName: name,
          avatarUrl: '',
          level: 1,
          xp: 0,
          streakCount: 0,
          weightKg: 0.0,
          heightCm: 0.0,
          createdAt: DateTime.now(),
        );
      }
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userIdKey);
  }
}
