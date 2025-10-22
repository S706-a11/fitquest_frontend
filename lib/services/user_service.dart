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

  //Get all users
  static Future<List<dynamic>> getUsers() async {
    return [];
  }

  //Create new user
  static Future<dynamic> createUser() async {
    return {};
  }
}
