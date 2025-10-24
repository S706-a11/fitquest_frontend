import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for managing exercise-related API calls
class ExerciseService {
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

  // ==================== Exercise Management ====================

  /// Get all exercises
  static Future<List<dynamic>> getExercises() async {
    final response = await http.get(Uri.parse('$baseUrl/exercises'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load exercises');
  }

  /// Get a specific exercise by ID
  static Future<Map<String, dynamic>> getExerciseById(int exerciseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises/$exerciseId'),
    );
    return _handleResponse(response);
  }

  /// Get exercises for a specific user
  static Future<List<dynamic>> getUserExercises(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/exercises'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load user exercises');
  }

  /// Create a new exercise for a user
  static Future<Map<String, dynamic>> createExercise({
    required int userId,
    required String name,
    required String exerciseType,
    String? description,
    int? duration,
    double? distance,
    int? reps,
    double? weight,
    int? calories,
  }) async {
    final body = {
      'UserId': userId,
      'Name': name,
      'ExerciseType': exerciseType,
      'Description': description,
      'Duration': duration,
      'Distance': distance,
      'Reps': reps,
      'Weight': weight,
      'Calories': calories,
    };

    // Remove null values
    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/exercises'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return _handleResponse(response);
  }

  /// Update an existing exercise
  static Future<Map<String, dynamic>> updateExercise({
    required int exerciseId,
    String? name,
    String? exerciseType,
    String? description,
    int? duration,
    double? distance,
    int? reps,
    double? weight,
    int? calories,
  }) async {
    final body = <String, dynamic>{};

    if (name != null) body['Name'] = name;
    if (exerciseType != null) body['ExerciseType'] = exerciseType;
    if (description != null) body['Description'] = description;
    if (duration != null) body['Duration'] = duration;
    if (distance != null) body['Distance'] = distance;
    if (reps != null) body['Reps'] = reps;
    if (weight != null) body['Weight'] = weight;
    if (calories != null) body['Calories'] = calories;

    final response = await http.put(
      Uri.parse('$baseUrl/exercises/$exerciseId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return _handleResponse(response);
  }

  /// Delete an exercise
  static Future<void> deleteExercise(int exerciseId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/exercises/$exerciseId'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete exercise: ${response.statusCode}');
    }
  }

  // ==================== Exercise Types ====================

  /// Get all exercise types
  static Future<List<dynamic>> getExerciseTypes() async {
    final response = await http.get(Uri.parse('$baseUrl/exercise-types'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load exercise types');
  }

  /// Get a specific exercise type by ID
  static Future<Map<String, dynamic>> getExerciseTypeById(int typeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercise-types/$typeId'),
    );
    return _handleResponse(response);
  }

  // ==================== Exercise Sessions ====================

  /// Log an exercise session
  static Future<Map<String, dynamic>> logExerciseSession({
    required int userId,
    required String exerciseType,
    required int duration, // in seconds
    double? distance, // in meters
    int? calories,
    List<Map<String, double>>? route, // GPS coordinates
    Map<String, dynamic>? metrics, // Additional metrics
    int? questId, // Optional quest to link
  }) async {
    final body = {
      'UserId': userId,
      'ExerciseType': exerciseType,
      'Duration': duration,
      'Distance': distance,
      'Calories': calories,
      'Route': route,
      'Metrics': metrics,
      'QuestId': questId,
      'CompletedAt': DateTime.now().toIso8601String(),
    };

    // Remove null values
    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/exercises/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return _handleResponse(response);
  }

  /// Get exercise sessions for a user
  static Future<List<dynamic>> getUserExerciseSessions({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
    String? exerciseType,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    if (exerciseType != null) {
      queryParams['exerciseType'] = exerciseType;
    }

    final uri = Uri.parse(
      '$baseUrl/users/$userId/exercises/sessions',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load exercise sessions');
  }

  /// Get exercise statistics for a user
  static Future<Map<String, dynamic>> getUserExerciseStats({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final uri = Uri.parse(
      '$baseUrl/users/$userId/exercises/stats',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri);
    return _handleResponse(response);
  }

  // ==================== Quest-Exercise Integration ====================

  /// Link an exercise to a quest
  static Future<Map<String, dynamic>> linkExerciseToQuest({
    required int questId,
    required int exerciseId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quests/$questId/exercises/$exerciseId'),
      headers: {'Content-Type': 'application/json'},
    );

    return _handleResponse(response);
  }

  /// Unlink an exercise from a quest
  static Future<void> unlinkExerciseFromQuest({
    required int questId,
    required int exerciseId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/quests/$questId/exercises/$exerciseId'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to unlink exercise from quest');
    }
  }

  /// Get exercises linked to a specific quest
  static Future<List<dynamic>> getQuestExercises(int questId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quests/$questId/exercises'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load quest exercises');
  }

  /// Submit exercise progress for a quest
  static Future<Map<String, dynamic>> submitQuestExerciseProgress({
    required int questId,
    required int exerciseId,
    required int duration,
    double? distance,
    int? reps,
    double? weight,
    int? calories,
  }) async {
    final body = {
      'ExerciseId': exerciseId,
      'Duration': duration,
      'Distance': distance,
      'Reps': reps,
      'Weight': weight,
      'Calories': calories,
      'CompletedAt': DateTime.now().toIso8601String(),
    };

    // Remove null values
    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/quests/$questId/progress'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return _handleResponse(response);
  }

  /// Get quest progress by exercise
  static Future<Map<String, dynamic>> getQuestProgress(int questId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quests/$questId/progress'),
    );
    return _handleResponse(response);
  }

  // ==================== Achievements & Goals ====================

  /// Get exercise achievements for a user
  static Future<List<dynamic>> getUserAchievements(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/exercises/achievements'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load achievements');
  }

  /// Set exercise goals for a user
  static Future<Map<String, dynamic>> setExerciseGoal({
    required int userId,
    required String goalType, // 'daily', 'weekly', 'monthly'
    required String metricType, // 'duration', 'distance', 'calories'
    required double targetValue,
    String? exerciseType,
  }) async {
    final body = {
      'UserId': userId,
      'GoalType': goalType,
      'MetricType': metricType,
      'TargetValue': targetValue,
      'ExerciseType': exerciseType,
    };

    body.removeWhere((key, value) => value == null);

    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/exercises/goals'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return _handleResponse(response);
  }

  /// Get exercise goals for a user
  static Future<List<dynamic>> getUserExerciseGoals(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/exercises/goals'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load exercise goals');
  }

  // ==================== Leaderboard ====================

  /// Get exercise leaderboard
  static Future<List<dynamic>> getExerciseLeaderboard({
    String? exerciseType,
    String? metric, // 'duration', 'distance', 'calories'
    String? period, // 'daily', 'weekly', 'monthly', 'allTime'
    int? limit,
  }) async {
    final queryParams = <String, String>{};

    if (exerciseType != null) queryParams['exerciseType'] = exerciseType;
    if (metric != null) queryParams['metric'] = metric;
    if (period != null) queryParams['period'] = period;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse(
      '$baseUrl/exercises/leaderboard',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load leaderboard');
  }
}
