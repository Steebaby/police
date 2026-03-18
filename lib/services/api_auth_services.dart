import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // adjust import path if needed

class ApiService {
  // ── Reuses the same baseUrl as AuthService ────────────────────────────────
  static const String baseUrl = AuthService.baseUrl;

  // ── Build headers, auto-attaches Bearer token ─────────────────────────────
  static Future<Map<String, String>> _headers({bool requiresAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (requiresAuth) {
      final token = await AuthService.getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Handle response, throws readable errors ───────────────────────────────
  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    if (response.statusCode == 401) throw ApiException('Session expired. Please log in again.', 401);
    if (response.statusCode == 403) throw ApiException('You do not have permission.', 403);
    if (response.statusCode == 404) throw ApiException('Resource not found.', 404);

    // Extract Django error message
    String errorMsg = 'Request failed (${response.statusCode})';
    if (data is Map && data.isNotEmpty) {
      final firstValue = data.values.first;
      errorMsg = firstValue is List ? firstValue.first.toString() : firstValue.toString();
    }
    throw ApiException(errorMsg, response.statusCode);
  }

  // ── GET ───────────────────────────────────────────────────────────────────
  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/$endpoint');
      if (queryParams != null) uri = uri.replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: await _headers(requiresAuth: requiresAuth))
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Cannot connect to server. Check your connection.');
    }
  }

  // ── POST ──────────────────────────────────────────────────────────────────
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/$endpoint'),
            headers: await _headers(requiresAuth: requiresAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Cannot connect to server. Check your connection.');
    }
  }

  // ── PUT ───────────────────────────────────────────────────────────────────
  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/$endpoint'),
            headers: await _headers(requiresAuth: requiresAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Cannot connect to server. Check your connection.');
    }
  }

  // ── PATCH ─────────────────────────────────────────────────────────────────
  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/$endpoint'),
            headers: await _headers(requiresAuth: requiresAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Cannot connect to server. Check your connection.');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  static Future<dynamic> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/$endpoint'),
            headers: await _headers(requiresAuth: requiresAuth),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Cannot connect to server. Check your connection.');
    }
  }

  // ── MULTIPART UPLOAD (image + fields) ─────────────────────────────────────
  // Used with image_picker: pass File from ImagePicker result
  static Future<dynamic> uploadFile({
    required String endpoint,
    required Map<String, String> fields,
    required File file,
    String fileField = 'image', // Django field name
    bool requiresAuth = true,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/$endpoint'),
      );

      if (requiresAuth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Upload failed. Check your connection.');
    }
  }
}

// ── Custom exception for clean error handling ─────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}