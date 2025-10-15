import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../widgets/common_navbar.dart';
import '../styles/app_text.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final profileVm = Provider.of<ProfileViewModel>(context);
    final uid = authVm.firebaseUser?.uid;
    if (uid != null && profileVm.user == null) profileVm.loadProfile(uid);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileVm.user == null ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          CircleAvatar(radius: 36, child: Text(profileVm.user!.name.isNotEmpty ? profileVm.user!.name[0] : 'U')),
          const SizedBox(height: 8),
          Text(profileVm.user!.name, style: AppTextStyles.heading2),
          Text(profileVm.user!.email, style: AppTextStyles.body),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => authVm.signOut(), child: const Text('Sign Out')),
        ])
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
