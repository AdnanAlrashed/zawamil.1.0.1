import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode;

  ThemeNotifier(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = !_isDarkMode;
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
