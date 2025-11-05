// pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_navbar.dart';
import '../core/exact_alarm_permission_helper.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: appState.isDarkMode,
            onChanged: (_) => appState.toggleTheme(),
          ),
          FutureBuilder<bool>(
            future: ExactAlarmPermissionHelper.isEnabled(),
            builder: (context, snapshot) {
              final isEnabled = snapshot.data ?? true;
              return SwitchListTile(
                title: const Text('Enable Exact Alarm Permission'),
                subtitle: const Text('Allow app to request exact alarm scheduling on Android'),
                value: isEnabled,
                onChanged: (value) async {
                  await ExactAlarmPermissionHelper.setEnabled(value);
                  // Update AppState locally (optional)
                  appState.setExactAlarmEnabled(value);
                  if (value) {
                    // Optionally prompt user to grant permission immediately
                    await ExactAlarmPermissionHelper.checkAndRequest(context);
                  }
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
