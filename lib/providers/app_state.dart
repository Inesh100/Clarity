// providers/app_state.dart
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _selectedPage = 'welcome';
  bool _isDarkMode = false;
  bool _isExactAlarmEnabled = true;

  String get selectedPage => _selectedPage;
  bool get isDarkMode => _isDarkMode;
  bool get isExactAlarmEnabled => _isExactAlarmEnabled;

  void setPage(String page) {
    _selectedPage = page;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setExactAlarmEnabled(bool value) {
    _isExactAlarmEnabled = value;
    notifyListeners();
  }
}
