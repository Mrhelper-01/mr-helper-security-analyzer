import 'package:flutter/material.dart';
import '../core/theme.dart';

/// MR HELPER - Web Application Security Analyzer
/// Theme provider for managing light/dark mode

class ThemeProvider extends ChangeNotifier {
  // دۆخی هەنووکەیی تیم (ڕووناک یان تاریک)
  ThemeData _currentTheme = lightMode;

  // ئایا دۆخی تاریک چالاکە؟
  bool _isDarkMode = false;

  // گەڕانەوەی ThemeData ی هەنووکەیی
  ThemeData get themeData => _currentTheme;

  // گەڕانەوەی دۆخی تاریک یان ڕووناک
  bool get isDarkMode => _isDarkMode;

  // گۆڕینی تیم (Dark <-> Light)
  void toggleTheme() {
    if (_isDarkMode) {
      // بگۆڕە بۆ ڕووناک
      _currentTheme = lightMode;
      _isDarkMode = false;
    } else {
      // بگۆڕە بۆ تاریک
      _currentTheme = darkMode;
      _isDarkMode = true;
    }
    // ئاگادارکردنەوەی هەموو ویجێتەکان بۆ نوێکردنەوە
    notifyListeners();
  }

  /// دانانی تیم بە دەست (بۆ بارکردنی دۆخی پاشەکەوتکراو)
  void setTheme(ThemeData theme, bool isDark) {
    _currentTheme = theme;
    _isDarkMode = isDark;
    notifyListeners();
  }

  /// گەڕانەوە بە دۆخی ڕووناک
  void setLightMode() {
    if (!_isDarkMode) return;
    _currentTheme = lightMode;
    _isDarkMode = false;
    notifyListeners();
  }

  /// گەڕانەوە بە دۆخی تاریک
  void setDarkMode(bool value) {
    if (_isDarkMode) return;
    _currentTheme = darkMode;
    _isDarkMode = true;
    notifyListeners();
  }
}
