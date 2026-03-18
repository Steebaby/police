import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ClearanceService {
  static const String baseUrl = AuthService.baseUrl;

  // ── Auth Headers ──────────────────────────────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  // ── STEP 1: Submit Personal Information ───────────────────────────────────
  static Future<Map<String, dynamic>> submitStep1({
    required String fullName,
    required String phone,
    required String nidaNumber,
    required String purpose,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/api/clearance/'),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName,
          'phone': phone,
          'nida_number': nidaNumber,
          'purpose': purpose,
        }),
      );

      print('📡 Clearance Step1 Status: ${response.statusCode}');
      print('📦 Clearance Step1 Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Personal info saved.',
          'application_id': data['application']['id'],
        };
      }

      // Surface Django validation errors (e.g. duplicate NIDA)
      final errors = data is Map ? data.toString() : 'Failed to submit.';
      return {'success': false, 'message': errors};
    } catch (e) {
      print('❌ Clearance Step1 Error: $e');
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── STEP 2: Upload Documents ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitStep2({
    required int applicationId,
    required File passportPhoto,
    required File nidaCopy,
    required File introLetter,
  }) async {
    try {
      final headers = await _authHeaders();

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/api/clearance/$applicationId/documents/'),
      );

      // Add auth header (no Content-Type — multipart sets it automatically)
      request.headers.addAll(headers);

      // Attach the three files with the field names Django expects
      request.files.add(await http.MultipartFile.fromPath(
        'passport_photo',
        passportPhoto.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'nida_copy',
        nidaCopy.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'intro_letter',
        introLetter.path,
      ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print('📡 Clearance Step2 Status: ${response.statusCode}');
      print('📦 Clearance Step2 Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Documents uploaded.',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to upload documents.',
      };
    } catch (e) {
      print('❌ Clearance Step2 Error: $e');
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── STEP 3: Final Submit (trigger backend processing) ─────────────────────
  static Future<Map<String, dynamic>> submitFinal({
    required int applicationId,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/api/clearance/$applicationId/submit/'),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
      );

      print('📡 Clearance Final Status: ${response.statusCode}');
      print('📦 Clearance Final Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Application submitted.',
          'reference_number': data['reference_number'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Final submission failed.',
      };
    } catch (e) {
      print('❌ Clearance Final Error: $e');
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── GET Application by ID ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getApplicationById(
      int applicationId) async {
    try {
      final headers = await _authHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/api/clearance/$applicationId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to load application: ${response.statusCode}');
    } catch (e) {
      print('❌ GetApplication Error: $e');
      rethrow;
    }
  }
}