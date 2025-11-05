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
    // Watch authVM so UI rebuilds when user signs in/out
    final authVm = context.watch<AuthViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final uid = authVm.firebaseUser?.uid;

    // Load profile if signed in and not already loaded
    if (uid != null && profileVm.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileVm.loadProfile(uid);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: uid == null
          ? const Center(
              child: Text('You are not signed in', style: AppTextStyles.body),
            )
          : profileVm.user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.25,
                            child: Text(
                              profileVm.user!.name.isNotEmpty
                                  ? profileVm.user!.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(profileVm.user!.name, style: AppTextStyles.heading2),
                          Text(profileVm.user!.email, style: AppTextStyles.body),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await authVm.signOut();
                              // Clear profile data on sign out
                              profileVm.clearProfile();
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/about');
                            },
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Credits'),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Settings'),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/notifications');
                            },
                            icon: const Icon(Icons.message_outlined),
                            label: const Text('Medicine logs'),
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
