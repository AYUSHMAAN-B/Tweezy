import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/themes/dark_theme.dart';
import 'package:minimal_tweets_app/themes/light_theme.dart';

class ThemeProvider extends ChangeNotifier {
  
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    _themeData = (isDarkMode) ? lightMode : darkMode;
    notifyListeners();
  }

}