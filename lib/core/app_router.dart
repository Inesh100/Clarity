// lib/core/app_router.dart
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
import '../pages/about_page.dart';
import '../pages/motivation_timer_page.dart';
import '../pages/splash_page.dart';
import '../pages/edit_profile.dart';
import '../pages/calendar_page.dart'; 
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashPage());
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
        return MaterialPageRoute(builder: (_) => const ReminderPage());
      case '/medicine':
        return MaterialPageRoute(builder: (_) => const MedicinePage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case '/profile/edit':
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case '/library':
        return MaterialPageRoute(builder: (_) => const LibraryPage());
      case '/about':
        return MaterialPageRoute(builder: (_) => const CreditsPage());
      case '/motivation_timer':
        return MaterialPageRoute(builder: (_) => const MotivationTimerPage());
      case '/calendar':
        return MaterialPageRoute(builder: (_) => const CalendarPage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
