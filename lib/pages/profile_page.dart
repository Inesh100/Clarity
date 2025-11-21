import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../widgets/common_navbar.dart';
import '../styles/app_text.dart';
import '../styles/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final user = profileVm.user ?? authVm.appUser;

    if (authVm.firebaseUser != null && profileVm.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileVm.loadProfile(authVm.firebaseUser!.uid);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('You are not signed in', style: AppTextStyles.body))
          : profileVm.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.secondary,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: AppTextStyles.heading1.copyWith(fontSize: 48),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(user.name, style: AppTextStyles.heading2),
                          Text(user.email, style: AppTextStyles.body),
                          const SizedBox(height: 32),

                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/profile/edit');
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger
                            ),
                            onPressed: () async {
                              profileVm.clearProfile();
                              await authVm.signOut();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                          ),

                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Settings'),
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
