import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_vm.dart';
import '../styles/app_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text('Welcome back', style: AppTextStyles.heading1),
            const SizedBox(height: 12),

            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: passCtrl,
              
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),

            // ✅ Fixed Sign-In button
            ElevatedButton(
              onPressed: () async {
                await vm.signIn(emailCtrl.text.trim(), passCtrl.text);
                if (!mounted) return;
                Navigator.pushNamed(context, '/welcome');
              },
              child: const Text('Sign In'),
            ),

            const SizedBox(height: 8),

            // ✅ Fixed Google Sign-In button
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Sign In with Google'),
              onPressed: () async {
                await vm.googleSignIn();
                if (!mounted) return;
                Navigator.pushNamed(context, '/welcome');
              },
            ),

            const Spacer(),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
