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
    print('UserService: POST $baseUrl/users/register');
    print(
      'UserService: Register data - email: $email, displayName: $displayName',
    );

    final requestBody = {
      'email': email,
      'password': password,
      'displayName': displayName,
    };

    print('UserService: Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('UserService: Register response status: ${response.statusCode}');
    print('UserService: Register response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final userData = jsonDecode(response.body) as Map<String, dynamic>;
      print('UserService: Successfully parsed user data: $userData');
      return User.fromJson(userData);
    } else {
      final errorMsg =
          'Failed to register user: Status ${response.statusCode}, Body: ${response.body}';
      print('UserService: Registration failed - $errorMsg');
      throw Exception(errorMsg);
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

  // Get leaderboard
  // Expected endpoint: GET /users/leaderboard or GET /leaderboard
  // Returns a list of leaderboard entries (flexible shape)
  // Fetch leaderboard
  // metric: 'level'|'xp'|'streak'
  // limit: number between 1 and 100
  static Future<List<dynamic>> getLeaderboard({String metric = 'level', int limit = 50}) async {
    final q = {
      'metric': metric,
      'limit': limit.toString(),
    };

    final urls = [
      Uri.parse('$baseUrl/users/leaderboard').replace(queryParameters: q),
      Uri.parse('$baseUrl/leaderboard').replace(queryParameters: q),
    ];

    for (final uri in urls) {
      try {
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body is List) return body;
          if (body is Map && body['data'] is List) return body['data'] as List<dynamic>;
        }
      } catch (_) {
        // ignore and try next
      }
    }

    throw Exception('Failed to load leaderboard');
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
