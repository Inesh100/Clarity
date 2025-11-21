import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../viewmodels/auth_vm.dart';
import '../viewmodels/profile_vm.dart';
import '../widgets/common_navbar.dart';
import '../core/exact_alarm_permission_helper.dart';
import '../styles/app_text.dart';
import '../styles/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final authVm = context.read<AuthViewModel>();
    final profileVm = context.read<ProfileViewModel>();
    final user = authVm.firebaseUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    String? password;
    final providers = user.providerData.map((p) => p.providerId).toList();
    if (providers.contains('password')) {
      final passwordController = TextEditingController();
      final pwdConfirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Enter Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
          ],
        ),
      );
      if (pwdConfirm != true) return;
      password = passwordController.text;
    }

    try {
      await authVm.deleteAccount(password: password);
      profileVm.clearProfile();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                subtitle: const Text('Required for precise scheduled reminders'),
                value: isEnabled,
                onChanged: (value) async {
                  await ExactAlarmPermissionHelper.setEnabled(value);
                  appState.setExactAlarmEnabled(value);
                  if (value) {
                    await ExactAlarmPermissionHelper.checkAndRequest(context);
                  }
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: const Text("Edit Profile", style: AppTextStyles.body),
            onTap: () => Navigator.pushNamed(context, '/profile/edit'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.danger),
            title: const Text("Delete Account", style: TextStyle(color: AppColors.danger)),
            onTap: () => _deleteAccount(context),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () async {
                final profileVm = context.read<ProfileViewModel>();
                final authVm = context.read<AuthViewModel>();

                profileVm.clearProfile();
                await authVm.signOut();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                }
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
