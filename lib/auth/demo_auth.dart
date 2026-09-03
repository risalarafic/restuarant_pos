import 'package:shared_preferences/shared_preferences.dart';

class DemoAuth {
  DemoAuth._();

  static const email = 'admin@kudeghor.com';
  static const password = 'Admin@123';
  static const _rememberKey = 'remember_me';
  static const _emailKey = 'remembered_email';
  static const _passwordKey = 'remembered_password';

  static final emailFormat = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    if (!emailFormat.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static bool matches(String email, String password) {
    return email.trim().toLowerCase() == DemoAuth.email &&
        password == DemoAuth.password;
  }

  static Future<({bool remember, String email, String password})> loadRemembered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool(_rememberKey) ?? true;
      if (!remember) {
        return (remember: false, email: '', password: '');
      }
      return (
        remember: true,
        email: prefs.getString(_emailKey) ?? DemoAuth.email,
        password: prefs.getString(_passwordKey) ?? DemoAuth.password,
      );
    } catch (_) {
      return (
        remember: true,
        email: DemoAuth.email,
        password: DemoAuth.password,
      );
    }
  }

  static Future<void> saveRemembered({
    required bool remember,
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberKey, remember);
      if (remember) {
        await prefs.setString(_emailKey, email);
        await prefs.setString(_passwordKey, password);
      } else {
        await prefs.remove(_emailKey);
        await prefs.remove(_passwordKey);
      }
    } catch (_) {}
  }
}
