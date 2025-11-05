// pages/welcome_page.dart
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
import 'motivation_timer_page.dart';
import '../core/notification_service.dart';
import '../core/exact_alarm_permission_helper.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    // Ask for exact alarm permission after the first frame if the user enabled the toggle
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final enabled = await ExactAlarmPermissionHelper.isEnabled();
      if (enabled) {
        await ExactAlarmPermissionHelper.checkAndRequest(context);
      }
    });
  }

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
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            SizedBox(
              height: 400,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildNavButton(context, 'Journal', Icons.book, const JournalPage()),
                  _buildNavButton(context, 'Motivational & Study Timer', Icons.favorite,
                      const MotivationTimerPage()),
                  _buildNavButton(context, 'Reminders', Icons.alarm, const ReminderPage()),
                  _buildNavButton(context, 'Medicine', Icons.medication, const MedicinePage()),
                  _buildNavButton(context, 'Flashcards', Icons.school, const FlashcardPage()),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Test Notifications', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            ..._buildNotificationButtons(),
            const SizedBox(height: 24),

            const Text(
              'Designed by Sedelle & Sade',
              style: AppTextStyles.small,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonNavBar(),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, IconData icon, Widget targetPage) {
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
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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

  List<Widget> _buildNotificationButtons() {
    final now = DateTime.now();
    int uniqueId(int offset) => now.microsecondsSinceEpoch.remainder(100000) + offset;

    return [
      _notifButton('Instant Notification', () async {
        await NotificationService.instance.showInstant(
          id: uniqueId(0),
          title: 'Instant Notification',
          body: '✅ This notification appears immediately.',
        );
        _showSnack('Instant Notification sent!');
      }),
      _notifButton('Schedule 1-Minute Notification', () async {
        await NotificationService.instance.scheduleOneTime(
          id: uniqueId(1),
          title: 'One-Time Notification',
          body: '⏰ This triggers 1 minute from now.',
          dateTime: now.add(const Duration(minutes: 1)),
        );
        _showSnack('1-Minute Notification scheduled!');
      }),
      _notifButton('Schedule Daily Notification', () async {
        await NotificationService.instance.scheduleDaily(
          id: uniqueId(2),
          title: 'Daily Notification',
          body: '🗓 Repeats daily at this time.',
          hour: now.hour,
          minute: (now.minute + 1) % 60,
        );
        _showSnack('Daily Notification scheduled!');
      }),
      _notifButton('Schedule Weekly Notification', () async {
        await NotificationService.instance.scheduleWeekly(
          id: uniqueId(3),
          title: 'Weekly Notification',
          body: '📅 Repeats weekly on the same weekday.',
          weekday: now.weekday,
          hour: now.hour,
          minute: (now.minute + 2) % 60,
        );
        _showSnack('Weekly Notification scheduled!');
      }),
      _notifButton('Schedule Monthly Notification', () async {
        await NotificationService.instance.scheduleMonthly(
          id: uniqueId(4),
          title: 'Monthly Notification',
          body: '🗓 Repeats monthly on the 2nd weekday.',
          weekday: now.weekday,
          weekOfMonth: 2,
          hour: now.hour,
          minute: (now.minute + 3) % 60,
        );
        _showSnack('Monthly Notification scheduled!');
      }),
    ];
  }

  Widget _notifButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }

  void _showSnack(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
    }
  }
}
