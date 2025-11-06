// lib/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_vm.dart';
import '../viewmodels/auth_vm.dart';
import '../models/app_user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileViewModel>().user;
    nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final profileVm = context.watch<ProfileViewModel>();
    final authVm = context.read<AuthViewModel>();
    final user = profileVm.user ?? authVm.appUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? "Enter a name" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: profileVm.loading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final updated = user.copyWith(name: nameController.text);

                          // Update Firestore
                          await profileVm.updateProfile(updated);

                          // Sync with AuthViewModel
                          authVm.appUser = updated;
                          authVm.notifyListeners();

                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                child: profileVm.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
