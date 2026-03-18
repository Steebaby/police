// lib/helpers/report_step_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class ReportStepManager {
  static const String _stepKey = 'loss_report_step';
  static const String _reportIdKey = 'loss_report_id';

  static Future<void> saveStep(int step, int reportId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepKey, step);
    await prefs.setInt(_reportIdKey, reportId);
  }

  static Future<Map<String, int?>> getSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'step': prefs.getInt(_stepKey),
      'reportId': prefs.getInt(_reportIdKey),
    };
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stepKey);
    await prefs.remove(_reportIdKey);
  }
}