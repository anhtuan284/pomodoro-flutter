import 'package:flutter/material.dart';
import 'package:pomodoro/src/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData newThemeData) {
    _themeData = newThemeData;
    notifyListeners();
  }

  void toggleTheme() {
    themeData = themeData == lightMode ? darkMode : lightMode;
  }
}
