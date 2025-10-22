import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading1 = TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const body = TextStyle(fontSize: 16, color: AppColors.textSecondary);
  static const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
  static const small = TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const subtitle = small;
}
