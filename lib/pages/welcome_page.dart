import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../viewmodels/auth_vm.dart';
import '../styles/app_text.dart';
import '../widgets/common_navbar.dart';
import 'journal_page.dart';
import 'flashcard_page.dart';
import 'reminders_page.dart';
import 'medicine_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);


    final authVM = context.watch<AuthViewModel>();
    final name = authVM.appUser?.name ?? 'User';

    return Scaffold(
      backgroundColor: appState.isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Welcome, $name'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Welcome Back!', style: AppTextStyles.heading1),
            const SizedBox(height: 16),
            Text(
              'Choose where you want to go:',
              style: AppTextStyles.subtitle.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildNavButton(
                      context, 'Journal', Icons.book, const JournalPage()),
                  _buildNavButton(context, 'Flashcards', Icons.school,
                      const FlashcardPage()),
                  _buildNavButton(context, 'Reminders', Icons.alarm,
                      const RemindersPage()),
                  _buildNavButton(
                      context, 'Medicine', Icons.medication, const MedicinePage()),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Designed by Sedelle & Sade',
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }

  Widget _buildNavButton(
      BuildContext context, String label, IconData icon, Widget targetPage) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(16),
        elevation: 2,
      ),
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => targetPage,
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.buttonText),
        ],
      ),
    );
  }
}
