// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_router.dart';
import 'core/app_initializer.dart';
import 'core/notification_service.dart';
import 'styles/app_theme.dart';

// ViewModels
import 'viewmodels/auth_vm.dart';
import 'viewmodels/medicine_vm.dart';
import 'viewmodels/medicine_log_vm.dart'; // ✅ ADD THIS
import 'viewmodels/reminders_vm.dart';
import 'viewmodels/profile_vm.dart';
import 'viewmodels/journal_vm.dart';
import 'viewmodels/flashcard_vm.dart';
import 'providers/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineViewModel()),
        ChangeNotifierProvider(create: (_) => MedicineLogViewModel()), // ✅ FIX
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
      initialRoute: '/splash',
    );
  }
}
