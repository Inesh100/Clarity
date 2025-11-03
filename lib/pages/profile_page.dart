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

    // Safely load user profile after build
    if (uid != null && profileVm.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileVm.loadProfile(uid);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileVm.user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // ✅ Prevents overflow on small screens
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.25, // ✅ Scales based on screen width
                        child: Text(
                          profileVm.user!.name.isNotEmpty
                              ? profileVm.user!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(profileVm.user!.name, style: AppTextStyles.heading2),
                      Text(profileVm.user!.email, style: AppTextStyles.body),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => authVm.signOut(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
ElevatedButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, '/about'); // Navigate to CreditsPage
  },
  icon: const Icon(Icons.info_outline),
  label: const Text('Credits'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    textStyle: const TextStyle(fontSize: 16),
  ),
),
ElevatedButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, '/settings'); // Navigate to CreditsPage
  },
  icon: const Icon(Icons.settings),
  label: const Text('Settings'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    textStyle: const TextStyle(fontSize: 16),
  ),
),
ElevatedButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, '/notifications'); // Navigate to CreditsPage
  },
  icon: const Icon(Icons.message_outlined),
  label: const Text('Notifications'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    textStyle: const TextStyle(fontSize: 16),
  ),
),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }
}
