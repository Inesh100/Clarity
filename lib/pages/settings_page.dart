import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/common_navbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: appState.isDarkMode,
          onChanged: (_) => appState.toggleTheme(),
        ),
      ]),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
