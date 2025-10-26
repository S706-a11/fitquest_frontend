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
  static Future<List<dynamic>> getUserExercises(String userId) async {
    print('=== getUserExercises DEBUG ===');
    print('userId: $userId (type: ${userId.runtimeType})');

    // API returns paginated response: { items: [...], total: 10, page: 1, pageSize: 20 }
    final url = Uri.parse('$baseUrl/exercises?userId=$userId');
    print('GET request to: $url');

    final response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>?) ?? [];
      print('Found ${items.length} exercises');
      return items;
    }
    print('ERROR: Failed to load user exercises');
    throw Exception('Failed to load user exercises');
  }

  /// Create a new exercise for a user
  static Future<Map<String, dynamic>> createExercise({
    required String userId,
    required int exerciseTypeId,
    String? note,
    int? repsPerSet,
    int? sets,
    double? weightKg,
    DateTime? startAt,
    DateTime? endAt,
    int? questId,
  }) async {
    print('=== ExerciseService.createExercise DEBUG ===');
    print('userId: $userId (type: ${userId.runtimeType})');
    print(
      'exerciseTypeId: $exerciseTypeId (type: ${exerciseTypeId.runtimeType})',
    );

    final url = Uri.parse('$baseUrl/exercises');
    final payload = <String, dynamic>{
      'userId': userId,
      'exerciseTypeId': exerciseTypeId,
      if (note != null) 'note': note,
      if (repsPerSet != null) 'repsPerSet': repsPerSet,
      if (sets != null) 'sets': sets,
      if (weightKg != null) 'weightKg': weightKg,
      if (startAt != null) 'startAt': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'endAt': endAt.toUtc().toIso8601String(),
      if (questId != null) 'questId': questId,
    };

    print('Payload: ${jsonEncode(payload)}');
    print('Sending POST to: $url');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      print('ERROR: API returned ${res.statusCode}');
      throw Exception('API Error: ${res.statusCode} - ${res.body}');
    }

    final result = jsonDecode(res.body) as Map<String, dynamic>;
    print('Successfully created exercise: $result');
    return result;
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
  static Future<void> deleteExercise(String exerciseId) async {
    // UUID string
    print('=== deleteExercise DEBUG ===');
    print('Deleting exerciseId: $exerciseId');

    final response = await http.delete(
      Uri.parse('$baseUrl/exercises/$exerciseId'),
    );

    print('Delete response status: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('ERROR deleting exercise: ${response.statusCode}');
      throw Exception('Failed to delete exercise: ${response.statusCode}');
    }

    print('Exercise deleted successfully');
  }

  /// Complete an exercise by setting endAt timestamp and optionally updating details
  /// You can pass sets, repsPerSet, weightKg, note to update those fields at completion time.
  /// Backend will auto-calculate totalReps, totalWeight, and duration.
  static Future<Map<String, dynamic>> completeExercise({
    required String exerciseId,
    int? sets,
    int? repsPerSet,
    double? weightKg,
    String? note,
  }) async {
    print('=== completeExercise DEBUG ===');
    print('Completing exerciseId: $exerciseId');

    // Build payload with endAt and any provided detail fields
    final payload = <String, dynamic>{
      'endAt': DateTime.now().toUtc().toIso8601String(),
      if (sets != null) 'sets': sets,
      if (repsPerSet != null) 'repsPerSet': repsPerSet,
      if (weightKg != null) 'weightKg': weightKg,
      if (note != null) 'note': note,
    };

    print('Sending payload: ${json.encode(payload)}');

    final response = await http.put(
      Uri.parse('$baseUrl/exercises/$exerciseId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    print('Complete exercise response status: ${response.statusCode}');
    print('Complete exercise response body: ${response.body}');
    print('Complete exercise response headers: ${response.headers}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('❌ ERROR completing exercise: ${response.statusCode}');
      print('Error response body: ${response.body}');

      // Try to parse error details
      try {
        final errorData = json.decode(response.body);
        print('Error details: $errorData');
      } catch (e) {
        print('Could not parse error response as JSON');
      }

      throw Exception(
        'Failed to complete exercise: ${response.statusCode} - ${response.body}',
      );
    }

    print('✅ Exercise completed successfully');

    // Handle 204 No Content response (empty body)
    if (response.statusCode == 204 || response.body.isEmpty) {
      return {'success': true, 'exerciseId': exerciseId};
    }

    final result = json.decode(response.body) as Map<String, dynamic>;
    return result;
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
    required String userId,
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
      'CompletedAt': DateTime.now().toUtc().toIso8601String(),
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
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? exerciseType,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['startDate'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toUtc().toIso8601String();
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
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['startDate'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toUtc().toIso8601String();
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
      'CompletedAt': DateTime.now().toUtc().toIso8601String(),
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
  static Future<List<dynamic>> getUserAchievements(String userId) async {
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
    required String userId,
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
  static Future<List<dynamic>> getUserExerciseGoals(String userId) async {
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
