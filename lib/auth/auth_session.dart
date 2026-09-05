import 'package:shared_preferences/shared_preferences.dart';

import '../api/login_response.dart';

class AuthSession {
  const AuthSession({
    required this.authToken,
    required this.user,
  });

  final String authToken;
  final LoginUserDetails user;

  String get restaurantName => user.restaurantName;
}

class AuthStorage {
  AuthStorage._();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _restaurantIdKey = 'restaurant_id';
  static const _restaurantNameKey = 'restaurant_name';
  static const _emailKey = 'session_email';
  static const _passwordKey = 'session_password';

  static Future<AuthSession?> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final restaurantName = prefs.getString(_restaurantNameKey);
      if (token == null || token.isEmpty || restaurantName == null) {
        return null;
      }
      return AuthSession(
        authToken: token,
        user: LoginUserDetails(
          id: prefs.getString(_userIdKey) ?? '',
          name: prefs.getString(_userNameKey) ?? '',
          restaurantId: prefs.getString(_restaurantIdKey) ?? '',
          restaurantName: restaurantName,
          email: prefs.getString(_emailKey) ?? '',
          password: prefs.getString(_passwordKey) ?? '',
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSession(AuthSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, session.authToken);
      await prefs.setString(_userIdKey, session.user.id);
      await prefs.setString(_userNameKey, session.user.name);
      await prefs.setString(_restaurantIdKey, session.user.restaurantId);
      await prefs.setString(_restaurantNameKey, session.user.restaurantName);
      await prefs.setString(_emailKey, session.user.email);
      await prefs.setString(_passwordKey, session.user.password);
    } catch (_) {}
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_restaurantIdKey);
      await prefs.remove(_restaurantNameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
    } catch (_) {}
  }
}
