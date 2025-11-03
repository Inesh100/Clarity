import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';

class ExactAlarmPermissionHelper {
  /// Show a dialog prompting the user to enable exact alarms
  static Future<void> checkAndRequest(BuildContext context) async {
    if (!Platform.isAndroid) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exact Alarm Permission Needed'),
        content: const Text(
          'To schedule reminders accurately, Clarity needs permission '
          'to use exact alarms. Please enable it in system settings.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final intent = AndroidIntent(
                action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
              );
              await intent.launch();
              Navigator.of(ctx).pop();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
