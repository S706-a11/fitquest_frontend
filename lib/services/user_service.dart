import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static const String baseUrl = 'http://localhost:5105/api';

  //Get user by ID
  static Future<User> getUserById(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load user');
    }
  }

  //login
  static Future<dynamic> login(String email, String password) async {
    //should send with json raw
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to log in');
    }
  }

  //Register/Create new user
  static Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'displayName': displayName,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  //Get all users
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load users');
    }
  }

  //Update user profile
  static Future<User> updateUser({
    required String userId,
    String? displayName,
    String? avatarUrl,
    double? weightKg,
    double? heightCm,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    if (weightKg != null) body['weightKg'] = weightKg;
    if (heightCm != null) body['heightCm'] = heightCm;

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  //Delete user
  static Future<void> deleteUser(String userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }

  //Get user stats/profile
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/stats'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load user stats');
    }
  }

  //Update user XP
  static Future<User> addXp({
    required String userId,
    required int xpAmount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/xp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'xpAmount': xpAmount}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to add XP: ${response.body}');
    }
  }

  //Update streak
  static Future<User> updateStreak(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/streak'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update streak: ${response.body}');
    }
  }
}
