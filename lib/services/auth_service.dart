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
      print('AuthService: Starting login for $email');
      // Use the UserService login method which handles authentication
      final user = await UserService.login(email, password);
      print('AuthService: Login successful for user ${user.id}');

      await _saveUserLocally(user);
      print('AuthService: User data saved locally');

      // Verify save
      final prefs = await SharedPreferences.getInstance();
      print('AuthService: Saved userId: ${prefs.getString(_userIdKey)}');

      return user;
    } catch (e) {
      print('AuthService: Login error: $e');
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
      final user = await UserService.register(
        email: email,
        password: password,
        displayName: name,
      );

      await _saveUserLocally(user);
      return user;
    } catch (e) {
      print('Registration error: $e');
      rethrow; // Re-throw to let the UI handle specific error messages
    }
  }

  // Save user data locally
  static Future<void> _saveUserLocally(User user) async {
    print(
      'AuthService: Saving user locally - ID: ${user.id}, Name: ${user.displayName}, Email: ${user.email}',
    );
    final prefs = await SharedPreferences.getInstance();

    final success1 = await prefs.setString(_userIdKey, user.id);
    final success2 = await prefs.setString(_userNameKey, user.displayName);
    final success3 = await prefs.setString(_userEmailKey, user.email);

    print(
      'AuthService: Save results - ID: $success1, Name: $success2, Email: $success3',
    );
  }

  // Get current user from local storage
  static Future<User?> getCurrentUser() async {
    print('AuthService: Getting current user from local storage');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);

    print('AuthService: Retrieved userId: $userId');

    if (userId == null) {
      print('AuthService: No userId found in local storage');
      return null;
    }

    try {
      print('AuthService: Fetching user data from API for userId: $userId');
      // Fetch fresh user data from API
      final user = await UserService.getUserById(userId);
      print('AuthService: Successfully fetched user from API');
      return user;
    } catch (e) {
      print('AuthService: Error fetching user from API: $e');
      // Fallback to cached data
      final name = prefs.getString(_userNameKey);
      final email = prefs.getString(_userEmailKey);

      print('AuthService: Using cached data - Name: $name, Email: $email');

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
      print('AuthService: No cached data available');
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
