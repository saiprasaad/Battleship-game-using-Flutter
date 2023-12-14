import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'sessionToken';
  static const String _userName = 'userName';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString(_sessionKey);
    return sessionToken != null;
  }

  static Future<String> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey) ?? '';
  }

  static Future<void> setSessionTokenAndUserName(String token, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, token);
    await prefs.setString(_userName, username);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<String> getUserNameOfLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName) ?? '';
  }
}
