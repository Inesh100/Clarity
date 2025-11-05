// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_router.dart';
import 'core/app_initializer.dart';
import 'core/notification_service.dart';
import 'styles/app_theme.dart';
import 'viewmodels/auth_vm.dart';
import 'viewmodels/medicine_vm.dart';
import 'viewmodels/reminders_vm.dart';
import 'viewmodels/profile_vm.dart';
import 'viewmodels/journal_vm.dart';
import 'viewmodels/flashcard_vm.dart';
import 'providers/app_state.dart';
import 'core/exact_alarm_permission_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app services (Firebase, SharedPreferences, etc.)
  await AppInitializer.initialize();

  // Create a single AppState instance and provide it to the app
  final appState = AppState();

  // Initialize notification service
  await NotificationService.instance.init();

  // NOTE:
  // We cannot call checkAndRequest(context) here because no BuildContext exists in main().
  // Exact-alarm permission is requested after app starts (WelcomePage initState).
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appState),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineViewModel()),
        ChangeNotifierProvider(create: (_) => RemindersViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => JournalViewModel()),
        ChangeNotifierProvider(create: (_) => FlashcardViewModel()),
      ],
      child: const ClarityApp(),
    ),
  );
}

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clarity',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
    );
  }
}
