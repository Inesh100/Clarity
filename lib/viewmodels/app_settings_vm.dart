/*// app_settings_vm.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsViewModel extends ChangeNotifier {
  bool _is24Hour = false;
  bool get is24Hour => _is24Hour;

  AppSettingsViewModel() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _is24Hour = prefs.getBool('is24Hour') ?? false;
    notifyListeners();
  }

  Future<void> toggleTimeFormat(bool value) async {
    _is24Hour = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is24Hour', value);
    notifyListeners();
  }
}

*/