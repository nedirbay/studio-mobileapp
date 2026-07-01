import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    loadSession();
  }

  static http.Client client = http.Client();

  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _token != null;

  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final userStr = prefs.getString('auth_user');
      if (userStr != null) {
        _user = Map<String, dynamic>.from(json.decode(userStr) as Map);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_user', json.encode(user));
      _token = token;
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_user');
      _token = null;
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': usernameOrEmail,
        'password': password,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Giriş şowsuz boldy');
    }
    final body = json.decode(utf8.decode(res.bodyBytes));
    if (body['jwt'] != null && body['user'] != null) {
      await saveSession(body['jwt'].toString(), Map<String, dynamic>.from(body['user'] as Map));
    }
    return Map<String, dynamic>.from(body as Map);
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Agza bolmak şowsuz boldy');
    }
    return Map<String, dynamic>.from(json.decode(utf8.decode(res.bodyBytes)) as Map);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'code': code,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Kod nädogry ýa-da möwriti öten';
      try {
        final body = json.decode(utf8.decode(res.bodyBytes));
        if (body is Map && body['error'] != null) {
          message = body['error'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
    final body = json.decode(utf8.decode(res.bodyBytes));
    if (body['jwt'] != null && body['user'] != null) {
      await saveSession(body['jwt'].toString(), Map<String, dynamic>.from(body['user'] as Map));
    }
    return Map<String, dynamic>.from(body as Map);
  }

  Future<void> resendOtp(String email) async {
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Kod ugratmak başartmady';
      try {
        final body = json.decode(utf8.decode(res.bodyBytes));
        if (body is Map && body['error'] != null) {
          message = body['error'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_token == null) throw Exception('Ulanyjy awtorizirlenen däl');
    final res = await client.post(
      Uri.parse('${Config.apiBaseUrl}/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Paroly çalşyp bolmady';
      try {
        final body = json.decode(utf8.decode(res.bodyBytes));
        if (body is Map && body['detail'] != null) message = body['detail'].toString();
      } catch (_) {}
      throw Exception(message);
    }
  }
}
