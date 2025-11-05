// core/exact_alarm_permission_helper.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';

class ExactAlarmPermissionHelper {
  ExactAlarmPermissionHelper._();
  static final instance = ExactAlarmPermissionHelper._();

  static const _prefKey = 'exact_alarm_enabled';

  /// Returns whether exact alarm is enabled in settings (persisted)
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? true; // default enabled
  }

  /// Sets the toggle in settings
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  /// Checks and requests exact alarm permission (Android only). Uses permission_handler
  /// and falls back to opening system settings for Android 14+ if required.
  static Future<void> checkAndRequest(BuildContext context) async {
    final enabled = await isEnabled();
    if (!enabled) return;
    if (!Platform.isAndroid) return;

    // If the permission is already granted via permission_handler, nothing to do
    final p = Permission.scheduleExactAlarm;
    if (await p.isGranted) return;

    // Try to request runtime permission
    final status = await p.request();
    if (status.isGranted) return;

    // If not granted and Android 14+ (or manufacturer requires system UI), open the system settings screen
    final sdk = int.tryParse(Platform.version.split(' ').first) ?? 0;
    const android14 = 34;
    if (sdk >= android14) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }

    // If still not granted, show a SnackBar explaining
    if (context.mounted && !await p.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exact Alarm permission is needed for precise notifications.'),
        ),
      );
    }
  }
}
