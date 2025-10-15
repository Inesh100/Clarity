import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _selectedPage = 'welcome';
  bool _isDarkMode = false;

  String get selectedPage => _selectedPage;
  bool get isDarkMode => _isDarkMode;

  void setPage(String page) {
    _selectedPage = page;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
