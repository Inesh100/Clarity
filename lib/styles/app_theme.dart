import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
    textTheme: const TextTheme(titleLarge: AppTextStyles.heading1, titleMedium: AppTextStyles.heading2, bodyMedium: AppTextStyles.body),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, textStyle: AppTextStyles.buttonText)),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF0F1113),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF111216), foregroundColor: Colors.white, elevation: 0),
    textTheme: const TextTheme(titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white), titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white), bodyMedium: TextStyle(fontSize: 16, color: Colors.white)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, textStyle: AppTextStyles.buttonText)),
  );
}
