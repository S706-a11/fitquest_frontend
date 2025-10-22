import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for managing exercise-related API calls
class ExerciseService {
  static const String baseUrl = 'http://localhost:5105/api';

  /// Get all exercises
  static Future<List<dynamic>> getExercises() async {
    final response = await http.get(Uri.parse('$baseUrl/exercises'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load exercises');
  }

  /// Get all exercise types
  static Future<List<dynamic>> getExerciseTypes() async {
    final response = await http.get(Uri.parse('$baseUrl/exercise-types'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load exercise types');
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
}
