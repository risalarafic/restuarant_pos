import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'login_response.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthApi {
  Future<LoginResponse> login({
    required String username,
    required String password,
  });
}

class RemoteAuthApi implements AuthApi {
  RemoteAuthApi({
    http.Client? client,
    this.loginUrl = ApiConfig.loginUrl,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String loginUrl;

  @override
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final requestBody = {
      'username': username.trim(),
      'password': password,
    };
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    debugPrint('LOGIN REQUEST url=$loginUrl');
    debugPrint('LOGIN REQUEST headers=$headers');
    debugPrint('LOGIN REQUEST body=$requestBody');

    try {
      final response = await _client
          .post(
            Uri.parse(loginUrl),
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('LOGIN RESPONSE status=${response.statusCode}');
      debugPrint('LOGIN RESPONSE headers=${response.headers}');
      debugPrint('LOGIN RESPONSE body=${response.body}');

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AuthException('Unexpected login response');
      }

      final result = LoginResponse.fromJson(decoded);
      if (!result.success) {
        throw AuthException(result.message ?? 'Invalid email or password');
      }
      if (result.authToken == null ||
          result.authToken!.isEmpty ||
          result.user == null) {
        throw const AuthException('Login succeeded but user details are missing');
      }
      return result;
    } on AuthException catch (error) {
      debugPrint('LOGIN ERROR $error');
      rethrow;
    } on TimeoutException catch (error) {
      debugPrint('LOGIN ERROR timeout=$error');
      throw const AuthException('Login timed out. Please try again.');
    } on FormatException catch (error) {
      debugPrint('LOGIN ERROR format=$error');
      throw const AuthException('Unexpected login response');
    } on http.ClientException catch (error) {
      debugPrint('LOGIN ERROR client=$error');
      throw const AuthException(
        'Unable to connect. Check your internet connection.',
      );
    } catch (error) {
      debugPrint('LOGIN ERROR $error');
      throw const AuthException(
        'Unable to connect. Check your internet connection.',
      );
    }
  }
}
