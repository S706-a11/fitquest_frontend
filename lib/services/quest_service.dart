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
  static Future<List<dynamic>> getUserQuests(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/quests'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load quests');
  }

  /// Get active quests for a user
  static Future<List<dynamic>> getActiveQuests(String userId) async {
    print('QuestService: GET $baseUrl/users/$userId/quests/active');
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/active'),
    );
    print(
      'QuestService: Active quests response status: ${response.statusCode}',
    );
    print('QuestService: Active quests response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      print('QuestService: Parsed ${data.length} active quests');
      return data;
    }
    throw Exception(
      'Failed to load active quests: ${response.statusCode} - ${response.body}',
    );
  }

  /// Get completed quests for a user
  static Future<List<dynamic>> getCompletedQuests(String userId) async {
    print('QuestService: GET $baseUrl/users/$userId/quests/completed');
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/completed'),
    );
    print(
      'QuestService: Completed quests response status: ${response.statusCode}',
    );
    print('QuestService: Completed quests response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      print('QuestService: Parsed ${data.length} completed quests');
      return data;
    }
    throw Exception(
      'Failed to load completed quests: ${response.statusCode} - ${response.body}',
    );
  }

  /// Get available quest templates for user's level
  static Future<List<dynamic>> getAvailableQuests(String userId) async {
    print('QuestService: GET $baseUrl/users/$userId/quests/available');
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/available'),
    );
    print(
      'QuestService: Available quests response status: ${response.statusCode}',
    );
    print('QuestService: Available quests response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      print('QuestService: Parsed ${data.length} available quest templates');
      return data;
    }
    throw Exception(
      'Failed to load available quests: ${response.statusCode} - ${response.body}',
    );
  }

  /// Claim a quest from a template
  static Future<Map<String, dynamic>> claimQuest({
    required String userId,
    required int templateId,
  }) async {
    print('QuestService: POST $baseUrl/users/$userId/quests/$templateId/claim');
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/quests/$templateId/claim'),
      headers: {'Content-Type': 'application/json'},
    );

    print('QuestService: Claim quest response status: ${response.statusCode}');
    print('QuestService: Claim quest response body: ${response.body}');

    return _handleResponse(response);
  }

  /// Create a new quest
  static Future<Map<String, dynamic>> createQuest({
    required String userId,
    required String title,
    required String description,
    int? xpReward,
    String? priority,
    String? dueDate,
  }) async {
    // Priority should be an integer enum: 0=Low, 1=Medium, 2=High, 3=Critical
    int priorityValue;
    switch (priority?.toLowerCase()) {
      case 'low':
        priorityValue = 0;
        break;
      case 'medium':
        priorityValue = 1;
        break;
      case 'high':
        priorityValue = 2;
        break;
      case 'critical':
        priorityValue = 3;
        break;
      default:
        priorityValue = 1; // Default to Medium
    }

    // Backend expects capitalized field names
    final body = {
      'Title': title,
      'Description': description,
      'XpReward': xpReward ?? 50,
      'Priority': priorityValue,
    };

    if (dueDate != null) {
      body['DueDate'] = dueDate;
    }

    print('QuestService: POST $baseUrl/users/$userId/quests');
    print('QuestService: Create quest body: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/quests'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    print('QuestService: Create quest response status: ${response.statusCode}');
    print('QuestService: Create quest response body: ${response.body}');

    return _handleResponse(response);
  }

  /// Toggle quest completion status
  static Future<Map<String, dynamic>> toggleQuestStatus({
    required String userId,
    required int questId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/quests/$questId/toggle'),
    );
    return _handleResponse(response);
  }

  /// Get a specific quest by ID
  static Future<Map<String, dynamic>> getQuestById({
    required String userId,
    required int questId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/$questId'),
    );
    return _handleResponse(response);
  }

  /// Update a quest
  static Future<Map<String, dynamic>> updateQuest({
    required String userId,
    required int questId,
    String? title,
    String? description,
    int? xpReward,
    String? priority,
    String? dueDate,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (xpReward != null) body['xpReward'] = xpReward;
    if (priority != null) body['priority'] = priority;
    if (dueDate != null) body['dueDate'] = dueDate;

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/quests/$questId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  /// Delete a quest
  static Future<void> deleteQuest({
    required String userId,
    required int questId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId/quests/$questId'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete quest: ${response.statusCode}');
    }
  }

  /// Get quest exercises
  static Future<List<dynamic>> getQuestExercises({
    required String userId,
    required int questId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/quests/$questId/exercises'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load quest exercises');
  }

  /// Add exercise to quest
  static Future<Map<String, dynamic>> addExerciseToQuest({
    required String userId,
    required int questId,
    required int exerciseId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/quests/$questId/exercises/$exerciseId'),
    );
    return _handleResponse(response);
  }

  /// Remove exercise from quest
  static Future<void> removeExerciseFromQuest({
    required String userId,
    required int questId,
    required int exerciseId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId/quests/$questId/exercises/$exerciseId'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to remove exercise: ${response.statusCode}');
    }
  }

  /// Generate quest templates (admin/testing function)
  static Future<Map<String, dynamic>> generateQuestTemplates({
    int? count,
    bool? saveToDatabase,
    bool? addVariance,
    bool? returnTemplates,
    List<String>? categories,
    List<String>? difficulties,
  }) async {
    final body = <String, dynamic>{};

    if (count != null) body['count'] = count;
    if (saveToDatabase != null) body['saveToDatabase'] = saveToDatabase;
    if (addVariance != null) body['addVariance'] = addVariance;
    if (returnTemplates != null) body['returnTemplates'] = returnTemplates;
    if (categories != null && categories.isNotEmpty) {
      body['categories'] = categories;
    }
    if (difficulties != null && difficulties.isNotEmpty) {
      body['difficulties'] = difficulties;
    }

    print('QuestService: POST $baseUrl/generate-quest-templates');
    print('QuestService: Generate templates body: $body');

    final response = await http.post(
      Uri.parse('$baseUrl/generate-quest-templates'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    print(
      'QuestService: Generate templates response status: ${response.statusCode}',
    );
    print('QuestService: Generate templates response body: ${response.body}');

    return _handleResponse(response);
  }
}
