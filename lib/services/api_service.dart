import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5105/api';

  // Helper method to handle HTTP responses
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

  // User endpoints
  static Future<Map<String, dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    String? password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'displayName': name, // Backend expects displayName
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  //login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getUserById(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    return _handleResponse(response);
  }

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

  // Quest endpoints
  static Future<List<dynamic>> getUserQuests(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/quests'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load quests');
  }

  static Future<List<dynamic>> getActiveQuests(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/active'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load active quests');
  }

  static Future<List<dynamic>> getCompletedQuests(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/completed'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load completed quests');
  }

  static Future<Map<String, dynamic>> createQuest({
    required int userId,
    required String title,
    required String description,
    int? xpReward,
    String? priority,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/quests'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'description': description,
        'xpReward': xpReward ?? 50,
        'priority': priority ?? 'Medium',
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> toggleQuestStatus({
    required int userId,
    required int questId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/quests/$questId/toggle'),
    );
    return _handleResponse(response);
  }

  // Exercise endpoints
  static Future<List<dynamic>> getExercises() async {
    final response = await http.get(Uri.parse('$baseUrl/exercises'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load exercises');
  }

  static Future<List<dynamic>> getExerciseTypes() async {
    final response = await http.get(Uri.parse('$baseUrl/exercise-types'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load exercise types');
  }
}
