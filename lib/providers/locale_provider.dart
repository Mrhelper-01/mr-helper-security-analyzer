import 'package:flutter/widgets.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';

/// MR HELPER - Web Application Security Analyzer
/// Provider that holds the current UI language and exposes translated strings.
class LocaleProvider extends ChangeNotifier {
  AppLang _lang = AppLang.en;

  AppLang get lang => _lang;
  bool get isKurdish => _lang == AppLang.ckb;

  /// Translated strings for the current language.
  AppStrings get strings => AppStrings(_lang);

  /// Text direction follows the language (Kurdish is right-to-left).
  TextDirection get textDirection =>
      isKurdish ? TextDirection.rtl : TextDirection.ltr;

  void setLanguage(AppLang lang) {
    if (_lang == lang) return;
    _lang = lang;
    notifyListeners();
  }

  void toggle() => setLanguage(isKurdish ? AppLang.en : AppLang.ckb);
}
