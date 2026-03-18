import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // ← Use your computer's IP address (not localhost) so phone/emulator can connect
  //static const String baseUrl = 'http://localhost:8000';//web browser
  //static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000'; // iOS simulator
   static const String baseUrl = 'http://192.168.1.188:8000'; // Real phone - change to your IP

  static const _storage = FlutterSecureStorage();

  // ── REGISTER ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String nidaNumber,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name':        fullName,
          'nida_number':      nidaNumber,
          'phone_number':     phoneNumber,
          'email':            email,
          'password':         password,
          'confirm_password': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Account created successfully!'};
      } else {
        // Extract first error message from Django
        String errorMsg = 'Registration failed. Please try again.';
        if (data is Map) {
          final firstKey = data.keys.first;
          final firstValue = data[firstKey];
          if (firstValue is List) {
            errorMsg = firstValue.first.toString();
          } else {
            errorMsg = firstValue.toString();
          }
        }
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server. Check your connection.'};
    }
  }

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save tokens securely
        await _storage.write(key: 'access_token',  value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Invalid email or password.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // ── GET TOKEN ─────────────────────────────────────────────────────────────
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
}