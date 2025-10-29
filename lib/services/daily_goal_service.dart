import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client for Daily Goal related endpoints.
class DailyGoalService {
  static const String baseUrl = 'http://localhost:5105/api';

  /// Recompute a daily goal's progress from exercises that started on the goal's DateYmd (UTC).
  ///
  /// Calls POST /api/daily-goals/{id}/recompute-from-exercises?updateStatus=true|false
  /// Returns the deserialized JSON response if the endpoint returns a body, otherwise an empty map.
  static Future<Map<String, dynamic>> recomputeFromExercises({
    required String goalId,
    bool updateStatus = true,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/daily-goals/$goalId/recompute-from-exercises',
    ).replace(queryParameters: {'updateStatus': updateStatus.toString()});

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return <String, dynamic>{};
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{'result': response.body};
      }
    }

    throw Exception(
      'Failed to recompute daily goal: ${response.statusCode} ${response.body}',
    );
  }
}
