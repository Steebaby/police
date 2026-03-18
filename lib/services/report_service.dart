import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ReportService {
  static const String baseUrl = AuthService.baseUrl;

  // ── Auth Headers helper ───────────────────────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── STEP 1: Basic Information ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitLostPropertyStep1({
    required String category,
    required String itemName,
    required String estimatedValue,
    required String description,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/api/reports/lost-property/'),
        headers: headers,
        body: jsonEncode({
          'category': category,
          'item_name': itemName,
          'estimated_value':
              estimatedValue.isEmpty ? null : double.tryParse(estimatedValue),
          'description': description,
        }),
      );

      print('📡 Step1 Status: ${response.statusCode}');
      print('📦 Step1 Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'report_id': data['report']['id'],
        };
      }
      return {'success': false, 'message': 'Failed to submit report.'};
    } catch (e) {
      print('❌ Step1 Error: $e');
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── STEP 2: Location & Time ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitLostPropertyStep2({
    required int reportId,
    required String location,
    required String landmark,
    required String circumstances,
    required DateTime? dateLost,
    required TimeOfDay? timeLost,
  }) async {
    try {
      final headers = await _authHeaders();

      print('📍 Report ID: $reportId');

      final body = <String, dynamic>{
        'location': location,
        'landmark': landmark,
        'circumstances': circumstances,
        if (dateLost != null)
          'date_lost': '${dateLost.year}-'
              '${dateLost.month.toString().padLeft(2, '0')}-'
              '${dateLost.day.toString().padLeft(2, '0')}',
        if (timeLost != null)
          'time_lost': '${timeLost.hour.toString().padLeft(2, '0')}:'
              '${timeLost.minute.toString().padLeft(2, '0')}:00',
      };

      print('📦 Step2 Body: $body');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/reports/lost-property/$reportId/'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📡 Step2 Status: ${response.statusCode}');
      print('📦 Step2 Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {
        'success': false,
        'message': 'Failed to save location details.'
      };
    } catch (e) {
      print('❌ Step2 Error: $e');
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── STEP 3: Fetch full report by ID ───────────────────────────────────────
  static Future<Map<String, dynamic>> getLostReportById(
      int reportId) async {
    try {
      final headers = await _authHeaders();

      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/reports/lost-property/$reportId/detail/'),
        headers: headers,
      );

      print('📡 GetReport Status: ${response.statusCode}');
      print('📦 GetReport Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both { report: {...} } and flat { id:..., item_name:... }
        if (data is Map && data.containsKey('report')) {
          return data['report'] as Map<String, dynamic>;
        }
        return data as Map<String, dynamic>;
      }
      throw Exception(
          'Failed to load report. Status: ${response.statusCode}');
    } catch (e) {
      print('❌ GetReport Error: $e');
      rethrow;
    }
  }

  // ── STEP 3: Final submit ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitLostPropertyFinal({
    required int reportId,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/reports/lost-property/$reportId/submit/'),
        headers: headers,
      );

      print('📡 FinalSubmit Status: ${response.statusCode}');
      print('📦 FinalSubmit Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'control_number': data['control_number'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Submission failed.'
      };
    } catch (e) {
      print('❌ FinalSubmit Error: $e');
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── PAYMENT ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitPayment({
    required int reportId,
    required String method,
    required String phone,
    required double amount,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/reports/lost-property/$reportId/payment/'),
        headers: headers,
        body: jsonEncode({
          'method': method,
          'phone': phone,
          'amount': amount,
        }),
      );

      print('📡 Payment Status: ${response.statusCode}');
      print('📦 Payment Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Payment confirmed!',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Payment failed.'
      };
    } catch (e) {
      print('❌ Payment Error: $e');
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }
}