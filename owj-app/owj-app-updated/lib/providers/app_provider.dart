import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  bool _isDarkMode = true;
  bool _isFirstLaunch = true;

  AppProvider(this.prefs) {
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
  }

  bool get isDarkMode => _isDarkMode;
  bool get isFirstLaunch => _isFirstLaunch;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  void setFirstLaunchDone() {
    _isFirstLaunch = false;
    prefs.setBool('is_first_launch', false);
    notifyListeners();
  }
}
