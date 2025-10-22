import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/app_router.dart';
import 'core/app_initializer.dart';
import 'styles/app_theme.dart';
import 'viewmodels/auth_vm.dart';
import 'viewmodels/medicine_vm.dart';
import 'viewmodels/reminders_vm.dart';
import 'viewmodels/profile_vm.dart';
import 'viewmodels/journal_vm.dart';
import 'viewmodels/flashcard_vm.dart';
import 'providers/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => MedicineViewModel()),
      ChangeNotifierProvider(create: (_) => RemindersViewModel()),
      ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ChangeNotifierProvider(create: (_) => JournalViewModel()),
      ChangeNotifierProvider(create: (_) => FlashcardViewModel()),
    ],
    child: const ClarityApp(),
  ));
}

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
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
