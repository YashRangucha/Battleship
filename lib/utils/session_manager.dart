import 'package:shared_preferences/shared_preferences.dart';

/// A class to manage session tokens in shared preferences. Used for
/// keeping track of logged in users in eg3
class SessionManager {
  static const String _sessionKey = 'sessionToken';
  static const String _expiryKey = 'sessionExpiry';
  static const String _usernameKey = 'loggedInUsername';

  // Method to check if a user is logged in (has an active session).
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString(_sessionKey);
    final expiryTimestamp = prefs.getInt(_expiryKey);

    return sessionToken != null &&
        expiryTimestamp != null &&
        DateTime.now().millisecondsSinceEpoch < expiryTimestamp;
    // Check if the session is not expired
  }

  // Method to retrieve the session token.
  static Future<String> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey) ?? '';
  }

  // Method to set the session token.
  static Future<void> setSessionToken(
      String token, int expiryTime, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, token);
    await prefs.setInt(_expiryKey, expiryTime);
    await prefs.setString(_usernameKey, username);
  }

  static Future<String> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? ' ';
  }

  // Method to clear the session token, effectively logging the user out.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_expiryKey);
  }
}
