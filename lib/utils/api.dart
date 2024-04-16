import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/GameDetails.dart';
import '../utils/session_manager.dart';

class API {
  static const String baseURL = 'http://165.227.117.48';

  static Future<Map<String, dynamic>> startGame(
      List<String> ships, String? ai) async {
    final url = Uri.parse('$baseURL/games');
    final token = await _getSessionToken();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'ships': ships, 'ai': ai}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start the game');
    }
  }

  static Future<void> logout() async {
    await SessionManager.clearSession();
  }

  // Modify this method based on the actual structure of your API response
  static Future<Map<String, dynamic>> getGameDetails() async {
    final url = Uri.parse('$baseURL/games');
    final token = await _getSessionToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('games')) {
        return {'games': responseData['games']};
      } else {
        throw Exception('Invalid API response: Missing "games" key');
      }
    } else {
      throw Exception('Failed to get game details');
    }
  }

  static Future<GameDetails> getGameDetailsById(int gameId) async {
    final url = Uri.parse('$baseURL/games/$gameId');
    final token = await _getSessionToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return GameDetails.fromJson(responseData);
    } else {
      throw Exception('Failed to load game details: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> playShot(int gameId, String shot) async {
    final url = Uri.parse('$baseURL/games/$gameId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getSessionToken()}',
      },
      body: jsonEncode({'shot': shot}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> cancelGame(int gameId) async {
    final url = Uri.parse('$baseURL/games/$gameId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${await _getSessionToken()}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to cancel the game');
    }
  }

  static Future<String> _getSessionToken() async {
    return await SessionManager.getSessionToken();
  }
}
