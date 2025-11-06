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
  bool _obscurePassword = true; 
  bool _rememberMe = true; // default to true

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<AuthViewModel>();
      final email = await vm.getLastEmail();
      if (email != null) {
        emailCtrl.text = email;
      }
    });
  }

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
              style: const TextStyle(fontSize: 16), 
              decoration: const InputDecoration(
                labelText: 'Email', 
                labelStyle: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),

            // Password Field
            TextField(
              controller: passCtrl,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(fontSize: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ✅ Remember Me checkbox
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (val) {
                    setState(() {
                      _rememberMe = val ?? true;
                    });
                  },
                ),
                const Text("Remember Me"),
              ],
            ),
            const SizedBox(height: 8),

            // Sign-In button
            ElevatedButton(
              onPressed: () async {
                await vm.signIn(emailCtrl.text.trim(), passCtrl.text);
                if (!mounted) return;

                if (vm.firebaseUser != null) {
                  if (_rememberMe) {
                    await vm.saveLastEmail(emailCtrl.text.trim());
                  } else {
                    await vm.clearLastEmail();
                  }
                  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vm.error ?? 'Login failed')),
                  );
                }
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 8),

            // Google Sign-In button
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Sign In with Google'),
              onPressed: () async {
                await vm.googleSignIn();
                if (!mounted) return;

                if (vm.firebaseUser != null) {
                  if (_rememberMe) {
                    await vm.saveLastEmail(vm.firebaseUser!.email ?? '');
                  } else {
                    await vm.clearLastEmail();
                  }
                  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vm.error ?? 'Google sign-in failed')),
                  );
                }
              },
            ),

            const Spacer(),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text(
                'Create account', 
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
