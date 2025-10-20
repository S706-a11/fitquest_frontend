import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for managing quest-related API calls
class QuestService {
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

  /// Get all quests for a user
  static Future<List<dynamic>> getUserQuests(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/quests'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load quests');
  }

  /// Get active quests for a user
  static Future<List<dynamic>> getActiveQuests(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/active'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load active quests');
  }

  /// Get completed quests for a user
  static Future<List<dynamic>> getCompletedQuests(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/completed'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load completed quests');
  }

  /// Create a new quest
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

  /// Toggle quest completion status
  static Future<Map<String, dynamic>> toggleQuestStatus({
    required int userId,
    required int questId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/quests/$questId/toggle'),
    );
    return _handleResponse(response);
  }
}
