import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../viewmodels/auth_vm.dart';
import '../viewmodels/medicine_log_vm.dart';

import '../styles/app_text.dart';
import '../widgets/common_navbar.dart';

import 'journal_page.dart';
import 'flashcard_page.dart';
import 'reminders_page.dart';
import 'medicine_page.dart';
import 'medicine_log_page.dart';
import 'motivation_timer_page.dart';
import '../core/exact_alarm_permission_helper.dart';
import '../core/notification_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVM = context.read<AuthViewModel>();
      final logVM = context.read<MedicineLogViewModel>();
      final userId = authVM.currentUserId;

      // ✅ Load today's logs for progress bar
      if (userId != null) {
        await logVM.loadTodayLogs(userId);
      }

      // ✅ Request exact alarm permission on Android
      final enabled = await ExactAlarmPermissionHelper.isEnabled();
      if (!enabled) {
        await ExactAlarmPermissionHelper.checkAndRequest(context);
      }

      if (mounted) {
        setState(() => _initialized = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (!_initialized || authVM.currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final logVM = context.watch<MedicineLogViewModel>();

    final userId = authVM.currentUserId!;
    final name = authVM.appUser?.name ?? "User";

    final progress = logVM.todayProgress;
    final percent = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: appState.isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surface,

      appBar: AppBar(
        title: Text("Welcome, $name"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Today's Medicine Progress ($percent%)",
                style: AppTextStyles.subtitle),
            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 20),
//discuss different options
            Text(
              "Choose where to go:",
              style: AppTextStyles.subtitle.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 700,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _nav(context, "Journal", Icons.book, const JournalPage()),
                  _nav(context, "Motivation & Timer", Icons.favorite,
                      const MotivationTimerPage()),
                  _nav(context, "Reminders", Icons.alarm, const ReminderPage()),
                  _nav(context, "Medicine", Icons.medication, const MedicinePage()),
                  _nav(context, "Flashcards", Icons.school, const FlashcardPage()),
                  _nav(context, "Medicine Logs", Icons.checklist_rounded,
                      MedicineLogPage(userId: userId)),
                ],
              ),
            ),
/*
            const SizedBox(height: 20),

            /// ✅ TEST NOTIFICATION BUTTONS
          
            Text("Debug Notifications",
                style: AppTextStyles.subtitle
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () =>
                  NotificationService.instance.showTestNotification(
                    "Daily Test 🔔",
                    "This is a test daily reminder",
                  ),
              child: const Text("Test Daily Notification"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () =>
                  NotificationService.instance.showTestNotification(
                    "Weekly Test 🔔",
                    "This is a test weekly reminder",
                  ),
              child: const Text("Test Weekly Notification"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () =>
                  NotificationService.instance.showTestNotification(
                    "Monthly Test 🔔",
                    "This is a test monthly reminder",
                  ),
              child: const Text("Test Monthly Notification"),
            ),*/
          ],
        ),
      ),

      bottomNavigationBar: const CommonNavBar(),
    );
  }

  Widget _nav(BuildContext context, String label, IconData icon, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
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
