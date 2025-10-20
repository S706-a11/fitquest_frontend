import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for managing user-related API calls
class UserService {
  static const String baseUrl = 'http://localhost:5105/api';

  /// Helper method to handle HTTP responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get all users
  static Future<Map<String, dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    return _handleResponse(response);
  }

  /// Create a new user
  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    String? password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'displayName': name, // Backend expects displayName
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  /// Get user by ID
  static Future<Map<String, dynamic>> getUserById(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    return _handleResponse(response);
  }

  /// Update user information
  static Future<Map<String, dynamic>> updateUser({
    required int userId,
    String? name,
    String? email,
    int? level,
    int? xp,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['displayName'] = name; // Backend expects displayName
    if (email != null) body['email'] = email;
    if (level != null) body['level'] = level;
    if (xp != null) body['xp'] = xp;

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return _handleResponse(response);
  }
}
