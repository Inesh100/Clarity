import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/welcome_page.dart';
import '../pages/journal_page.dart';
import '../pages/flashcard_page.dart';
import '../pages/reminders_page.dart';
import '../pages/medicine_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/notifications_page.dart';
import '../pages/library_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case '/journal':
        return MaterialPageRoute(builder: (_) => const JournalPage());
      case '/flashcard':
        return MaterialPageRoute(builder: (_) => const FlashcardPage());
      case '/reminders':
        return MaterialPageRoute(builder: (_) => const RemindersPage());
      case '/medicine':
        return MaterialPageRoute(builder: (_) => const MedicinePage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case '/library':
        return MaterialPageRoute(builder: (_) => const LibraryPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
